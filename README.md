# Ruby on Rails Tutorial: sample application

This is the sample application for
the [*Ruby on Rails Tutorial*](http://railstutorial.org/)
by [Michael Hartl](http://michaelhartl.com/).

# GitHub issue number commit hook instructions

This hook will remind you to add GitHub issue number to every commit. 

Paste the following code into a file called `.git/hooks/commit-msg` in your project's root directory:

    #!/bin/sh
    
    test "" != "$(grep -E '\#[0-9]+' "$1" )" || {
      echo 1>&2 "ERROR: Commit aborted! Missing GitHub issue number."
      exit 1
    }

Remember to make the file executable:

    chmod +x .git/hooks/commit-msg

