# frozen_string_literal: true

module PoisePython
  module Resources
    # Patch in the poise-python fixes for pip 18.1 currently awaiting release.
    module PythonPackage
      PIP_HACK_SCRIPT = <<-HACK.gsub(/^ {8}/, '')
        import json
        import re
        import sys
        import pip
        # Don't use pkg_resources because I don't want to require it before this anyway.
        if re.match(r'0\\.|1\\.|6\\.0', pip.__version__):
          sys.stderr.write('The python_package resource requires pip >= 6.1.0, currently '+pip.__version__+'\\n')
          sys.exit(1)
        try:
          from pip.commands import InstallCommand
          from pip.index import PackageFinder
          from pip.req import InstallRequirement
          install_req_from_line = InstallRequirement.from_line
        except ImportError:
          # Pip 10 moved all internals to their own package.
          from pip._internal.commands import InstallCommand
          from pip._internal.index import PackageFinder
          try:
            # Pip 18.1 moved from_line to the constructors
            from pip._internal.req.constructors import install_req_from_line
          except ImportError:
            from pip._internal.req import InstallRequirement
            install_req_from_line = InstallRequirement.from_line
        packages = {}
        cmd = InstallCommand()
        options, args = cmd.parse_args(sys.argv[1:])
        with cmd._build_session(options) as session:
          if options.no_index:
            index_urls = []
          else:
            index_urls = [options.index_url] + options.extra_index_urls
          finder_options = dict(
            find_links=options.find_links,
            index_urls=index_urls,
            allow_all_prereleases=options.pre,
            process_dependency_links=options.process_dependency_links,
            trusted_hosts=options.trusted_hosts,
            session=session,
          )
          if getattr(options, 'format_control', None):
            finder_options['format_control'] = options.format_control
          finder = PackageFinder(**finder_options)
          find_all = getattr(finder, 'find_all_candidates', getattr(finder, '_find_all_versions', None))
          for arg in args:
            req = install_req_from_line(arg)
            found = finder.find_requirement(req, True)
            all_candidates = find_all(req.name)
            candidate = [c for c in all_candidates if c.location == found]
            if candidate:
              packages[candidate[0].project.lower()] = str(candidate[0].version)
        json.dump(packages, sys.stdout)
      HACK
    end
  end
end
