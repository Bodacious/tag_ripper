# Tag::Ripper


[![Ruby](https://github.com/Bodacious/tag-ripper/actions/workflows/main.yml/badge.svg)](https://github.com/Bodacious/tag-ripper/actions/workflows/main.yml)

Lets you annotate Ruby code with tags that can be parsed and collected in code.

Example:

```ruby
# @domain: Auth
class User
  # @warning: untested
  def some_method_that_isnt_tested
    # ...
  end
end

TagRipper.new(File.read('user.rb')).taggables
# => [
# <id=22040, @name=some_method_that_isnt_tested, tags={"warning" => #<Set: {"untested"}>},parent=#<TagRipper::TaggableEntity:0x00000001203bf468>>,
#  <id=22224, @name=User, tags={"domain" => #<Set: {"Auth"}>},parent=>nil
# ]
```

## Installation

TODO: Replace `tag_ripper` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add tag_ripper
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install tag_ripper
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bodacious/tag-ripper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/bodacious/tag-ripper/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tag::Ripper project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bodacious/tag-ripper/blob/master/CODE_OF_CONDUCT.md).
