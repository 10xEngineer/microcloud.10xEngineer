require 'spec_helper'
require 'utils/provider'

describe "Service Provider" do
  context "" do
    before do
      @provider_name = "dummy"
      @provider = load_provider(@provider_name, File.join(File.dirname(__FILE__), "../providers/#{@provider_name}.rb"))
    end

    it "should load correct provider" do
      @provider.name.should == "dummy"
    end

    it "should keep reference of all loaded providers" do
      provider = Provider.get(@provider_name)
      provider.should_not be_nil
      provider.name.should == @provider_name
    end
  end
end
