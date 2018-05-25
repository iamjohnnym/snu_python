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

Additional platform support may be added in the future, but Python in RHEL-land seems to get real scary real fast.

## Usage

Add the default recipe to your node's run list and/or declare instances of the included resources in a recipe of your own.

## Recipes

***default***

Installs Python 2 and 3 and some default packages using the `snu_python` resource

## Attributes

N/A

## Resources

***snu_python***

A wrapper around the `python_runtime` resource to install both Python 2 and 3 as well as any supporting packages (e.g. the python3 package that manages `/usr/local/bin/python3` on Debian platforms) and some default packages from PIP.

Syntax:

```ruby
snu_python 'default' do
  python3_packages %w[requests]
  python2_packages %w[requests awscli]
  action :install
end
```

Actions:

| Action     | Description                                         |
|------------|-----------------------------------------------------|
| `:install` | Install Python 2 and 3 and friends                  |
| `:upgrade` | Upgrade Python 2 and 3 and friends                  |
| `:remove`  | Uninstall Python 2 and 3 and all installed packages |

Properties:

| Property | Default    | Description           |
|----------|------------|-----------------------|
| action   | `:install` | The action to perform |

***snu_python_package***

A very light wrapper around the `python_package` resource that explicitly installs under Python 2 as a default behavior instead of relying on the order the `python_runtime` resources were declared in.

Syntax:

```ruby
snu_python_package 'pygithub' do
  package_name 'pygithub'
  python '2'
  version '1.2.3'
  action :install
end
```

Actions:

| Action     | Description           |
|------------|-----------------------|
| `:install` | Install the package   |
| `:upgrade` | Upgrade the package   |
| `:remove`  | Uninstall the package |

Properties:

| Property     | Default       | Description                      |
|--------------|---------------|----------------------------------|
| package_name | Resource name | The name(s) of the package(s)    |
| python       | `'2'`         | The Python runtime to install in |
| version      | `nil`         | The version to install           |
| action       | `:install`    | The action to perform            |

## Maintainers

- Jonathan Hartman <jonathan.hartman@socrata.com>
