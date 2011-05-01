require 'spec_helper'

describe OfficeAutopilot::Client::Contacts do

  before do
    @contact_endpoint = "#{api_endpoint}/cdata.php"
    @client = OfficeAutopilot::Client.new(:api_id => 'xxx', :api_key => 'xxx')
    @auth_str = "Appid=#{@client.api_id}&Key=#{@client.api_key}"
  end

  def parse_contacts_xml(xml)
    contacts = []
    xml = Nokogiri::XML(xml)
    xml.css('result contact').each do |node|
      contacts << {
          :id => node['id'].to_i,
          :first_name => node.at_css("Group_Tag[name='Contact Information'] field[name='First Name']").text,
          :last_name => node.at_css("Group_Tag[name='Contact Information'] field[name='Last Name']").text,
          :email => node.at_css("Group_Tag[name='Contact Information'] field[name='E-Mail']").text
      }
    end
    contacts
  end

  describe "#contacts_search" do
    context "when the results contain one user" do
      it "returns an array containing the contact" do
        search_params = {:field => 'E-Mail', :op => 'e', :value => 'prashant@example.com'}
        xml_request = @client.xml_for_search(search_params)
        xml_response = test_data('contacts_search_single_response.xml')

        stub_request(:post, @contact_endpoint).with(
            :body => "reqType=search&data=#{escape_xml(xml_request)}&#{@auth_str}"
        ).to_return(:body => xml_response)

        xml_contacts = parse_contacts_xml(xml_response)

        response = @client.contacts_search(search_params)
        response.each_with_index do |contact, index|
          contact[:id].should == xml_contacts[index][:id]
          contact[:first_name].should == xml_contacts[index][:first_name]
          contact[:last_name].should == xml_contacts[index][:last_name]
          contact[:email].should == xml_contacts[index][:email]
        end
      end
    end

    context "when the results contain more than one user" do
      it "returns an array containing the contacts" do
        search_params = {:field => 'E-Mail', :op => 'c', :value => ''}
        xml_request = @client.xml_for_search(search_params)
        xml_response = test_data('contacts_search_multiple_response.xml')

        stub_request(:post, @contact_endpoint).with(
            :body => "reqType=search&data=#{escape_xml(xml_request)}&#{@auth_str}"
        ).to_return(:body => xml_response)

        xml_contacts = parse_contacts_xml(xml_response)

        response = @client.contacts_search(search_params)
        response.each_with_index do |contact, index|
          contact[:id].should == xml_contacts[index][:id]
          contact[:first_name].should == xml_contacts[index][:first_name]
          contact[:last_name].should == xml_contacts[index][:last_name]
          contact[:email].should == xml_contacts[index][:email]
        end
      end
    end
  end

  describe "#xml_for_contact" do
    it "returns a valid contacts xml" do
      xml = @client.xml_for_contact([
        { 'Contact Information' => {'First Name' => 'Bob', 'Last Name' => 'Foo', 'E-Mail' => 'b@example.com'} },
        { 'Lead Information' => {'Contact Owner' => 'Mr Bar'} }
      ])

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
        xml = Nokogiri::XML(@client.xml_for_contact([], 1234))
        xml.at_css('contact')['id'].should == '1234'
      end
    end
  end

  describe "#contacts_add" do

    context "when success" do
      it "does not raise an error"

      context "when additional option :returns is specified" do
        it "returns the created contact"
      end

      context "when additional option 'return_id' is specified" do
        it "returns the created contact"
      end
    end

    context "when failure" do
      pending
    end

  end

end
