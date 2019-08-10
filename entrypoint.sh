#!/bin/sh
set -e
# HOME=/github/workspace
SSH_PATH="/root/.ssh"
KEY_FILENAME="id_rsa"
mkdir -p "${SSH_PATH}"
chmod 700 "${SSH_PATH}"

if [ "$DEPLOY_KEY_PRIVATE" = "" ]
then
   echo "DEPLOY_KEY_PRIVATE Does not exist"
   exit 1
fi

printf "%s" "$DEPLOY_KEY_PRIVATE" > "${SSH_PATH}/${KEY_FILENAME}"
chmod 600 "${SSH_PATH}/${KEY_FILENAME}"
# wc -c "${SSH_PATH}/${KEY_FILENAME}"

# printf "%s" "$DEPLOY_KEY_PUBLIC" > "${SSH_PATH}/${KEY_FILENAME}.pub"
# chmod 644 "${SSH_PATH}/${KEY_FILENAME}.pub"
# wc -c "${SSH_PATH}/${KEY_FILENAME}.pub"

echo -e "Host github.com\n\tIdentityFile ~/.ssh/${KEY_FILENAME}\n\tStrictHostKeyChecking no\n\tAddKeysToAgent yes\n" >> "${SSH_PATH}/config"
chmod 644 "${SSH_PATH}/config"

eval "$(ssh-agent)"
ssh-add "${SSH_PATH}/${KEY_FILENAME}"

ssh-keyscan github.com > "${SSH_PATH}/known_hosts"
chmod 644 "${SSH_PATH}/known_hosts"
if [ "$EMAIL" = "" ]
then
  echo "EMAIL defaulting to ${GITHUB_ACTOR}"
  EMAIL="${GITHUB_ACTOR}"
fi
echo "Setting git config globally"
git config --global user.email "$EMAIL"
git config --global user.name "$GITHUB_ACTOR"
git config --global core.sshCommand 'ssh -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa -F /dev/null'
git config --global status.submodulesummary 1
git config --global diff.submodule log

if [ "$DEBUG" = "" ]
then
   echo "DEBUG environment variable not set, so skipping ssh test"
fi
else
  echo "Debug ssh:"
  set +e
  ssh -o "IdentitiesOnly=yes" -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i "${SSH_PATH}/${KEY_FILENAME}" -F /dev/null -Tv git@github.com
  set -e
fi

cd "$GITHUB_WORKSPACE" || exit 1
ls -la "${SSH_PATH}"
printf "\033[0;32mSubmodule Safety Engaged...\033[0m\n"
git submodule sync --recursive
git submodule update --init --recursive
cd public
git checkout master
git fetch
git pull origin master
cd "$GITHUB_WORKSPACE" || exit 1
printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

hugo

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="${GITHUB_REPOSITORY} action hugo-deploy-gh-org-pages automated rebuilding of site at $(date)"
git commit -am "$msg"

# Push source and build repos.
git push origin master
printf "\033[0;32mDone for now\033[0m\n"
