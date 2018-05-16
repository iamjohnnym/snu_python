# frozen_string_literal: true

%w[
  /usr/bin/python*
  /usr/bin/pip*
  /usr/local/bin/*
].each do |f|
  describe command("ls #{f}") do
    its(:exit_status) { should eq(2) }
  end
end
