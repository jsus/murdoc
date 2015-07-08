require "spec_helper"
require "fileutils"

describe Murdoc::Annotator do
  describe "#initialize" do
    it "should set #source from source text" do
      Murdoc::Annotator.new("Procrastination", "plaintext").source.should == "Procrastination"
    end

    it "should set source type from second argument" do
      Murdoc::Annotator.new("# Hello", "ruby").source_type.should == :ruby
      Murdoc::Annotator.new("# Hello", :ruby).source_type.should == :ruby
    end
  end

  describe ".from_file" do
    after(:each) do
      FileUtils.rm "annotator_test.rb", :force => true
      FileUtils.rm "annotator_test.", :force => true
    end

    it "should set #source from file contents" do
      File.open("annotator_test.rb", "w+") do |f|
        f.puts "# Comment"
        f.puts "puts 'Hello, world!'"
      end
      described_class.from_file("annotator_test.rb").source.should =~ /# Comment\s+puts 'Hello, world!'/
    end

    it "can handle failure of non-detection" do
      File.open('annotator_test.', 'w+')
      described_class.from_file("annotator_test.").source_type.should == :base
    end

    it "properly detects ruby" do
      File.open("annotator_test.rb", "w+")
      described_class.from_file("annotator_test.rb").source_type.should == :ruby
    end

    it "should detect source type from extension" do
      File.open("annotator_test.rb", "w+")
      Murdoc::Languages.stub('detect' => :test)
      described_class.from_file("annotator_test.rb").source_type.should == :test
    end

    it "should still let me force source type" do
      File.open("annotator_test.rb", "w+")
      described_class.from_file("annotator_test.rb", :code).source_type.should == :code
    end
  end


  describe "#source=" do
    let(:source) { "" }
    subject { described_class.new(source, :ruby) }
    context "for source with single-line comments" do
      let(:source) { "# Block one\n# Block one!!!!\n     def hi\nputs 'hello'\nend\n\n# Block two\ndef yo\nputs 'rap'\nend\n" }

      it "should split source into paragraphs" do
        subject.paragraphs.count.should == 2
        subject.paragraphs[0].source.should =~ /\A\s*def hi\s*puts 'hello'\s*end\s*\Z/m
        subject.paragraphs[0].annotation.should =~ /\ABlock one\s*Block one!!!!\Z/m
        subject.paragraphs[1].source.should =~ /\A\s*def yo\s*puts 'rap'\s*end\s*\Z/m
        subject.paragraphs[1].annotation.should =~ /\ABlock two\Z/m
      end

      it "should remove trailing comment blank line" do
        subject = described_class.new("# Hello\n#      \n   \n\n", :ruby)
        subject.paragraphs.count.should == 1
        subject.paragraphs[0].annotation.should == "Hello"
      end
    end

    context "for source with multi-line comments" do
      let(:source) { "=begin\n Block one\n Block one!!!!\n=end\n     def hi\nputs 'hello'\nend\n=begin\nBlock two\n=end\ndef yo\nputs 'rap'\nend\n" }

      it "should split source into paragraphs" do
        subject.paragraphs.count.should == 2
        subject.paragraphs[0].source.should =~ /\A\s*def hi\s*puts 'hello'\s*end\s*\Z/m
        subject.paragraphs[0].annotation.should =~ /\ABlock one\s*Block one!!!!\Z/m
        subject.paragraphs[1].source.should =~ /\A\s*def yo\s*puts 'rap'\s*end\s*\Z/m
        subject.paragraphs[1].annotation.should =~ /\ABlock two\Z/m
      end

      it "should not hang upon non-closed comments" do
        source = "=begin\n"
        lambda {
          subject = described_class.new(source, :ruby)
        }.should_not raise_error
      end
    end

    context "for comment without code" do
      let(:source) { "# Header\n\n\n# Comment\ndef body\nend" }
      it "should create a separate paragraph" do
        subject.paragraphs.count.should == 2
        subject.paragraphs[0].source.should == ""
        subject.paragraphs[0].annotation.should == "Header"
      end
    end

    it "should not choke on edge cases" do
      expect {
        described_class.new("", :ruby)
        described_class.new("#", :ruby)
        described_class.new("# A\n#", :ruby)
        described_class.new("           # A\n             #            ", :ruby)
        described_class.new("# A\n=begin\n", :ruby)
        described_class.new("# A\n=begin\n\n          =end yo", :ruby)
        described_class.new("# A\n=begin\n\n      asdasd    =end yo", :ruby)
        described_class.new("# A\n=begin\n\n      !!$$    =end yo", :ruby)
        described_class.new("\n            =begin\n\n          =end yo", :ruby)
        described_class.new("=begin YO =end\n\n\n\n asdasd asd", :ruby)
      }.not_to raise_error
    end

    it "should remove totally empty source" do
      subject = described_class.new("# Comment\n\n\n\n", :ruby)
      subject.paragraphs[0].source.should be_empty
    end

    it "should remove semi-empty lines" do
      subject = described_class.new("def hi\n\nend", :ruby)
      subject.paragraphs[0].source.should == "def hi\n\nend"
    end
  end

  describe "metadata extraction" do
    subject { described_class.new("---\nfoo: 'bar'\nbaz: 'foobar'\n---\nhello, world!", nil) }
    it "extracts and parses yaml blocks in the beginning of the file" do
      subject.metadata.should == {
        'foo' => 'bar',
        'baz' => 'foobar'
      }
    end

    it "doesn't count metadata block in line numbering" do
      paragraph = subject.paragraphs[0]
      paragraph.starting_line.should == 0
      paragraph.source.should == 'hello, world!'
    end

    it "doesn't raise on invalid yaml" do
      subject = described_class.new("---\n{\n---\nfoo bar", :ruby)
      subject.metadata.should == {}
    end
  end
end
