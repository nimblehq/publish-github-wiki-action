#!/bin/sh

REPOSITORY=$GITHUB_REPOSITORY
WIKI_FOLDER=".github/wiki"
TEMP_CLONE_WIKI_FOLDER="tmp_wiki"
COMMIT_MSG="Update Wiki content"

function error() {
  echo "::error::$1"
}

function add_mask() {
  echo "::add-mask::$1"
}

if [ -z "$USER_NAME" ]; then
  error "USER_NAME environment variable is not set"
  exit 1
fi

if [ -z "$USER_EMAIL" ]; then
  error "USER_EMAIL environment variable is not set"
  exit 1
fi

if [ -z "$USER_ACCESS_TOKEN" ]; then
  error "USER_ACCESS_TOKEN environment variable is not set"
  exit 1
fi

add_mask "${USER_ACCESS_TOKEN}"

# This step will
# - Create folder named `tmp_wiki`
# - Initialize Git
# - Pull old Wiki content
{
  mkdir $TEMP_CLONE_WIKI_FOLDER
  cd $TEMP_CLONE_WIKI_FOLDER || exit 1
  git init
  git config user.name $USER_NAME
  git config user.email $USER_EMAIL
  git pull https://$USER_ACCESS_TOKEN@github.com/$REPOSITORY.wiki.git
  cd ..
} || exit 1

# This step will
# - Synchronize differences between `.github/wiki/` & `tmp_wiki`
# - Push new Wiki content
{
  rsync -av --delete $WIKI_FOLDER/ $TEMP_CLONE_WIKI_FOLDER/ --exclude .git
  cd $TEMP_CLONE_WIKI_FOLDER
  git add .
  git commit -m "$COMMIT_MSG"
  git push -f --set-upstream https://$USER_ACCESS_TOKEN@github.com/$REPOSITORY.wiki.git master
  cd ..
} || exit 1

rm -rf "$TEMP_CLONE_WIKI_FOLDER"
exit 0
