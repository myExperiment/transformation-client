require 'helper'

class TestTransformationClient < Test::Unit::TestCase

  SERVICE_URI = "http://sandbox.wf4ever-project.org/wf-ro/jobs"
  T2FLOW_FORMAT = "application/vnd.taverna.t2flow+xml"
  OAUTH_TOKEN = "47d5423c-b507-4e1c-8"
  RESOURCE = "http://www.myexperiment.org/workflows/2470/download/_untitled__947103.t2flow?version=2"
  RO = "http://sandbox.wf4ever-project.org/rodl/ROs/FinnsTest/"

  def test_can_create
    uri = Wf4Ever::TransformationClient.create_job(SERVICE_URI, RESOURCE, T2FLOW_FORMAT, RO, OAUTH_TOKEN)
    assert_not_nil uri
  end

end
