require 'builder'
require 'nokogiri'

require File.expand_path('../error', __FILE__)
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

    def request(method, path, options)
      handle_response( OfficeAutopilot::Request.send(method, path, options) )
    end

    def handle_response(response)
      xml = Nokogiri::XML(response)

      if xml.at_css('result').content =~ /failure/i
        raise OfficeAutopilot::XmlError if xml.at_css('result error').content =~ /Invalid XML/i
      end

      response
    end

  end
end
