# Testing

## Prerequisites

Running the tests described below assumes an already installed Ruby environment
(via Chef-DK, Homebrew, system Ruby, etc).

The integration tests assume a running instance of Docker on the test machine. 

## Installing Dependencies

Install all the gem dependencies into your Ruby environment:

```shell
> bundle install
```

Or, if using the Chef-DK's Ruby:

```shell
> eval "$(chef shell-init bash)"
> bundle install
```

## All Test Suites

The included `Rakefile` defines a default task that runs all non-integration
tests:

```shell
> bundle exec rake
```

The included `test/run` script runs all tests:

```shell
> bundle exec test/run
```

## Lint Tests

This cookbook uses both RuboCop and FoodCritic for linting. Just the lint tests
can be run with Rake:

```shell
> bundle exec rake rubocop
> bundle exec rake foodcritic
```

## Unit Tests

Unit testing is done with ChefSpec. The unit tests can be run with Rake:

```shell
> bundle exec rake spec
```

## Integration Tests

Integration testing is done with Test Kitchen and Inspec. The included Kitchen
config assumes a working local Docker installation.

```shell
> bundle exec rake kitchen:all
```
