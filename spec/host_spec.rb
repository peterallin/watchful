require 'host'

describe Host do
  it "has a name" do
    host = Host.new("testhostname")
    host.name.should eq "testhostname"
  end
end
