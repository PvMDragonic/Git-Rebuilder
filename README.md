# Git-Rebuilder
A Shell script to automate manually recreating a Git Repository.

## About
Sometimes it's just easier to start over than to try and do everything with rebase whenever you need to alter tons of past commits from any given repository. Thus, I did a little something to automate the worst part about a repo surgery—having to split each commit and keep tabs of their original messages and such. As a bonus, I've also made so it'll re-commit everything after you're done meddling with the commits.

## Usage
Either pop it inside a Repository directory or feed it an URL for remote cloning. 

After cloning and splitting each commit, it'll prompt the user to make their changes.

Then, it'll ask whether to init a new Repository or to clone a new remote one.

Lastly, it'll ask about keeping or not the old commit information (dates, emails and names).

After that, it'll commit everything and leave the new Repository ready for a push.