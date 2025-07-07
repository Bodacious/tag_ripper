# 🏷️ Tag Ripper

[![Ruby](https://github.com/Bodacious/tag-ripper/actions/workflows/main.yml/badge.svg)](https://github.com/Bodacious/tag-ripper/actions/workflows/main.yml)
[![Maintainability](https://qlty.sh/gh/Bodacious/projects/tag_ripper/maintainability.svg)](https://qlty.sh/gh/Bodacious/projects/tag_ripper)
[![Code Coverage](https://qlty.sh/gh/Bodacious/projects/tag_ripper/coverage.svg)](https://qlty.sh/gh/Bodacious/projects/tag_ripper)

Lets you annotate Ruby code with tags that can be parsed and collected in code.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add tag_ripper
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install tag_ripper
```

## Usage

```ruby
# @domain: Auth
class User
  # @warning: untested
  def some_method_that_isnt_tested
    # ...
  end
end

TagRipper.new(File.read('user.rb')).taggables
# (Beautified output)
# ---
# -
#   id: 2221
#   name: some_method_that_isnt_tested
#   tags:
#     warning:
#       - "untested
#   parent: 22224,
# -
#   id: 22224
#   name: User
#   tags:
#     domain:
#       - "Auth"
#    parent: nil
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/bodacious/tag_ripper>.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/bodacious/tag_ripper/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tag::Ripper project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bodacious/tag_ripper/blob/master/CODE_OF_CONDUCT.md).
