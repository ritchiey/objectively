# Objectively

Objectively draws a diagram of the messages being  passed between objects
in some part of your Ruby program.

The purpose is to help you understand at a glance how the objects in your
program are interacting.

Note: Don't run this in production.

## Installation

Add this line to the development section of your application's Gemfile:

```ruby
gem 'objectively'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install objectively

## Usage

```ruby
Objectively.draw(png: 'hello_world.png') do
  # your code to be traced.
end

```

Your objects will be named `ClassName:1`, `ClassName:2` etc by default but
they can specify their own name by responding to `__name_in_diagram__`.

Note that `__name_in_diagram` must return a unique and unchanging name for each class instance.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/objectively.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
