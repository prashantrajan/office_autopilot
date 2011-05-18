module OfficeAutopilot
  class Client
    module Contacts

      CONTACTS_ENDPOINT = '/cdata.php'

      def contacts_search(options)
        xml = xml_for_search(options)
        response = request(:post, CONTACTS_ENDPOINT, :body => {'reqType' => 'search', 'data' => xml})
        parse_contacts_xml(response)
      end

      def contacts_add(options)
        xml = xml_for_contact(options)
        response = request(:post, CONTACTS_ENDPOINT, :body => {'reqType' => 'add', 'return_id' => '1', 'data' => xml})
        parse_contacts_xml(response)[0]
      end

      def contacts_pull_tag
        response = request(:post, CONTACTS_ENDPOINT, :body => {'reqType' => 'pull_tag'})
        parse_xml(response, "tag")
      end

      def contacts_fetch_sequences
        response = request(:post, CONTACTS_ENDPOINT, :body => {'reqType' => 'fetch_sequences'})
        parse_xml(response, "sequence")
      end

      def contacts_key
        response = request(:post, CONTACTS_ENDPOINT, :body => {'reqType' => 'key'})
        parse_contacts_key_xml(response)
      end

      def contacts_fetch(ids)
        xml = xml_for_fetch("contact", ids)
        response = request(:post, CONTACTS_ENDPOINT, :body => {'reqType' => 'fetch', 'data' => xml})
        parse_contacts_xml(response)
      end

      private

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

      def parse_contacts_key_xml(response)
        groups = {}

        xml = Nokogiri::XML(response)
        xml.css('result contact Group_Tag').each do |group_tag|
          group = { 'fields' => {} }
          group['editable'] = group_tag['editable'] == '1'

          group_tag.css('field').each do |field_node|
            field_type = field_node['type']
            field_info = { 'type' => field_type }
            field_info['editable'] = field_node['editable'] == '1'

            case field_type
              when 'tdrop'
                options = []
                field_info['options'] = options
                field_node.css('option').each do |option_node|
                  options << option_node.content
                end
              when 'list'
                list = {}
                field_info['list'] = list
                field_node.css('list').each do |list_node|
                  list[list_node['id']] = list_node.content
                end
            end
            group['fields'][field_node['name']] = field_info
          end
          groups[group_tag['name']] = group
        end
        groups
      end

      def parse_xml(response, element_name)
        result = {}
        xml = Nokogiri::XML(response)
        xml.css("result #{element_name}").each do |node|
          id = node['id']
          result[id] = node.content
        end
        result
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

      def xml_for_fetch(type, ids)
        xml = ""
        ids.each do |id|
          xml << "<#{type}_id>#{id}</#{type}_id>"
        end
        xml
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

    end
  end
end
