# frozen_string_literal: true

describe command('ls /usr/local/lib/python*') do
  its(:exit_status) { should eq(2) }
end

[/^python.*/, /^libpython.*/].each do |p|
  describe packages(p) do
    its(:statuses) { should_not cmp('installed') }
  end
end
