require 'spec_helper'

describe Murdoc::Scanner do
  subject { described_class.new(Murdoc::Languages::Ruby) }

  describe "null scanner" do
    subject { described_class.new(Murdoc::Languages::Base) }

    it "returns a single paragraph with all the text" do
      paragraphs = subject.call("hello\nworld")
      paragraphs.count.should == 1
      paragraphs[0].source.should == "hello\nworld"
      paragraphs[0].annotation.should be_empty
    end
  end

  it "detect single line comment block annotations" do
    # for example
    # something like
    # this

    paragraphs = subject.call("# hello\n# hello 2\n\nworld")
    paragraphs.count.should == 1
    paragraphs[0].annotation.should == "hello\nhello 2"
    paragraphs[0].source.should == 'world'
  end

  it "detects multi-line comment block annotations" do
    # =begin
    # this should become annotation
    # =end

    paragraphs = subject.call("=begin\nhello\n=endworld")
    paragraphs.count.should == 1
    paragraphs[0].annotation.should == 'hello'
    paragraphs[0].source.should == 'world'
  end

  it "works with zero code lines" do
    paragraphs = subject.call('# foo')
    paragraphs.count.should == 1
    paragraphs[0].annotation.should == 'foo'
    paragraphs[0].source.should == ''
  end

  it "works with zero annotation lines" do
    paragraphs = subject.call("foo bar\nbaz bool")
    paragraphs.count.should == 1
    paragraphs[0].source.should == "foo bar\nbaz bool"
  end

  it "works with more than one paragraph" do
    paragraphs = subject.call("# hello\nworld\n# foo\nbar")
    paragraphs.count.should == 2
    paragraphs[1].annotation.should == "foo"
    paragraphs[1].source.should == "bar"
  end

  it "removes common space prefix from multiline comment blocks" do
    paragraphs = subject.call("=begin\n    foo\n    bar\n        baz\n=end")
    paragraphs[0].annotation.should == "foo\nbar\n    baz"
  end
end
