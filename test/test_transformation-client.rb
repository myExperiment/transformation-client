require 'helper'

class TestTransformationClient < Test::Unit::TestCase

  SERVICE_URI = "http://sandbox.wf4ever-project.org/wf-ro/jobs"
  T2FLOW_FORMAT = "application/vnd.taverna.t2flow+xml"
  OAUTH_TOKEN = "47d5423c-b507-4e1c-8"
  RESOURCE = "http://www.myexperiment.org/workflows/2470/download/_untitled__947103.t2flow?version=2"
  RO = "http://sandbox.wf4ever-project.org/rodl/ROs/FinnsTest/"

  def test_can_create
    @uri = Wf4Ever::TransformationClient.create_job(SERVICE_URI, RESOURCE, T2FLOW_FORMAT, RO, OAUTH_TOKEN)
    assert_not_nil @uri
    status = Wf4Ever::TransformationClient.check_job(@uri)
    #puts status
    assert_equal(RESOURCE, status["resource"])
    assert_equal(T2FLOW_FORMAT, status["format"])
    assert_equal(RO, status["ro"])
    # :ro default should become 'main'
    assert_equal(RO, status["extract"]["main"])
    ## The remaining folders should not be listed
    assert_nil(status["extract"]["nested"])
    assert_nil(status["extract"]["scripts"])
    assert_nil(status["extract"]["services"])
  end

  def setup
      @uri = nil
  end

  def teardown
    Wf4Ever::TransformationClient.cancel_job(@uri) if @uri
  end

  def test_with_extract
    extract = {:nested => RO + "folderNested", :scripts => :ro, :main => RO + "folderMain"} 
    @uri = Wf4Ever::TransformationClient.create_job(SERVICE_URI, RESOURCE, T2FLOW_FORMAT, RO, OAUTH_TOKEN, extract)
    assert_not_nil @uri
    status = Wf4Ever::TransformationClient.check_job(@uri)
#    puts status
    assert_equal(RESOURCE, status["resource"])
    assert_equal(T2FLOW_FORMAT, status["format"])
    assert_equal(RO, status["ro"])
    assert_equal(RO + "folderMain", status["extract"]["main"])
    assert_equal(RO + "folderNested", status["extract"]["nested"])
    assert_equal(RO, status["extract"]["scripts"])
    assert_nil(status["extract"]["services"])
  end

end
