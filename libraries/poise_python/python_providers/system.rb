# frozen_string_literal: true

module PoisePython
  module PythonProviders
    # Patch in the poise-python fixes for Ubuntu 18.04 currently awaiting
    # release.
    class System < Base
      def install_python
        install_system_packages
        return unless node.platform_family?('debian') && \
                      system_package_name == 'python3.6'
        opts = options
        package %w[python3.6-venv python3.6-distutils] do
          action(:upgrade) if opts['package_upgrade']
        end
      end

      def uninstall_python
        if node.platform_family?('debian') && system_package_name == 'python3.6'
          package %w[python3.6-venv python3.6-distutils] do
            action(:purge)
          end
        end
        uninstall_system_packages
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def system_package_candidates(version)
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
        [].tap do |names|
          # For two (or more) digit versions.
          if (match = version.match(/^(\d+\.\d+)/))
            # Debian style pythonx.y
            names << "python#{match[1]}"
            # Amazon style pythonxy
            names << "python#{match[1].delete('.')}"
          end
          # Aliases for 2 and 3.
          if version == '3' || version.empty?
            names.concat(
              %w[python3.7 python37 python3.6 python36 python3.5 python35
                 python3.4 python34 python3.3 python33 python3.2 python32
                 python3.1 python31 python3.0 python30 python3]
            )
          end
          if version == '2' || version.empty?
            names.concat(%w[python2.7 python27 python2.6 python26 python2.5
                            python25])
          end
          # For RHEL and friends.
          names << 'python'
          names.uniq!
        end
      end
    end
  end
end
