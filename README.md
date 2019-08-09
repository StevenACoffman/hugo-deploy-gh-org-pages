# hugo-deploy-gh-org-pages
Github Action to Automate Hugo extended for a Github Organization Pages


[![license](https://img.shields.io/github/license/StevenACoffman/hugo-deploy-gh-org-pages.svg)](https://github.com/StevenACoffman/hugo-deploy-gh-org-pages/blob/master/LICENSE)
[![release](https://img.shields.io/github/release/StevenACoffman/hugo-deploy-gh-org-pages.svg)](https://github.com/StevenACoffman/hugo-deploy-gh-org-pages/releases/latest)
[![GitHub release date](https://img.shields.io/github/release-date/StevenACoffman/hugo-deploy-gh-org-pages.svg)](https://github.com/StevenACoffman/hugo-deploy-gh-org-pages/releases)
![StevenACoffman/hugo-deploy-gh-org-pages latest version](https://img.shields.io/github/release/StevenACoffman/hugo-deploy-gh-org-pages.svg?label=StevenACoffman%2Fhugo-deploy-gh-org-pages)


## GitHub Actions for building Hugo extended and deploying to a Github Organization Pages Submodule Repository

GitHub Action for building and publishing Hugo-built site to a Github Organization Pages. Follow the [Hosting on Github Organization Pages step by step instructions](https://gohugo.io/hosting-and-deployment/hosting-on-github/#step-by-step-instructions).

This action goes in the repository that will contain Hugo’s content and other source files, and expects `public` to be a submodule
pointing to a repo named like `organization.github.io`.

Inspired by [khanhicetea/gh-actions-hugo-deploy-gh-pages](https://github.com/khanhicetea/gh-actions-hugo-deploy-gh-pages)

## Secrets
- `EMAIL` - The email that you would like to have your git push signed as.
- `GIT_DEPLOY_KEY` - *Required* your deploy key which has **Write access**

## Create Deploy Key

1. Generate deploy key `ssh-keygen -t rsa -b 4096 -f hugo -q -N ""`
1. Then go to your repo named `<orgname>.github.io`and select "Settings > Deploy Keys" and click the "Add New" button
1. Add the contents of your public key (`hugo.pub`) to the Key field and select the "Allow write access" option.
1. Go to the repo named like `organization.github.io` that will contain the fully rendered version of your Hugo website
1. Add the github action as below (the file will go in `.github/main.workflow`)
1. Copy your private deploy key to `GIT_DEPLOY_KEY` secret in "Settings > Secrets"

## Environment Variables

- `HUGO_VERSION` : **optional**, default is **0.56.3** - [check all versions here](https://github.com/gohugoio/hugo/releases)

## Example

**main.workflow**

```hcl
workflow "Deploy to GitHub Organization Pages" {
  resolves = ["hugo-deploy-gh-org-pages"]
  on = "push"
}

action "hugo-deploy-gh-org-pages" {
  uses = "StevenACoffman/hugo-deploy-gh-org-pages@v1.0.0"
  needs = ["Filters for GitHub Actions"]
  secrets = [
    "EMAIL",
    "DEPLOY_KEY_PRIVATE"
  ]
  env = {
    HUGO_VERSION = "0.56.3"
  }
}

action "Filters for GitHub Actions" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}
```



## License

[MIT License - StevenACoffman/hugo-deploy-gh-org-pages]

[MIT License - StevenACoffman/hugo-deploy-gh-org-pages]: https://github.com/StevenACoffman/hugo-deploy-gh-org-pages/blob/master/LICENSE
