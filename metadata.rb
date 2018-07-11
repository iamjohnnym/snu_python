# frozen_string_literal: true

name 'snu_python'
maintainer 'Socrata Engineering'
maintainer_email 'sysadmin@socrata.com'
license 'Apache-2.0'
description 'Installs/configures snu_python'
long_description 'Installs/configures snu_python'
version '1.0.0'
chef_version '>= 12.14'

source_url 'https://github.com/socrata-cookbooks/snu_python'
issues_url 'https://github.com/socrata-cookbooks/snu_python/issues'

depends 'poise-python'

# TODO: 18.04 support should be in the next poise-python after 1.7.0.
supports 'ubuntu', '< 18.04'
supports 'debian'
