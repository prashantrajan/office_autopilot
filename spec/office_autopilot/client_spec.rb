require 'spec_helper'

describe OfficeAutopilot::Client do

  before do
    @api_id = 'foo'
    @api_key = 'bar'
    @client = OfficeAutopilot::Client.new(:api_id => @api_id, :api_key => @api_key)
  end

  describe "#new" do
    it "initializes the API credentials" do
      @client.api_id.should == @api_id
      @client.api_key.should == @api_key
      @client.auth.should == { 'Appid' => @api_id, 'Key' => @api_key }
    end

    it "raises an ArgumentError when api_id is not provided" do
      expect {
        OfficeAutopilot::Client.new(:api_key => 'foo')
      }.to raise_error(ArgumentError)
    end

    it "raises an ArgumentError when api_key is not provided" do
      expect {
        OfficeAutopilot::Client.new(:api_id => 'foo')
      }.to raise_error(ArgumentError)
    end
  end

  describe "#request" do
    pending "can't seem to stub out OfficeAutopilot::Request.post"
  end

  describe "#handle_response" do
    context "when there are no errors" do
      it "returns the response verbatim" do
        response = '<result>Success</result>'
        @client.handle_response(response).should == response
      end
    end

    context "invalid XML error" do
      it "raises OfficeAutopilot::XmlError" do
        expect {
            @client.handle_response( test_data('invalid_xml_error_response.xml') )
        }.to raise_error(OfficeAutopilot::XmlError)
      end
    end
  end

end
