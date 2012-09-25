require 'helper'

class TestTransformationClient < Test::Unit::TestCase

  SERVICE_URI = "http://sandbox.wf4ever-project.org/wf-ro/jobs"
  T2FLOW_FORMAT = "http://taverna.sf.net/2008/xml/t2flow"
  OAUTH_TOKEN = "47d5423c-b507-4e1c-8"

  def test_can_create
    uri = Wf4Ever::TransformationClient.create_job(SERVICE_URI, 
        "http://www.myexperiment.org/workflows/2470/download/_untitled__947103.t2flow?version=2", 
        T2FLOW_FORMAT,
        "http://sandbox.wf4ever-project.org/rodl/ROs/FinnsTest/",
        OAUTH_TOKEN)
    assert_not_nil uri
  end

end
