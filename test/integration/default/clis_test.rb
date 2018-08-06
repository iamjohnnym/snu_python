# frozen_string_literal: true

describe file('/usr/bin/python') do
  its(:link_path) { should eq('/usr/bin/python2.7') }
end

describe command('python --version') do
  its(:exit_status) { should eq(0) }
  its(:stderr) { should match(/^Python 2\.7\.[0-9]+$/) }
end

describe file('/usr/bin/pip') do
  it { should_not exist }
end

major_minor3 = command('python3 --version').stdout.split.last.split('.')[0..1]
                                           .join('.')
major_minor2 = command('python2 --version').stderr.split.last.split('.')[0..1]
                                           .join('.')

pip_group = if os.name == 'ubuntu'
              'root'
            elsif os.name == 'debian'
              'staff'
            end

%W[pip3 pip#{major_minor3} pip2 pip#{major_minor2} pip].each do |c|
  describe file(File.join('/usr/local/bin', c)) do
    it { should exist }
    its(:owner) { should eq('root') }
    its(:group) { should eq(pip_group) }
    its(:mode) { should cmp('0755') }
  end
end

describe command('pip --version') do
  its(:exit_status) { should eq(0) }
  its(:stdout) do
    r = Regexp.new('^pip [0-9]+\.[0-9]+ from ' \
                   "/usr/local/lib/python#{major_minor2}/dist-packages/pip " \
                   "\\(python #{major_minor2}\\)")
    should match(r)
  end
end

describe file('/opt/myapp/bin/python') do
  its(:link_path) { should eq('/opt/myapp/bin/python2.7') }
end

describe command('/opt/myapp/bin/python --version') do
  its(:exit_status) { should eq(0) }
  its(:stderr) { should match(/^Python 2\.7\.[0-9]+$/) }
end
