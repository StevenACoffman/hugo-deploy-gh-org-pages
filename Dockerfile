FROM golang:alpine AS build

ENV GO111MODULE on
ENV ver 0.56.3

WORKDIR /go/src/github.com/gohugoio/hugo
RUN apk add --no-cache git build-base
RUN wget -O- https://github.com/gohugoio/hugo/archive/v$ver.tar.gz|tar -xz --strip=1
RUN go install -v -ldflags '-s -w' -tags extended

# ---

FROM alpine:latest
LABEL "com.github.actions.name"="hugo-org-action"
LABEL "com.github.actions.description"="Run hugo publish for github organization"
LABEL "com.github.actions.icon"="wifi"
LABEL "com.github.actions.color"="yellow"

LABEL "repository"="http://github.com/StevenACoffman/hugo-org-action"
LABEL "homepage"="http://github.com/StevenACoffman/hugo-org-action"

RUN apk add --update git openssh-client bash git-subtree \
    findutils py-pygments asciidoctor libc6-compat libstdc++ \
    ca-certificates
COPY --from=build /go/bin/hugo /usr/local/bin

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
