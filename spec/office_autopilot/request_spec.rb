require 'spec_helper'

describe OfficeAutopilot::Request do

  describe "HTTParty" do
    it "sets the base uri to the Office Autopilot API host" do
      OfficeAutopilot::Request.base_uri.should == 'http://api.moon-ray.com'
    end

    it "set the format to :plain" do
      OfficeAutopilot::Request.format.should == :plain
    end
  end

end
