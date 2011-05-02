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

  describe "#parse_contacts_xml" do
    context "when the results contain one user" do
      it "returns an array containing the contact" do
        pending
        contacts = @client.parse_contacts_xml( test_data('contacts_search_single_response.xml') )

        contacts.each do |contact|
          contact[:id].should == 7
#          contact[:first_name].should
#          contact[:last_name].should
#          contact[:email].should
        end

#        response = @client.contacts_search(search_params)
#        response.each_with_index do |contact, index|
#          contact[:id].should == xml_contacts[index][:id]
#          contact[:first_name].should == xml_contacts[index][:first_name]
#          contact[:last_name].should == xml_contacts[index][:last_name]
#          contact[:email].should == xml_contacts[index][:email]
#        end
      end
    end

#    context "when the results contain more than one user" do
#      it "returns an array containing the contacts" do
#        search_params = {:field => 'E-Mail', :op => 'c', :value => ''}
#        xml_request = @client.xml_for_search(search_params)
#        xml_response = test_data('contacts_search_multiple_response.xml')
#
#        stub_request(:post, @contact_endpoint).with(
#            :body => "reqType=search&data=#{escape_xml(xml_request)}&#{@auth_str}"
#        ).to_return(:body => xml_response)
#
#        xml_contacts = parse_contacts_xml(xml_response)
#
#        response = @client.contacts_search(search_params)
#        response.each_with_index do |contact, index|
#          contact[:id].should == xml_contacts[index][:id]
#          contact[:first_name].should == xml_contacts[index][:first_name]
#          contact[:last_name].should == xml_contacts[index][:last_name]
#          contact[:email].should == xml_contacts[index][:email]
#        end
#      end
#    end

  end





  describe "#contacts_add" do
    pending "build #parse_xml_contacts"

    it "returns the newly created contact" do
      response = @client.contacts_add([
        { 'Contact Information' => {'First Name' => 'prashant', 'Last Name' => 'nadarajan', 'E-Mail' => 'prashant@example.com'} },
        { 'Lead Information' => {'Contact Owner' => 'Don Corleone'} }
      ])


    end
  end

end
