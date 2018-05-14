# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_python_package' do
  include_context 'resources'

  let(:resource) { 'snu_python_package' }
  let(:name) { 'thing' }

  shared_context 'the :nothing action' do
    let(:action) { :nothing }
  end

  shared_examples_for 'any platform' do
    context 'the :nothing action' do
      include_context description

      it 'defaults the python runtime to python2' do
        expect(chef_run.snu_python_package('thing').python).to eq('python2')
      end
    end
  end

  RSpec.configuration.supported_platforms.each do |os, versions|
    context os.to_s.capitalize do
      let(:platform) { os.to_s }

      versions.each do |ver|
        context ver do
          let(:platform_version) { ver }

          it_behaves_like 'any platform'
        end
      end
    end
  end
end
