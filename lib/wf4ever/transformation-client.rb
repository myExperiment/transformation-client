require 'net/http'
require 'json'

module Wf4Ever
  class TransformationClient

    ##
    # Create a transformation job and returns its URI, which can be
    # used with check_job() and cancel_job()
    #
    # uri -- The URI for the wf-ro service endpoint, e.g.
    #   "http://example.com/wf-ro/jobs"
    # resource - The URI for the workflow resource to transform, e.g.
    #   "http://www.example.net/workflow.t2flow"
    # format - the media type of the resource, e.g.
    #   "application/vnd.taverna.t2flow+xml"
    # ro - the URI for the research object within an RODL service,
    #   where the transformed and extracted resources are to be uploaded
    # token - token for authenticating access to the RODL
    # extract -
    #   (optional) hash of folders where to extract additional
    #   resources. The main workflow is always extracted, but will
    #   only be placed into a folder if it is given in the hash. Other
    #   resource types are only extracted if listed in the map. 
    #
    #   The extract keys should be one of:
    #     - :main -- transformed workflow 
    #     - :nested -- nested workflows
    #     - :scripts -- embedded scripts (e.g. beanshell, R)
    #     - :services -- external services (e.g. WSDL, REST)
    #   
    #   The extract values are URIs to RODL folders within the RO where to
    #   extract the resource. A value using the keyword :ro means to
    #   extract the particular resource without aggregating it in any 
    #   particular folder.
    def self.create_job(uri, resource, format, ro, token, extract={:main=>:ro})
      uri = URI(uri)
      job_uri = nil
      ## Replace :ro with the ro URI as per wf-ro REST API
      # We'll do this in a new hash to not modify our incoming hash
      # TODO: Avoid Perl-like syntax below..
      extract = extract.each_with_object({}) { |(k,v), h|  h[k] = v==:ro ? ro : v } 

      Net::HTTP.start(uri.host, uri.port || 80) do |http|
        body = {
          "resource" => resource,
          "format" => format,
          "ro" => ro,
          "token" => token,
          "extract" => extract
        }.to_json
        
        headers = {"content-type" => "application/json"}

        response = http.post(uri.request_uri, body, headers)

        if response.code == "201"
          job_uri = response["Location"] || response["location"]
        else
          raise "#{response.code} #{response.body}"
        end
      end
      job_uri
    end

    ##
    # Check wf-ro transformation job status.
    #
    # Return a hash containing: 
    # ["resource"]  the resource being transformed
    # ["format"]    the content type of the resource
    # ["ro"]        the URI of the RO being created
    # ["status"]    the status of the transformation job  
    # ["extract"]   the resource type to extract, to which folder
    def self.check_job(uri)
      uri = URI(uri)
      Net::HTTP.start(uri.host, uri.port || 80) do |http|

        response = http.get(uri.request_uri)

        if response.code == "200"
          response_body = JSON.parse(response.body)
          response_body
        else
          raise "#{response.code} #{response.body}"
        end
      end
    end

    ##
    # Cancel wf-ro transformation job and returns true if it succeeds.
    def self.cancel_job(uri)
      uri = URI(uri)
      Net::HTTP.start(uri.host, uri.port || 80) do |http|

        response = http.delete(uri.request_uri)

        if response.code == "204"
          true
        else
          raise "#{response.code} #{response.body}"
        end
      end
    end
  end
end

