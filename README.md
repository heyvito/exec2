# Exec2

Exec2 is a small wrapper around `Process::spawn`. This gem exists because I
usually follow this same pattern in multiple projects, and copy-paste is tedious.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add exec2

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install exec2

## Usage

Executing a command using `Exec2.exec2` returns its stdout and stderr contents:

```ruby
Exec2.exec2("git rev-parse --show-toplevel")
# => ["/Users/victorgama/Developer/exec2\n", ""]
```

`Exec2.exec` is an alias of `Exec2.exec2(...).first` in case you don't care
about what `stderr` may hold:

```ruby
Exec2.exec2("git rev-parse --show-toplevel")
# => "/Users/victorgama/Developer/exec2\n"
```

Commands exiting with a non-zero status raises an `Exec2::Error`:
```ruby
Exec2.exec2("git bla")
# /Users/victorgama/Developer/exec2/lib/exec2.rb:71:in `exec2': Process `git bla' exited with status 1:  git: 'bla' is not a git command. See 'git --help'. (Exec2::Error)
#
# The most similar command is
#     blame
#
#     from (irb):4:in `<main>'
#     from bin/console:15:in `<main>'
```

For convenience, `Exec2::Error` contains the following fields: `:stdout, :stderr, :status, :cmd, :env`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/heyvito/exec2. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/heyvito/exec2/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Exec2 project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/heyvito/exec2/blob/master/CODE_OF_CONDUCT.md).
