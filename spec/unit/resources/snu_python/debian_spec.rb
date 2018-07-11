# frozen_string_literal: true

require_relative '../snu_python'

describe 'resources::snu_python::debian' do
  include_context 'resources::snu_python'

  before do
    allow_any_instance_of(Chef::Mixin::ShellOut).to receive(:shell_out!)
      .with('apt-cache show python3')
      .and_return(double(stdout: "Thing: stuff\nDepends: python3.5 and more\n"))
    allow_any_instance_of(Chef::Mixin::ShellOut).to receive(:shell_out!)
      .with('apt-cache show python')
      .and_return(double(stdout: "Thing: stuff\nDepends: python2.7 and more\n"))
  end

  shared_examples_for 'any Debian platform' do
    it_behaves_like 'any platform'

    %w[install upgrade remove].each do |act|
      context "the :#{act} action" do
        include_context description

        it 'ensures the APT cache is fresh' do
          expect(chef_run).to periodic_apt_update('default')
        end

        pkg_act = act == 'remove' ? 'purge' : act
        it "#{pkg_act}s the supplemental python 3 packages" do
          p = %w[
            python3
            python3-dev
            python3-minimal
            libpython3-stdlib
            libpython3-dev
            python3.5-minimal
            libpython3.5
            libpython3.5-stdlib
            libpython3.5-minimal
            libpython3.5-dev
          ]
          if platform == 'ubuntu' && platform_version == '18.04'
            p += %w[python3-distutils python3.5-distutils]
          end
          expect(chef_run).to send(
            "#{pkg_act}_package", 'All Python 3 system packages'
          ).with(package_name: p)
        end

        it "#{pkg_act}s the supplemental python 2 packages" do
          p = %w[
            python
            python-dev
            python-minimal
            libpython-stdlib
            libpython-dev
            python2.7-minimal
            libpython2.7
            libpython2.7-stdlib
            libpython2.7-minimal
            libpython2.7-dev
          ]

          expect(chef_run).to send(
            "#{pkg_act}_package", 'All Python 2 system packages'
          ).with(package_name: p)
        end
      end
    end
  end

  RSpec.configuration.supported_platforms.each do |os, versions|
    next unless %i[ubuntu debian].include?(os)

    context os.to_s.capitalize do
      let(:platform) { os.to_s }

      versions.each do |ver|
        context ver do
          let(:platform_version) { ver }

          it_behaves_like 'any Debian platform'
        end
      end
    end
  end
end
