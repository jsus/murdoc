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
      described_class.new("", "", :ruby).source_type.should == "ruby"
    end
  end
end