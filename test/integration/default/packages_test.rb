# frozen_string_literal: true

major_minor3 = command('python3 --version').stdout.split.last.split('.')[0..1]
                                           .join('.')
major_minor2 = command('python2 --version').stderr.split.last.split('.')[0..1]
                                           .join('.')

%W[
  python3
  python#{major_minor3}
  python3-dev
  python#{major_minor3}-dev
  python
  python#{major_minor2}
  python-dev
  python#{major_minor2}-dev
].each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

%w[python3-pip python-pip].each do |p|
  describe package(p) do
    it { should_not be_installed }
  end
end

%w[awscli 1and1].each do |p|
  describe pip(p) do
    it { should be_installed }
  end

  %W[/usr/local/bin/pip2 /usr/local/bin/pip#{major_minor2}].each do |pp|
    describe pip(p, pp) do
      it { should be_installed }
    end
  end

  %W[/usr/local/bin/pip3 /usr/local/bin/pip#{major_minor3}].each do |pp|
    describe pip(p, pp) do
      it { should_not be_installed }
    end
  end
end

%w[requests pygithub].each do |p|
  describe pip(p) do
    it { should be_installed }
  end

  %W[pip2 pip#{major_minor2} pip3 pip#{major_minor3}].each do |pp|
    describe pip(p, "/usr/local/bin/#{pp}") do
      it { should be_installed }
    end
  end
end

describe pip('awscli', '/opt/myapp/bin/pip') do
  it { should be_installed }
end

%w[py-dateutil docker jsonpath_rw].each do |p|
  describe pip(p, '/usr/share/collectd/python/bin/pip') do
    it { should be_installed }
  end
end
