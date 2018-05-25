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
  end

  %i[upgrade remove].each do |a|
    shared_context "the :#{a} action" do
      let(:action) { a }
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
              expect(chef_run).to install_python_runtime(p).with(options: opts)
            end

            it "#{act}s the requested Python 3 packages" do
              pkgs = python3_packages || %w[requests]
              expect(chef_run).to send("#{act}_snu_python_package", pkgs)
                .with(python: '3')
            end

            it "#{act}s the requested Python 2 packages" do
              pkgs = python2_packages || %w[requests awscli]
              expect(chef_run).to send("#{act}_snu_python_package", pkgs)
                .with(python: '2')
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

      before do
        %w[3 2].each do |p|
          stdout = <<-STDOUT.gsub(/^ +/, '')
            [
              {"name": "certifi", "version": "2017.4.17"},
              {"name": "chardet", "version": "3.0.3"},
              {"name": "#{p}wiggles", "version": "0.0.1"}
            ]
          STDOUT

          allow_any_instance_of(Chef::Mixin::ShellOut).to receive(:shell_out!)
            .with("python#{p} -m pip.__main__ list --format=json")
            .and_return(double(stdout: stdout))
        end
      end

      %w[3 2].each do |p|
        it "removes all Python #{p} packages" do
          pp = chef_run.snu_python_package("Remove all Python #{p} packages")
          expect(pp).to do_nothing
          expect(pp.package_name).to eq(%W[certifi chardet #{p}wiggles])
        end

        it "uninstalls Python #{p}" do
          expect(chef_run).to uninstall_python_runtime(p)
          expect(chef_run.python_runtime(p))
            .to notify("snu_python_package[Remove all Python #{p} packages]")
            .to(:remove).before
        end
      end
    end
  end
end
