# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_python_virtualenv' do
  include_context 'resources'

  let(:resource) { 'snu_python_virtualenv' }
  %i[path python user group].each { |p| let(p) { nil } }
  let(:properties) do
    { path: path, python: python, user: user, group: group }
  end
  let(:name) { '/tmp/myapp' }

  shared_context 'the :create action' do
  end

  shared_context 'the :delete action' do
    let(:action) { :delete }
  end

  shared_context 'all default properties' do
  end

  {
    path: '/tmp/otherapp',
    python: '3',
    user: 'py',
    group: 'py'
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    %w[create delete].each do |act|
      context "the :#{act} action" do
        include_context description

        shared_context 'any property set' do
          it "#{act}s the Python virtualenv" do
            expect(chef_run).to send("#{act}_python_virtualenv", name)
              .with(path: path || name,
                    python: python || '2',
                    user: user,
                    group: group)
          end
        end

        %w[path python user group].each do |p|
          context "an overridden #{p} property" do
            include_context description

            it_behaves_like 'any property set'
          end
        end
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
