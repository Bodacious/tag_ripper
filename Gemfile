# frozen_string_literal: true

source "https://rubygems.org"
gemspec

ruby file: "./.ruby-version"

group :development, :ci do
  gem "rake", "~> 13.2"
  gem "rdoc", "~> 6.13"

  gem "rubocop", "~> 1.75"
  gem "rubocop-minitest", "~> 0.37"
  gem "rubocop-rake", "~> 0.7"
end

group :test do
  gem "logger", "~> 1.7"
  gem "minitest", "~> 5.25", require: "minitest/autorun"
  gem "mocha", "~> 2.7", require: "mocha/minitest"
  gem "mutex_m", "~> 0.3"
end
