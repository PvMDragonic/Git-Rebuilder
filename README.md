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

### Commit information
Each commit's information is saved to a `commit.txt` file inside the individual commit folder. Inside this text file, each row represents the following:

| Row | Description    |
|-----|:--------------:|
| 1st | committer_date |
| 2nd | committer_name |
| 3rd | committer_mail |
| 4th | author_date    |
| 5th | author_name    |
| 6th | author_mail    |
| ... | commit_message |

You can freely tamper with them, but remember to keep them compatible with Git, as the script won't try to correct them and will just assume they to be correct.