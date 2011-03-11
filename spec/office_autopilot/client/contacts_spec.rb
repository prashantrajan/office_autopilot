require 'spec_helper'

describe OfficeAutopilot::Client::Contacts do

  before do
    @contact_endpoint = "#{api_endpoint}/cdata.php"
    @client = OfficeAutopilot::Client.new(:api_id => 'xxx', :api_key => 'xxx')
    @auth_str = "Appid=#{@client.api_id}&Key=#{@client.api_key}"
  end

  def parse_xml_contacts(xml)
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
        search_params = {:field => 'E-Mail', :op => 'c', :value => ''}
        xml_request = @client.xml_for_search(search_params)
        xml_response = test_data('contacts_search_single_response.xml')

        stub_request(:post, @contact_endpoint).with(
            :body => "reqType=search&data=#{escape_xml(xml_request)}&#{@auth_str}"
        ).to_return(:body => xml_response)

        xml_contacts = parse_xml_contacts(xml_response)

        response = @client.contacts_search(search_params)
        response.each_with_index do |contact, index|
          contact[:id].should == xml_contacts[index][:id]
          contact[:first_name].should == xml_contacts[index][:first_name]
          contact[:last_name].should == xml_contacts[index][:last_name]
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

        xml_contacts = parse_xml_contacts(xml_response)

        response = @client.contacts_search(search_params)
        response.each_with_index do |contact, index|
          contact[:id].should == xml_contacts[index][:id]
          contact[:first_name].should == xml_contacts[index][:first_name]
          contact[:last_name].should == xml_contacts[index][:last_name]
        end
      end
    end
  end

end
