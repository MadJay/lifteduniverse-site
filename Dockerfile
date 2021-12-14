FROM ruby:3.0.2

ENV VCMS_API /home/app/vcms_api
RUN mkdir -p $VCMS_API
WORKDIR $VCMS_API

RUN apt-get update && apt-get install -y nodejs libmagickwand-dev ghostscript nano && rm -rf /var/lib/apt/lists/* && apt-get cleanclean
EXPOSE 3000
ENV RAILS_VERSION 6.1.4
RUN gem install bundler
RUN gem install rails --version "$RAILS_VERSION"
ADD Gemfile ./
ADD Gemfile.lock ./

RUN bundle install

ADD . $VCMS_API

CMD ["rails", "s", "Puma", "-b", "0.0.0.0"]