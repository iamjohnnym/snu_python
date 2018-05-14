# frozen_string_literal: true

require_relative '../resources'

shared_context 'resources::snu_python' do
  include_context 'resources'

  let(:resource) { 'snu_python' }
  let(:name) { 'default' }

  shared_context 'the :install action' do
  end

  shared_context 'the :remove action' do
    let(:action) { :remove }
  end

  shared_examples_for 'any platform' do
    context 'the :install action' do
      include_context description

      %w[3 2].each do |p|
        it "installs Python #{p}" do
          expect(chef_run).to install_python_runtime(p)
        end
      end
    end

    context 'the :remove action' do
      include_context description

      %w[3 2].each do |p|
        it "uninstalls Python #{p}" do
          expect(chef_run).to uninstall_python_runtime(p)
        end
      end
    end
  end
end
