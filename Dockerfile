# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.2.3
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    LD_PRELOAD=/usr/local/lib/libjemalloc.so

FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
COPY vendor/ ./vendor/

RUN bundle install && \
    rm -rf ~/.bundle/ ${BUNDLE_PATH}/ruby/*/cache ${BUNDLE_PATH}/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

COPY . .

# Normalize Windows CRLF to LF for executable scripts copied from host.
RUN sed -i 's/\r$//' bin/* && chmod +x bin/*

RUN bundle exec bootsnap precompile -j 1 app/ lib/
RUN SECRET_KEY_BASE=1 REPL_ID=docker-build REPLIT_DEV_DOMAIN=localhost bundle exec rails assets:precompile

FROM base

ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_VERSION=latest
ARG IMAGE_SOURCE=https://github.com/shenefelt-org/pkmnditto
ARG IMAGE_URL=https://github.com/shenefelt-org/pkmnditto

LABEL org.opencontainers.image.title="pkmnditto" \
    org.opencontainers.image.description="Container image for the pkmnditto Rails application" \
    org.opencontainers.image.url="${IMAGE_URL}" \
    org.opencontainers.image.source="${IMAGE_SOURCE}" \
    org.opencontainers.image.revision="${IMAGE_REVISION}" \
    org.opencontainers.image.created="${IMAGE_CREATED}" \
    org.opencontainers.image.version="${IMAGE_VERSION}"

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

USER 1000:1000

COPY --chown=rails:rails --from=build ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --chown=rails:rails --from=build /rails /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
