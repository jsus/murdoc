require "spec_helper"

describe Murdoc::Paragraph do
  describe "#initialize" do
    it "should set source" do
      described_class.new("A", "").source.should == "A"
    end

    it "should set annotation" do
      described_class.new("", "B").annotation.should == "B"
    end

    it "should optionally set source_type" do
      described_class.new("", "", 0, :ruby).source_type.should == "ruby"
    end

    it "should optionally set starting line" do
      described_class.new("", "", 666, :ruby).starting_line.should == 666
    end

    it "should optionally set options" do
      described_class.new("", "", 666, :ruby, {:foo => :bar}).options.should == {:foo => :bar}
    end
  end
end