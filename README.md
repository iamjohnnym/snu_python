# Snu Python Cookbook README

[![Cookbook Version](https://img.shields.io/cookbook/v/snu_python.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/socrata-cookbooks/snu_python.svg)][travis]

[cookbook]: https://supermarket.chef.io/cookbooks/snu_python
[travis]: https://travis-ci.org/socrata-cookbooks/snu_python

A cookbook to perform an opinionated installation of Python using poise-python.

## Requirements

This cookbook is continously tested against a matrix of Chef versions and platforms:

- Chef 14
- Chef 13
- Chef 12

X

- Ubuntu 16.04
- Ubuntu 14.04
- Debian 9
- Debian 8

## Usage

Add the default recipe to your node's run list and/or declare instances of the included resources in a recipe of your own.

## Recipes

***default***

- Installs Python 2 and 3 using the `snu_python` resource
- Installs/upgrades the awscli and requests in Python 2 using `snu_python_package`

## Attributes

N/A

## Resources

***snu_python***

A wrapper around the `python_runtime` resource to install both Python 2 and 3 as well as any supporting packages (e.g. the python3 package that manages `/usr/local/bin/python3` on Debian platforms).

Syntax:

```ruby
snu_python 'default' do
  action :install
end
```

Actions:

| Action     | Description              |
|------------|--------------------------|
| `:install` | Install Python 2 and 3   |
| `:remove`  | Uninstall Python 2 and 3 |

Properties:

| Property | Default    | Description           |
|----------|------------|-----------------------|
| action   | `:install` | The action to perform |

***snu_python_package***

A wrapper around the `python_package` resource to explicitly default to installing packages in Python 2 rather than relying on the order the `python_runtime` resources were declared in.

Syntax:

```ruby
snu_python_package 'awsclit' do
  python 'python2'
  action :install
end
```

Actions:

Actions are the same as those of the [python_package](https://github.com/poise/poise-python#python_package) resource.

Properties:

| Property | Default     | Description                          |
|----------|-------------|--------------------------------------|
| python   | `'python2'` | The Python to install the package in |
| \*       |             |                                      |

\* All other properties are the same as those of the [python_package](https://github.com/poise/poise-python#python_package) resource.

## Maintainers

- Jonathan Hartman <jonathan.hartman@socrata.com>
