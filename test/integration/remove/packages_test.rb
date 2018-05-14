# frozen_string_literal: true

[/^python.*/, /^libpython.*/].each do |p|
  describe packages(p) do
    its(:statuses) { should_not cmp('installed') }
  end
end
