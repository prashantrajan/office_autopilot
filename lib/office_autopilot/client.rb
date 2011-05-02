require 'builder'
require 'nokogiri'


require File.expand_path('../request', __FILE__)
require File.expand_path('../client/contacts', __FILE__)


module OfficeAutopilot
  class Client

    include Contacts

    def initialize(options)
      @api = {
        :api_id => options[:api_id],
        :api_key => options[:api_key]
      }

      raise ArgumentError, "Missing required parameter: api_id" if @api[:api_id].nil?
      raise ArgumentError, "Missing required parameter: api_key" if @api[:api_key].nil?
    end

    def api_id
      @api[:api_id]
    end

    def api_key
      @api[:api_key]
    end

    def auth
      { 'Appid' => api_id, 'Key' => api_key }
    end

    def xml_for_search(options)
      if options.is_a?(Hash)
       options = [ options ]
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


    private

    def request(method, path, options)
      response = OfficeAutopilot::Request.send(method, path, options)
    end

  end
end
