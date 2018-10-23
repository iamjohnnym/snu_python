# frozen_string_literal: true

include_recipe 'snu_python'

python_package '1and1'

python_package 'pygithub' do
  python '2'
end

python_package 'pygithub' do
  python '3'
end

python_virtualenv '/opt/myapp' do
  python '3'
end

python_package 'awscli' do
  virtualenv '/opt/myapp'
end

package 'git'

directory '/usr/share/collectd'

git '/usr/share/collectd/docker' do
  repository 'https://github.com/signalfx/docker-collectd-plugin'
end

python_virtualenv '/usr/share/collectd/python' do
  python '2'
end

pip_requirements '/usr/share/collectd/docker/requirements.txt' do
  virtualenv '/usr/share/collectd/python'
end
