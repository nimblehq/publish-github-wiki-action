#!/bin/sh

set -eu

USER_NAME=${INPUT_USER_NAME:-}
USER_EMAIL=${INPUT_USER_EMAIL:-}
USER_ACCESS_TOKEN=${INPUT_USER_ACCESS_TOKEN:-}

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

WIKI_URL="https://${USER_ACCESS_TOKEN}@github.com/${REPOSITORY}.wiki.git"

# Add Safe Directory to initialize sub repo
git config --global --add safe.directory "/github/workspace"
git config --global --add safe.directory "/github/workspace/$TEMP_CLONE_WIKI_FOLDER"

if ! git clone "$WIKI_URL" "$TEMP_CLONE_WIKI_FOLDER"; then
  error "Could not clone the wiki. Create its first page in the Wiki tab, then check that the token can push to this repository."
  exit 1
fi

rsync -av --delete --exclude .git "$WIKI_FOLDER/" "$TEMP_CLONE_WIKI_FOLDER/"

cd "$TEMP_CLONE_WIKI_FOLDER"
git config user.name "$USER_NAME"
git config user.email "$USER_EMAIL"
git add --all

if git diff --cached --quiet; then
  echo "The wiki is already up to date."
else
  git commit -m "$COMMIT_MSG"
  git push origin HEAD
fi

cd ..
rm -rf "$TEMP_CLONE_WIKI_FOLDER"
