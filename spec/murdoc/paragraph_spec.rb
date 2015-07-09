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
      described_class.new("", "", 0, :ruby).source_type.should == :ruby
    end

    it "should optionally set starting line" do
      described_class.new("", "", 666, :ruby).starting_line.should == 666
    end

    it "extracts metadata" do
      subject = described_class.new("", "---! {'foo': 'bar'}\nbaz")
      subject.metadata.should == {'foo' => 'bar'}
      subject.annotation.should == 'baz'
    end

    it "extracts metadata from the middle of annotation too" do
      subject = described_class.new("", "foo\n---! {bar: 'baz'}\nfoo2")
      subject.metadata.should == {'bar' => 'baz'}
      subject.annotation.should == "foo\nfoo2"
    end
  end
end
