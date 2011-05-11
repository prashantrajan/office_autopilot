require 'spec_helper'

describe OfficeAutopilot::Client::Contacts do

  before do
    @contact_endpoint = "#{api_endpoint}/cdata.php"
    @client = OfficeAutopilot::Client.new(:api_id => 'xxx', :api_key => 'xxx')
    @auth_str = "Appid=#{@client.api_id}&Key=#{@client.api_key}"
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

        xml = Nokogiri::XML(@client.xml_for_search(:field => field, :op => op, :value => value))
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

  describe "#contacts_search" do
    it "returns the matched contacts" do
      search_options = {:field => 'E-Mail', :op => 'e', :value => 'prashant@example.com'}
      search_xml = @client.xml_for_search(search_options)
      contacts_xml = test_data('contacts_search_single_response.xml')

      request_body = "reqType=search&data=#{escape_xml(search_xml)}&#{@auth_str}"
      stub_request(:post, @contact_endpoint).with(:body => request_body).to_return(:body => contacts_xml)

      contacts = @client.contacts_search(search_options)
      WebMock.should have_requested(:post, @contact_endpoint).with(:body => request_body)
      contacts.should == @client.parse_contacts_xml(contacts_xml)
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
      xml = @client.xml_for_contact(@contact_options)
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
        xml = Nokogiri::XML( @client.xml_for_contact(@contact_options) )

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
        contacts = @client.parse_contacts_xml( test_data('contacts_search_single_response.xml') )

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
        contacts = @client.parse_contacts_xml(test_data('contacts_search_multiple_response.xml'))

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

      request_contact_xml = @client.xml_for_contact(contact_options)
      response_contact_xml = test_data('contacts_add_response.xml')

      request_body = "reqType=add&return_id=1&data=#{escape_xml(request_contact_xml)}&#{@auth_str}"
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

  describe "#contacts_pull_tags" do
    it "returns all the contact tag names and ids" do
      pull_tags_xml = test_data('contacts_pull_tags.xml')
      request_body = "reqType=pull_tag&#{@auth_str}"
      stub_request(:post, @contact_endpoint).with(:body => request_body).to_return(:body => pull_tags_xml)

      tags = @client.contacts_pull_tags
      tags['3'].should == 'newleads'
      tags['4'].should == 'old_leads'
      tags['5'].should == 'legacy Leads'
    end
  end

end
