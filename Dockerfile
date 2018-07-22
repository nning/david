FROM ruby:alpine

COPY . /app
WORKDIR /app

RUN \
  apk update && \
  apk add build-base && \
  bundle install --without cbor development test && \
  apk del build-base && \
  rm /var/cache/apk/*.gz

CMD rackup
