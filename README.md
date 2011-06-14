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

    client = OfficeAutopilot::Client.new(:api_id => 'xxx', :api_key => 'yyy')

    # Search Contacts
    puts client.contacts_search(:field => 'E-Mail', :op => 'e', :value => 'prashant@example.com')
       # results truncated for brevity but ALL fields (including custom fields) are returned
       => [{"id"=>"7",
             "Contact Information"=>{"First Name"=>"testing", "Last Name"=>"testing", "E-Mail"=>"prashant@example.com"},
            "Lead Information"=>{"Contact Owner"=>"XXX", "First Referrer"=>"", "Last Referrer"=>""},
            "Sequences and Tags"=>{"Sequences"=>"*/*", "Contact Tags"=>""},
            "Purchase History"=>{}
          }]

    # Add Contact
    puts client.contacts_add({ 'Contact Information' => {'First Name' => 'Turtle', 'Last Name' => 'Jones', 'E-Mail' => 'mrturtles@example.com'} })
       => {"id"=>"24", "Contact Information"=>{"First Name"=>"Turtle", "Last Name"=>"Jones", "E-Mail"=>"mrturtles@example.com"}}

Documentation
-------------

###### Currently supported API methods:

**Contacts:**

* contacts_search

* contacts_add

* contacts_pull_tag

* contacts_fetch_sequences

* contacts_key

* contacts_fetch


[OfficeAutopilot API Docs](http://wiki.sendpepper.com/w/page/19528683/API-Documentation)

Todo
----

* support ALL API calls

Submitting a Pull Request
-------------------------
1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Add specs for your feature or bug fix.
6. Run <tt>bundle exec rake spec</tt>. If your changes are not 100% covered, go back to step 5.
7. Commit and push your changes.
8. Submit a pull request. Please do not include changes to the gemspec or version file. (If you want to create your own version for some reason, please do so in a separate commit.)

Copyright
---------
Copyright (c) 2011 Prashant Nadarajan.
See [LICENSE](https://github.com/prashantrajan/office_autopilot/blob/master/LICENSE) for details.
