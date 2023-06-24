#!/bin/bash

# Checks if git is installed; if not, it ends execution.
if ! command -v git &>/dev/null; then
    echo "Git is not installed. Please install Git and try again."
    exit 1
fi

# Checks if current directory is not inside a Git Repository.
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    CLONED_REPO="cloned_repo_$(date +'%d-%m-%Y_%H-%M-%S')"
    
    while true; do
        read -p "Enter the repository URL: " REPO_URL
        echo -e "\n"

        git clone $REPO_URL $CLONED_REPO

        if [ $? -ne 0 ]; then
            echo -e "Something went wrong; try again or provide a new repository address.\n"
            continue
        fi

        break
    done

    cd $CLONED_REPO
fi

if ! [ -d "commits" ]; then
    echo -e "\n"

    # Get the list of commit hashes.
    COMMITS=$(git rev-list --all)

    # Loop through each commit.
    for commit in $COMMITS; do
        # Get the commit's information.
        commit_message=$(git show -s --format=%s $commit)
        committer_date=$(git show -s --format=%cd $commit)
        committer_name=$(git show -s --format=%cn $commit)
        committer_mail=$(git show -s --format=%ce $commit)
        author_date=$(git show -s --format=%ad $commit)
        author_name=$(git show -s --format=%an $commit)
        author_mail=$(git show -s --format=%ae $commit)

        # Create a folder for the commit.
        commit_dir=commits/$(git show -s --format=%cd --date=format:"%Y-%m-%d_%H-%M-%S" $commit)
        mkdir -p "$commit_dir"

        # Copy the files from the commit to the commit directory.
        git --work-tree="$commit_dir" checkout $commit -- .

        # Create the commit message file with the commit message as the file content.
        echo -e "$committer_date\n$committer_name\n$committer_mail\n$author_date\n$author_name\n$author_mail\n$commit_message" > "$commit_dir/commit.txt"
        
        echo "Created $commit_dir"
    done

    echo -e "\nRepository cloned and split into each commit inside the 'commits' folder."
    echo -e "Commit date and message were saved as text files.\n"

    while true; do
        echo "Any changes to the individual commits must be done now."
        read -p "Do you want to continue? (Y/N) " CHOICE

        # Checks for lower- and upper-cases using regex.
        if [[ "$CHOICE" =~ ^[Yy]$ ]]; then
            break
        elif [[ "$CHOICE" =~ ^[Nn]$ ]]; then
            echo "Stopping execution."
            exit 0
        else
            echo "Invalid choice. Please enter Y or N."
        fi
    done
fi

if ! [ -d "commits" ]; then
    echo -e "\nDid you delete the \"commits\" folder? Execution has been aborted."
    exit 1
fi

while true; do
    echo -e "\n"
    read -p "Create new repository (1) or supply existing remote repository (2)? (1/2) " CHOICE

    if [ "$CHOICE" == "1" ]; then
        while true; do
            read -p "Enter the name for the new repository: " REPO_NAME

            if [[ -z $REPO_NAME ]]; then
                echo "Error: Repository name cannot be empty"
                continue
            fi

            if [[ -d $REPO_NAME ]]; then
                echo "Error: Directory '$REPO_NAME' already exists"
                continue
            fi

            break
        done

        mkdir "$REPO_NAME"

        cd "$REPO_NAME"

        git init

        echo "Sucessfully initiated the repository."
        break
    elif [ "$CHOICE" == "2" ]; then
        while true; do
            read -p "Enter the repository URL: " REPO_URL

            git clone $REPO_URL $CLONED_REPO

            if [ $? -ne 0 ]; then
                echo -e "Something went wrong; try again or provide a new repository address.\n"
                continue
            fi

            break
        done

        cd $CLONED_REPO

        echo "Sucessfully cloned the repository."
        break
    else
        echo "Invalid choice. Please enter 1 or 2."
    fi
done

while true; do
    echo -e "\n"
    read -p "Keep original commit info (1) or create everything as new (2)? (1/2) " CHOICE

    if [ "$CHOICE" == "1" ] || [ "$CHOICE" == "2" ]; then
        break
    else
        echo "Invalid choice. Please enter 1 or 2."
    fi
done

if ! [ -d "../commits" ]; then
    echo -e "\nThe 'commits' folder has since been deleted; aborting execution."
    exit 1
fi

echo -e "\n"

# Iterates over all folders inside commits, whilst ignoring everything else.
for folder in "../commits"/*; do
    if [ -d "$folder" ]; then
        echo "Commiting: $folder"

        # Moves from the current commit folder to the new repository's directory.
        mv -f "$folder"/* "$(pwd)"

        mapfile arr < commit.txt

        # Splits the array data into commit_date and commit_msg
        committer_date=${arr[0]}
        committer_name=${arr[1]}
        committer_mail=${arr[2]}
        author_date=${arr[3]}
        author_name=${arr[4]}
        author_mail=${arr[5]}
        commit_msg=$(echo "${arr[*]:6}" | sed 's/^ *//')

        rm commit.txt

        git add .

        if [ "$CHOICE" == "1" ]; then
            GIT_COMMITTER_DATE="$committer_date" GIT_COMMITTER_NAME="$committer_name" GIT_COMMITTER_EMAIL="$committer_mail" \
            git commit -m "$commit_msg" --date="$author_date" --author="$author_name <$author_mail>" 
        elif [ "$CHOICE" == "2" ]; then
            git commit -m "$commit_msg"
        fi  
    fi
done

echo -e "\nThe repository is ready! Check it before using \"git push\" manually."

# Prompt the user to press a key before exiting.
read -n 1 -s -r -p "Press any key to exit..."