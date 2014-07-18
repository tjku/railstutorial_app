== README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.

GitHub issue number commit hook instructions
==============

This hook will remind you to add GitHub issue number to every commit. 

Paste the following code into a file called `.git/hooks/commit-msg` in your project's root directory:

    #!/bin/sh
    
    test "" != "$(grep -E '\#[0-9]+' "$1" )" || {
      echo 1>&2 "ERROR: Commit aborted! Missing GitHub issue number."
      exit 1
    }

Remember to make the file executable:

    chmod +x .git/hooks/commit-msg

