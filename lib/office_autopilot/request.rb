require 'httparty'

module OfficeAutopilot
  class Request

    include HTTParty
    base_uri 'http://api.moon-ray.com'
    format :plain

  end
end
