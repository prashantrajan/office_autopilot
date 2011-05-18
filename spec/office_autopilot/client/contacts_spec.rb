require 'spec_helper'

describe OfficeAutopilot::Client::Contacts do

  before do
    @contact_endpoint = "#{api_endpoint}/cdata.php"
    @client = OfficeAutopilot::Client.new(:api_id => 'xxx', :api_key => 'xxx')
    @auth_str = "Appid=#{@client.api_id}&Key=#{@client.api_key}"
  end

  def request_body(req_type, options = {})
    options = { 'reqType' => req_type }.merge(options)

    query = ''
    options.each do |key, value|
      if key == "data"
        value = escape_xml(value)
      end
      query << "#{key}=#{value}&"
    end
    query << @auth_str
  end

  describe "#xml_for_search" do
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

        xml = Nokogiri::XML(@client.send(:xml_for_search, { :field => field, :op => op, :value => value }) )
        xml.at_css('field').content.should == field
        xml.at_css('op').content.should == op
        xml.at_css('value').content.should == value
      end
    end

    context "searching with more than one field" do
      it "returns a valid multi search data xml" do
        search_options = [
          {:field => 'E-Mail', :op => 'e', :value => 'foo@example.com'},
          {:field => 'Contact Tags', :op => 'n', :value => 'bar'},
        ]

        xml = @client.send(:xml_for_search, search_options)
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

  describe "#contacts_search" do
    it "returns the matched contacts" do
      search_options = {:field => 'E-Mail', :op => 'e', :value => 'prashant@example.com'}
      search_xml = @client.send(:xml_for_search, search_options)
      contacts_xml = test_data('contacts_search_single_response.xml')
      
      request_body = request_body('search', 'data' => search_xml)
      stub_request(:post, @contact_endpoint).with(:body => request_body).to_return(:body => contacts_xml)

      contacts = @client.contacts_search(search_options)
      WebMock.should have_requested(:post, @contact_endpoint).with(:body => request_body)
      contacts.should == @client.send(:parse_contacts_xml, contacts_xml)
    end
  end

  describe "#xml_for_contact" do
    before do
      @contact_options = {
        'Contact Information' => {'First Name' => 'Bob', 'Last Name' => 'Foo', 'E-Mail' => 'b@example.com'},
        'Lead Information' => {'Contact Owner' => 'Mr Bar'}
      }
    end

    it "returns a valid contacts xml" do
      xml = @client.send(:xml_for_contact, @contact_options)
      xml = Nokogiri::XML(xml)

      xml.at_css('contact')['id'].should be_nil

      contact_info = xml.css("contact Group_Tag[name='Contact Information']")
      contact_info.at_css("field[name='First Name']").content.should == 'Bob'
      contact_info.at_css("field[name='Last Name']").content.should == 'Foo'

      lead_info = xml.css("contact Group_Tag[name='Lead Information']")
      lead_info.at_css("field[name='Contact Owner']").content.should == 'Mr Bar'
    end

    context "when 'id' is specified" do
      it "returns a valid contact xml containing the contact id" do
        @contact_options.merge!('id' => '1234')
        xml = Nokogiri::XML( @client.send(:xml_for_contact, @contact_options) )

        xml.at_css('contact')['id'].should == '1234'
        contact_info = xml.css("contact Group_Tag[name='Contact Information']")
        contact_info.at_css("field[name='First Name']").content.should == 'Bob'
        contact_info.at_css("field[name='Last Name']").content.should == 'Foo'

        lead_info = xml.css("contact Group_Tag[name='Lead Information']")
        lead_info.at_css("field[name='Contact Owner']").content.should == 'Mr Bar'
      end
    end
  end

  describe "#parse_contacts_xml" do
    context "when the results contain one contact" do
      it "returns an array containing the contact" do
        contacts = @client.send(:parse_contacts_xml, test_data('contacts_search_single_response.xml'))

        contacts.size.should == 1

        contacts.each do |contact|
          contact['id'].should == '7'
          contact['Contact Information']['First Name'].should == 'prashant'
          contact['Contact Information']['Last Name'].should == 'nadarajan'
          contact['Contact Information']['E-Mail'].should == 'prashant@example.com'
          contact['Lead Information']['Contact Owner'].should == 'Don Corleone'
        end
      end
    end

    context "when the results contain more than one contact" do
      it "returns an array containing the contacts" do
        contacts = @client.send(:parse_contacts_xml, test_data('contacts_search_multiple_response.xml'))

        contacts.size.should == 3

        contacts[0]['id'].should == '8'
        contacts[0]['Contact Information']['E-Mail'].should == 'bobby@example.com'
        contacts[0]['Lead Information']['Contact Owner'].should == 'Jimbo Watunusi'

        contacts[1]['id'].should == '5'
        contacts[1]['Contact Information']['E-Mail'].should == 'ali@example.com'
        contacts[1]['Lead Information']['Contact Owner'].should == 'Jimbo Watunusi'
      end
    end
  end

  describe "#contacts_add" do
    it "returns the newly created contact" do
      contact_options = {
        'Contact Information' => {'First Name' => 'prashant', 'Last Name' => 'nadarajan', 'E-Mail' => 'prashant@example.com'},
        'Lead Information' => {'Contact Owner' => 'Don Corleone'}
      }

      request_contact_xml = @client.send(:xml_for_contact, contact_options)
      response_contact_xml = test_data('contacts_add_response.xml')

      request_body = request_body('add', 'return_id' => '1', 'data' => request_contact_xml)
      stub_request(:post, @contact_endpoint).with(:body => request_body).to_return(:body => response_contact_xml)

      contact = @client.contacts_add(contact_options)
      WebMock.should have_requested(:post, @contact_endpoint).with(:body => request_body)

      contact['id'].should == '7'
      contact['Contact Information']['First Name'].should == 'prashant'
      contact['Contact Information']['Last Name'].should == 'nadarajan'
      contact['Contact Information']['E-Mail'].should == 'prashant@example.com'
      contact['Lead Information']['Contact Owner'].should == 'Don Corleone'
    end
  end

  describe "#contacts_pull_tag" do
    it "returns all the contact tag names and ids" do
      pull_tags_xml = test_data('contacts_pull_tags.xml')
      stub_request(:post, @contact_endpoint).with(:body => request_body('pull_tag')).to_return(:body => pull_tags_xml)

      tags = @client.contacts_pull_tag
      tags['3'].should == 'newleads'
      tags['4'].should == 'old_leads'
      tags['5'].should == 'legacy Leads'
    end
  end

  describe "#contacts_fetch_sequences" do
    it "returns all the available contact sequences" do
      xml = test_data('contacts_fetch_sequences.xml')
      stub_request(:post, @contact_endpoint).with(:body => request_body('fetch_sequences')).to_return(:body => xml)
      sequences = @client.contacts_fetch_sequences
      sequences['3'].should == 'APPOINTMENT REMINDER'
      sequences['4'].should == 'foo sequence'
    end
  end

  describe "#contacts_key" do
    it "returns information on the contact data structure" do
      xml = test_data('contacts_key_type.xml')
      stub_request(:post, @contact_endpoint).with(:body => request_body('key')).to_return(:body => xml)

      result = @client.contacts_key
      result["Contact Information"]["editable"].should be_false
      result["Contact Information"]["fields"]["Cell Phone"]["editable"].should be_false
      result["Contact Information"]["fields"]["Cell Phone"]["type"].should == "phone"
      result["Contact Information"]["fields"]["Birthday"]["type"].should == "fulldate"

      result["Lead Information"]["fields"]["Lead Source"]["type"].should == "tdrop"
      result["Lead Information"]["fields"]["Lead Source"]["options"][0].should == "Adwords"
      result["Lead Information"]["fields"]["Lead Source"]["options"][4].should == "Newspaper Ad"

      result["Sequences and Tags"]["fields"]["Contact Tags"]["type"].should == "list"
      result["Sequences and Tags"]["fields"]["Contact Tags"]["list"]["5"].should == "legacy Leads"

      result["PrecisoPro"]["editable"].should be_true
      result["PrecisoPro"]["fields"]["Lead Status"]["editable"].should be_true
    end
  end

  describe "#contacts_fetch" do
    context "when all the ids exists" do
      it "returns the contacts" do
        xml_response = test_data('contacts_search_multiple_response.xml')
        xml_request = "<contact_id>8</contact_id><contact_id>5</contact_id><contact_id>7</contact_id>"
        stub_request(:post, @contact_endpoint).with(:body => request_body('fetch', 'data' => xml_request )).to_return(:body => xml_response)

        results = @client.contacts_fetch([8, 5, 7])
        results.size.should == 3
        results[0]["Contact Information"].should_not be_nil
      end
    end

    context "when some of the ids don't exist"

    context "when all the ids don't exist"
  end
end
