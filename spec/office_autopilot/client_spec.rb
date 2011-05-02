require 'spec_helper'

describe OfficeAutopilot::Client do

  describe "#new" do
    before do
      @api_id = 'foo'
      @api_key = 'bar'
    end

    it "initializes the API credentials" do
      client = OfficeAutopilot::Client.new(:api_id => @api_id, :api_key => @api_key)
      client.api_id.should == @api_id
      client.api_key.should == @api_key
      client.auth.should == { 'Appid' => @api_id, 'Key' => @api_key }
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

  describe "#xml_for_search" do
    before do
      @client = OfficeAutopilot::Client.new(:api_id => 'xx', :api_key => 'yy')
    end

    # <search>
    #   <equation>
    #     <field>E-Mail</field>
    #     <op>e</op>
    #     <value>john@example.com</value>
    #   </equation>
    # </search>

    context "searching with one field" do
      it "returns a valid simple search data xml" do
        field = "E-Mail"
        op = "e"
        value = "john@example.com"

        xml = Nokogiri::XML(@client.xml_for_search(:field => field, :op => op, :value => value))
        xml.at_css('field').content.should == field
        xml.at_css('op').content.should == op
        xml.at_css('value').content.should == value
      end
    end

    context "searching with more than one field" do
      it "returns a valid multi search data xml" do
        field = "E-Mail"
        op = "e"
        value = "john@example.com"

        search_options = [
            {:field => 'E-Mail', :op => 'e', :value => 'foo@example.com'},
            {:field => 'Contact Tags', :op => 'n', :value => 'bar'},
        ]

        xml = @client.xml_for_search(search_options)
        xml = Nokogiri::XML(xml)
        xml.css('field')[0].content.should == 'E-Mail'
        xml.css('op')[0].content.should == 'e'
        xml.css('value')[0].content.should == 'foo@example.com'
        xml.css('field')[1].content.should == 'Contact Tags'
        xml.css('op')[1].content.should == 'n'
        xml.css('value')[1].content.should == 'bar'
      end
    end
  end

end
