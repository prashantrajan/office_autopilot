module OfficeAutopilot
  class Client

    module Contacts

      CONTACTS_ENDPOINT = '/cdata.php'

      def contacts_search(options = {})
        xml = xml_for_search(options)
        response = request(:post, CONTACTS_ENDPOINT, :body => {'reqType' => 'search', 'data' => xml}.merge(auth))

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

      def xml_for_search(options)
        if options.is_a?(Hash)
          options = [options]
        end

        xml = Builder::XmlMarkup.new
        xml.search do
          options.each do |option|
            xml.equation do
              xml.field option[:field]
              xml.op option[:op]
              xml.value option[:value]
            end
          end
        end
      end

      def xml_for_contact(nodes, id = nil)
        attrs = id ? {:id => id} : {}

        xml = Builder::XmlMarkup.new
        xml.contact(attrs) do
          nodes.each do |node|
            node.each do |group_tag, fields|
              xml.Group_Tag(:name => group_tag) do
                fields.each do |k, v|
                  xml.field(v, :name => k)
                end
              end
            end
          end
        end
      end

      def parse_contacts_xml(response)
        # TODO
        contacts = []
        contacts
      end

    end

  end
end
