FROM ruby:3.2.5

WORKDIR /usr/app

RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  libpq-dev &&\
  curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn


COPY Gemfile Gemfile.lock ./
RUN bundle install --retry 3

COPY package.json yarn.lock ./    
RUN yarn install

COPY . .

RUN bundle exec rails assets:precompile

EXPOSE 3000