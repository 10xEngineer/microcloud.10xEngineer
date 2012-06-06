require 'spec_helper'
require 'utils/provider'

describe "Dummy Service" do
  before do
    @service = "dummy"
    @dummy = load_provider(@service, File.join(File.dirname(__FILE__), "../providers/#{@service}.rb"))
  end

  it "should have action ping" do
    @dummy.actions.should include("ping")
  end

  it "should return 'Action not defined' for invalid actions" do
    action = "noaction"
    request = build_request(@service, action)

    response = @dummy.fire(action, request)

    response[:status].should == :fail
    response[:options][:reason].should_not be_nil
    response[:options][:reason].should == "Action not defined (#{action})"
  end

  context "exception handling" do
    before do
      @action = "failwhale"
      @message = "Fail of Whale"
      @request = build_request(@service, @action, {"message" => @message})


      @response = @dummy.fire(@action, @request)
    end

    it "should have action :failwhale" do
      @dummy.actions.should include("failwhale")
    end

    it "should fail when exception is raised" do
      @response[:status].should == :fail
    end

    it "should use exception message as a failure reason" do
      @response[:options][:reason].should == @message
    end
  end

  it "should return response :ok" do
    action = "ping"
    request = build_request(@service, action)

    response = @dummy.fire(action, request)

    response[:status].should == :ok
  end
end
