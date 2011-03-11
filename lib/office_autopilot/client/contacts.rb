module OfficeAutopilot
  class Client

    module Contacts

      CONTACTS_ENDPOINT = '/cdata.php'

      def contacts_search(options = {})
        xml = xml_for_search(options)
        response = self.class.post(CONTACTS_ENDPOINT, :body => {'reqType' => 'search', 'data' => xml}.merge(auth))

        contacts = []
        xml = Nokogiri::XML(response)
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
    end

  end
end
