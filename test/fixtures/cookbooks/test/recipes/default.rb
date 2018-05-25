# frozen_string_literal: true

include_recipe 'snu_python'

python_package '1and1'

python_package 'pygithub' do
  python '2'
end

python_package 'pygithub' do
  python '3'
end

snu_python_package 'botocore'

snu_python_package 'python_http_client' do
  python '2'
end

snu_python_package 'python_http_client' do
  python '3'
end
