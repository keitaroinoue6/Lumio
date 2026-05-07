FROM ruby:3.3

WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN set -x && \
    apt-get -qq update && \
    apt-get -qq upgrade -y && \
    apt-get -qq install -y \
        build-essential \
        vim \
        default-mysql-client \
        default-libmysqlclient-dev \
        nodejs \
        npm && \
    npm install -g yarn && \
    echo 'gem: --no-rdoc --no-ri' > ~/.gemrc && \
    bundle install --jobs=`getconf _NPROCESSORS_ONLN`

COPY . /myapp

EXPOSE 3000
