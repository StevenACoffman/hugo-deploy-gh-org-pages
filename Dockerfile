FROM golang:alpine AS build

ENV GO111MODULE on
ENV HUGO_VERSION 0.56.3

WORKDIR /go/src/github.com/gohugoio/hugo
RUN apk add --no-cache git build-base
RUN wget -O- https://github.com/gohugoio/hugo/archive/v${HUGO_VERSION}.tar.gz|tar -xz --strip=1
RUN go install -v -ldflags '-s -w' -tags extended

# ---

FROM alpine:latest
LABEL "com.github.actions.name"="Hugo for GitHub Organization Pages"
LABEL "com.github.actions.description"="Publishes and deploys the project to GitHub Organization Pages"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="yellow"

LABEL "repository"="http://github.com/StevenACoffman/hugo-deploy-gh-org-pages"
LABEL "homepage"="http://github.com/StevenACoffman/hugo-deploy-gh-org-pages"

RUN apk add --update git openssh-client bash git-subtree \
    findutils py-pygments asciidoctor libc6-compat libstdc++ \
    ca-certificates
COPY --from=build /go/bin/hugo /usr/local/bin

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
