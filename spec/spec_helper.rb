#Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }


require 'office_autopilot'

require 'cgi'
require 'webmock/rspec'


RSpec.configure do |config|
end


def test_data(file_name)
  File.read(File.join(File.dirname(__FILE__), 'data', file_name))
end

def api_endpoint
  'http://api.moon-ray.com'
end

def escape_xml(xml)
  CGI.escape(xml)
end
