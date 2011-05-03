module OfficeAutopilot
  class Client
    module Contacts

      CONTACTS_ENDPOINT = '/cdata.php'

      def contacts_search(options)
        xml = xml_for_search(options)
        response = request(:post, CONTACTS_ENDPOINT, :body => {'reqType' => 'search', 'data' => xml}.merge(auth))
        parse_contacts_xml(response)
      end

      def contacts_add(options)
        xml = xml_for_contact(options)
        response = request(:post, CONTACTS_ENDPOINT, :body => {'reqType' => 'add', 'return_id' => '1', 'data' => xml}.merge(auth))
        parse_contacts_xml(response)[0]
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

      def xml_for_contact(options)
        attrs = {}

        id = options.delete('id')
        attrs[:id] = id if id

        xml = Builder::XmlMarkup.new
        xml.contact(attrs) do
          options.each_key do |group_tag|
            xml.Group_Tag(:name => group_tag) do
              options[group_tag].each do |field, value|
                xml.field(value, :name => field)
              end
            end
          end
        end
      end

      def parse_contacts_xml(response)
        contacts = []
        xml = Nokogiri::XML(response)
        xml.css('result contact').each do |node|
          contact = {}
          contact['id'] = node['id']

          node.css('Group_Tag').each do |group_tag|
            group_tag_name = group_tag['name']
            contact[group_tag_name] = {}

            group_tag.css('field').each do |field|
              field_name = field['name']
              contact[group_tag_name][field_name] = field.content
            end
          end
          contacts << contact
        end
        contacts
      end

    end
  end
end
