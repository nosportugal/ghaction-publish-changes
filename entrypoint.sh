#!/bin/sh

BRANCH_NAME=$1
GITHUB_TOKEN=$2
GITHUB_ACTOR=$3
GITHUB_REPOSITORY=$4
GITHUB_SHA=$5

# check values
if [ -z "${GITHUB_TOKEN}" ]; then
    echo "error: not found GITHUB_TOKEN"
    exit 1
fi

if [ -z "${BRANCH_NAME}" ]; then
    echo "BRANCH_NAME: ${BRANCH_NAME}"
#   export BRANCH_NAME=master
fi

# initialize git
remote_repo="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git config http.sslVerify false
git config user.name "Automated Publisher"
git config user.email "actions@users.noreply.github.com"
git remote add publisher "${remote_repo}"
git show-ref # useful for debugging
git branch --verbose

# install lfs hooks
git lfs install

# publish any new files
git checkout ${BRANCH_NAME}
git add -A
timestamp=$(date -u)
git commit -m "Automated publish: ${timestamp} ${GITHUB_SHA}" || exit 0
git pull --rebase publisher ${BRANCH_NAME}
git push publisher ${BRANCH_NAME}

# get latest sha after commit
git fetch
echo "::set-output name=latest_sha::$(git rev-parse HEAD)"
