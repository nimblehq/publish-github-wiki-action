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

# Send the token as a header, as actions/checkout does, so git never writes it to .git/config.
# GITHUB_TOKEN works only with the x-access-token user name. A personal token accepts any user name.
BASIC_CREDENTIAL=$(printf 'x-access-token:%s' "$USER_ACCESS_TOKEN" | base64 | tr -d '\n')
add_mask "${BASIC_CREDENTIAL}"
AUTH_HEADER="AUTHORIZATION: basic ${BASIC_CREDENTIAL}"
WIKI_URL="https://github.com/${REPOSITORY}.wiki.git"

trap 'rm -rf "$TEMP_CLONE_WIKI_FOLDER"' EXIT

# Add Safe Directory to initialize sub repo
git config --global --add safe.directory "/github/workspace"
git config --global --add safe.directory "/github/workspace/$TEMP_CLONE_WIKI_FOLDER"

if ! git -c http.extraheader="$AUTH_HEADER" clone "$WIKI_URL" "$TEMP_CLONE_WIKI_FOLDER"; then
  error "Could not clone the wiki. Create its first page in the Wiki tab, then check that the token can read this repository."
  exit 1
fi

rsync -av --delete --exclude .git "$WIKI_FOLDER/" "$TEMP_CLONE_WIKI_FOLDER/"

git -C "$TEMP_CLONE_WIKI_FOLDER" config user.name "$USER_NAME"
git -C "$TEMP_CLONE_WIKI_FOLDER" config user.email "$USER_EMAIL"
git -C "$TEMP_CLONE_WIKI_FOLDER" add --all

if git -C "$TEMP_CLONE_WIKI_FOLDER" diff --cached --quiet; then
  echo "The wiki is already up to date."
else
  git -C "$TEMP_CLONE_WIKI_FOLDER" commit -m "$COMMIT_MSG"
  if ! git -C "$TEMP_CLONE_WIKI_FOLDER" -c http.extraheader="$AUTH_HEADER" push origin HEAD; then
    error "Could not push to the wiki. With the default GITHUB_TOKEN, the job needs the permission contents: write. A fine-grained personal token may not be able to push to a wiki, so use the default token or a classic token with the repo scope."
    exit 1
  fi
fi
