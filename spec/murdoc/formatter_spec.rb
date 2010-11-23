require "spec_helper"
require "tempfile"
describe Murdoc::Formatter do
  describe "#initialize" do
    it "should set template from given string" do
      described_class.new("%p Hello").template.should == "%p Hello"
    end

    it "should set template from given filename if that filename exists" do
      Tempfile.open("test") do |f|
        f.puts("%p Hello")
        f.close
        described_class.new(f.path).template.should == "%p Hello\n"
      end
    end
  end

  describe "#render" do
    it "should render with haml" do
      described_class.new("%p Hello").render.should =~ %r{<p>Hello</p>}
    end
    
    it "should send locals to haml" do
      described_class.new("%p= foo").render(:foo => 123).should =~ %r{<p>123</p>}
    end
  end
end