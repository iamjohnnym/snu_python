# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'snu_python::default' do
  let(:platform) { { platform: 'ubuntu', version: '16.04' } }
  let(:runner) { ChefSpec::SoloRunner.new(platform) }
  cached(:chef_run) { runner.converge(described_recipe) }

  it 'installs snu_python' do
    expect(chef_run).to install_snu_python('default')
  end

  it 'upgrades the awscli and requests packages' do
    expect(chef_run).to upgrade_snu_python_package(%w[awscli requests])
  end
end
