# Create a Jekyll container from a Ruby Alpine image

# At a minimum, use Ruby 2.5 ot later
FROM ruby:2.7-alpine3.15

# Add jekyll dependencies to Alpine
RUN apk update
RUN apk add --no--cache build-base gcc cmake git

# update the Ruby bundler and install Jekyll
RUN gem update bundler && gem install bundler Jekyll