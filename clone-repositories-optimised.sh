#!/bin/bash

REPO_LIST="repositories.txt"
echo "started processing"

# where to clone and create directory if not exists
BASE_DIR="cloned_repos"
mkdir -p $BASE_DIR

# read the file with repositories line by line and perform sparse checkout
while IFS= read -r REPO_URL; do
  REPO_NAME=$(basename "$REPO_URL" .git)
  REPO_DIR="$BASE_DIR/$REPO_NAME"

  # check if repository was already clonned earlier
  if [ -d "$REPO_DIR/.git" ]; then
    echo "repository $REPO_NAME already cloned, do nothing"
    continue
  fi

  echo "cloning repository $REPO_URL into $REPO_DIR"

  # create a directory for the repository
  mkdir -p $REPO_DIR
  cd $REPO_DIR
  git init

  # enable sparse checkout
  git config core.sparseCheckout true

  # define sparse checkout rules - only go files and files related to licensing
  # save this information to git file
  cat <<EOL > .git/info/sparse-checkout
*.go
LICENSE
NOTICE
licenses/
notices/
EOL

  # add the remote repository
  git remote add origin $REPO_URL

  # fetch without history
  # rollback everything if there is error
  # this is needed to skip invalid repos without failing all the script
  git fetch --depth=1 origin
  if [ $? -ne 0 ]; then
    echo "error failed to fetch from $REPO_URL"
    cd -
    rm -rf $REPO_DIR
    continue
  fi
  
  # get the name of the default branch to avoid error
  # some repos may have master as default branch and some main
  # rollback everything if there is error
  DEFAULT_BRANCH=$(git remote show origin | awk '/HEAD branch/ {print $NF}')
  if [ $? -ne 0 ]; then
    echo "Error failed to determine default branch for $REPO_URL"
    cd -
    rm -rf $REPO_DIR
    continue
  fi

  # perform a shallow fetch with sparse checkout of the default branch
  # rollback everything if there is error
  git pull --depth=1 origin $DEFAULT_BRANCH
  if [ $? -ne 0 ]; then
    echo "Error failed to pull $DEFAULT_BRANCH from $REPO_URL"
    cd -
    rm -rf $REPO_DIR
    continue
  fi

  # return to the base directory
  cd -

  echo "finished cloning repository $REPO_URL"
done < "$REPO_LIST"

echo "all repositories have been cloned"