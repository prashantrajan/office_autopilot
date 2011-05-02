module OfficeAutopilot
  # Custom error class for rescuing from all OfficeAutopilot errors
  class Error < StandardError; end

  # Raised when OfficeAutopilot returns <result>failure<error>Invalid XML</error></result>
  class XmlError < Error; end
end
