#!/bin/sh
set -e

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

if [ "$DEPLOY_KEY_PRIVATE" = "" ]
then
   echo "DEPLOY_KEY_PRIVATE Does not exist"
   exit 1
fi

if [ "$DEPLOY_KEY_PUBLIC" = "" ]
then
   echo "DEPLOY_KEY_PUBLIC Does not exist"
   exit 1
fi

printf "%s" "$DEPLOY_KEY_PRIVATE" > "${HOME}/.ssh/deploy_key"
chmod 600 "${HOME}/.ssh/deploy_key"
wc -c "${HOME}/.ssh/deploy_key"

printf "%s" "$DEPLOY_KEY_PUBLIC" > "${HOME}/.ssh/deploy_key.pub"
chmod 644 "${HOME}/.ssh/deploy_key.pub"
wc -c "${HOME}/.ssh/deploy_key.pub"

echo -e "Host github.com\n\tIdentityFile ~/.ssh/deploy_key\n\tStrictHostKeyChecking no\n\tAddKeysToAgent yes\n" >> "${HOME}/.ssh/config"
chmod 644 "${HOME}/.ssh/config"

eval "$(ssh-agent)"
ssh-add "${HOME}/.ssh/deploy_key"

ssh-keyscan github.com > "${HOME}/.ssh/known_hosts"
chmod 644 "${HOME}/.ssh/known_hosts"
# Debug ssh:
# ssh -Tv git@github.com
echo "set git"
git config --global user.email "$EMAIL"
git config --global user.name "$GITHUB_ACTOR"

cd $GITHUB_WORKSPACE
ls -la "${HOME}/.ssh"
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
