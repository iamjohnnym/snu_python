# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_python_package' do
  include_context 'resources'

  let(:resource) { 'snu_python_package' }
  %i[package_name python version].each { |p| let(p) { nil } }
  let(:properties) do
    { package_name: package_name, python: python, version: version }
  end
  let(:name) { 'thing' }

  shared_context 'the :install action' do
  end

  %i[upgrade remove].each do |a|
    shared_context "the :#{a} action" do
      let(:action) { a }
    end
  end

  shared_context 'all default properties' do
  end

  {
    package_name: %w[thing1 thing2],
    python: '3',
    version: '1.2.3'
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    %w[install upgrade remove].each do |act|
      context "the :#{act} action" do
        include_context description

        shared_context 'any property set' do
          it "#{act}s the Python package" do
            expect(chef_run).to send("#{act}_python_package", name)
              .with(package_name: package_name || name,
                    python: python || '2',
                    version: version)
          end
        end

        %w[package_name python version].each do |p|
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
