# frozen_string_literal: true

include_recipe '::default'

snu_python 'remove' do
  action :remove
end
