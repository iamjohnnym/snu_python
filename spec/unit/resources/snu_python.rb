# frozen_string_literal: true

require_relative '../resources'

shared_context 'resources::snu_python' do
  include_context 'resources'

  let(:resource) { 'snu_python' }
  %i[python3_packages python2_packages].each { |p| let(p) { nil } }
  let(:properties) do
    { python3_packages: python3_packages, python2_packages: python2_packages }
  end
  let(:name) { 'default' }

  shared_context 'the :install action' do
    before do
      allow(File).to receive(:stat).and_call_original
      allow(File).to receive(:stat)
        .with('/usr/local/bin/pip2')
        .and_return(double(uid: 123, gid: 456, mode: 33_261))
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read)
        .with('/usr/local/bin/pip2').and_return('pip2')
    end
  end

  shared_context 'the :upgrade action' do
    let(:action) { :upgrade }

    before do
      allow(File).to receive(:stat).and_call_original
      allow(File).to receive(:stat)
        .with('/usr/local/bin/pip2')
        .and_return(double(uid: 123, gid: 456, mode: 33_261))
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read)
        .with('/usr/local/bin/pip2').and_return('pip2')
    end
  end

  shared_context 'the :remove action' do
    let(:action) { :remove }
    let(:python3_installed?) { nil }
    let(:python2_installed?) { nil }

    before do
      allow(File).to receive(:exist?).and_call_original
      %w[3 2].each do |p|
        allow(File).to receive(:exist?)
          .with("/usr/bin/python#{p}")
          .and_return(send(:"python#{p}_installed?"))
        stdout = <<-STDOUT.gsub(/^ +/, '')
          [
            {"name": "certifi", "version": "2017.4.17"},
            {"name": "chardet", "version": "3.0.3"},
            {"name": "#{p}wiggles", "version": "0.0.1"}
          ]
        STDOUT

        allow_any_instance_of(Chef::Mixin::ShellOut).to receive(:shell_out!)
          .with("/usr/bin/python#{p} -m pip.__main__ list --format=json")
          .and_return(double(stdout: stdout))
      end
    end
  end

  shared_context 'all default properties' do
  end

  {
    python3_packages: %w[test1 test2],
    python2_packages: %w[test3 test4]
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    %w[install upgrade].each do |act|
      context "the :#{act} action" do
        include_context description

        shared_context 'any property set' do
          %w[3 2].each do |p|
            it "installs Python #{p}" do
              opts = act == 'upgrade' ? { package_upgrade: true } : nil
              expect(chef_run).to install_python_runtime(p)
                .with(pip_version: '18.0', options: opts)
            end

            it "#{act}s the requested Python 3 pip packages" do
              pkgs = python3_packages || %w[requests]
              expect(chef_run).to send(
                "#{act}_python_package", 'Python 3 pip packages'
              ).with(package_name: pkgs, python: '3')
            end

            it "#{act}s the requested Python 2 pip packages" do
              pkgs = python2_packages || %w[requests]
              expect(chef_run).to send(
                "#{act}_python_package", 'Python 2 pip packages'
              ).with(package_name: pkgs, python: '2')
            end

            it 'ensures /usr/local/bin/pip points at Python 2' do
              expect(chef_run).to create_file('/usr/local/bin/pip')
                .with(owner: 123,
                      group: 456,
                      mode: '00755',
                      content: 'pip2')
            end
          end
        end

        [
          'all default properties',
          'an overridden python3_packages property',
          'an overridden python2_packages property'
        ].each do |ctx|
          context ctx do
            include_context description

            it_behaves_like 'any property set'
          end
        end
      end
    end

    context 'the :remove action' do
      include_context description

      shared_examples_for 'any installed state' do
        %w[3 2].each do |p|
          it "uninstalls Python #{p}" do
            expect(chef_run).to uninstall_python_runtime(p)
          end
        end
      end

      context 'no Python runtime installed' do
        let(:python3_installed?) { false }
        let(:python2_installed?) { false }

        it_behaves_like 'any installed state'

        %w[3 2].each do |p|
          it "does not remove all Python #{p} pip packages" do
            pp = chef_run.python_package(
              "All Python #{p} pip packages"
            )
            expect(pp).to eq(nil)
          end
        end
      end

      context 'Python 3 runtime installed' do
        let(:python3_installed?) { true }

        it_behaves_like 'any installed state'

        it 'removes all Python 3 pip packages' do
          expect(chef_run)
            .to remove_python_package('All Python 3 pip packages')
            .with(package_name: %w[certifi chardet 3wiggles],
                  python: '3')
        end
      end

      context 'Python 2 runtime installed' do
        let(:python2_installed?) { true }

        it 'removes all Python 2 pip packages' do
          expect(chef_run)
            .to remove_python_package('All Python 2 pip packages')
            .with(package_name: %w[certifi chardet 2wiggles],
                  python: '2')
        end
      end
    end
  end
end
