The OfficeAutopilot Ruby Gem
============================
A Ruby wrapper for the OfficeAutopilot API

Installation
------------
    gem install office_autopilot

Usage Examples
--------------
    require "rubygems"
    require "office_autopilot"

    oap = OfficeAutopilot::Client.new(:api_id => 'xxx', :api_key => 'yyy')

    # Search Contacts
    puts oap.contacts_search(:field => 'E-Mail', :op => 'e', :value => 'jimbo@example.com')
      => [ { :id => 7, :first_name => 'Jimbo', :last_name => 'Watunusi', :email => 'jimbo@example.com' } ]

Documentation
-------------
[OfficeAutopilot API Docs](http://wiki.sendpepper.com/w/page/19528683/API-Documentation)

Todo
----

* support ALL API calls
* allow returning all possible contact details instead of the current subset

Submitting a Pull Request
-------------------------
1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Add specs for your feature or bug fix.
6. Run <tt>bundle exec rake spec</tt>. If your changes are not 100% covered, go back to step 5.
7. Commit and push your changes.
8. Submit a pull request. Please do not include changes to the gemspec, version, or history file. (If you want to create your own version for some reason, please do so in a separate commit.)

Copyright
---------
Copyright (c) 2011 Prashant Nadarajan.
See [LICENSE](https://github.com/prashantrajan/office_autopilot/blob/master/LICENSE) for details.
