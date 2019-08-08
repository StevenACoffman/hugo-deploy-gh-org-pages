#!/bin/sh
set -e

echo "set git"
git config --global user.email "$EMAIL"
git config --global user.name "$GITHUB_ACTOR"


mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

printf "%s" "$DEPLOY_KEY_PRIVATE" > "${HOME}/.ssh/id_rsa"
chmod 600 "${HOME}/.ssh/id_rsa"

echo "Host github.com\n\tStrictHostKeyChecking no\n" >> "${HOME}/.ssh/config"
chmod 644 "${HOME}/.ssh/config"

cd $GITHUB_WORKSPACE
ls -la
printf "\033[0;32mSubmodule Safety Engaged...\033[0m\n"
git submodule sync --recursive && git submodule update --init --recursive
printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"


hugo

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master
printf "\033[0;32mDone for now\033[0m\n"
