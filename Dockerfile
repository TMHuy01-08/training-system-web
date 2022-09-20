FROM ruby:3.0.2-alpine as base

WORKDIR /app

ENV PATH="${PATH}:/app/bin"

RUN apk update  && apk add mysql-dev mysql-client gcc g++ make python3 nodejs tzdata yarn

COPY Gemfile Gemfile.lock ./

RUN bundle install

FROM base as development

ENV RAILS_ENV=developement

FROM base as builder

COPY . . 

RUN bundle exec rails assets:precompile

FROM base as production

ENV RAILS_ENV=production

RUN mkdir -p tmp/pids
RUN mkdir -p tmp/logs
COPY --from=builder /app/entrypoint.sh /app/entrypoint.sh

COPY --from=builder /app/bin ./bin 
COPY --from=builder /app/Rakefile . 
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/config ./config 
COPY --from=builder /app/config.ru /app/config.ru
COPY --from=builder /app/db ./db
COPY --from=builder /app/app ./app 
COPY --from=builder /app/public ./public

# ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "/bin/sh", "/app/entrypoint.sh" ]


