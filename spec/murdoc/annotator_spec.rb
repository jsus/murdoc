require "spec_helper"
require "fileutils"

describe Murdoc::Annotator do
  describe "#initialize" do
    it "should set #source from source text" do
      Murdoc::Annotator.new("Procrastination", "plaintext").source.should == "Procrastination"
    end

    it "should set source type from second argument" do
      Murdoc::Annotator.new("# Hello", "ruby").source_type.should == "ruby"
      Murdoc::Annotator.new("# Hello", :ruby).source_type.should == "ruby"
    end

    it "should set options from hash" do
      Murdoc::Annotator.new("", "", :foo => :bar).options[:foo].should == :bar
    end
  end

  describe ".from_file" do
    after(:each) { FileUtils.rm "annotator_test.rb", :force => true }
    it "should set #source from file contents" do
      File.open("annotator_test.rb", "w+") do |f|
        f.puts "# Comment"
        f.puts "puts 'Hello, world!'"
      end

      described_class.from_file("annotator_test.rb").source.should =~ /# Comment\s+puts 'Hello, world!'/
    end

    it "should detect source type from extension" do
      File.open("annotator_test.rb", "w+")
      described_class.stub(:detect_source_type_from_filename).and_return("test")
      described_class.from_file("annotator_test.rb").source_type.should == "test"
    end

    it "should still let me force source type" do
      File.open("annotator_test.rb", "w+")
      described_class.from_file("annotator_test.rb", "code").source_type.should == "code"
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
        subject.source = "# Hello\n#      \n   \n\n"
        subject.paragraphs.count.should == 1
        subject.paragraphs[0].annotation.should == "Hello"
      end

      it "should not remove more than one space" do
        subject.source = "#    Hello"
        subject.paragraphs.count.should == 1
        subject.paragraphs[0].annotation.should == "    Hello"
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

    context "for commented code" do
      let(:source) { "# :code:\n# def hello\n# end\n\n\# Comment\ndef hi\nend" }
      it "should not create paragraphs" do
        subject.paragraphs.count.should == 1
        subject.paragraphs[0].source.should == "def hi\nend"
        subject.paragraphs[0].annotation.should == "Comment"
      end

      it "should not swallow wrong code" do
        source = "# :code:\n# def hi\n# end\n\ndef hallo\nend"
        subject = described_class.new(source, :ruby)
        subject.paragraphs.count.should == 1
        subject.paragraphs[0].annotation.to_s.should == ""
        subject.paragraphs[0].source.should == "def hallo\nend"
      end
    end

    it "should not choke on edge cases" do
      subject.source = ""
      subject.source = "#"
      subject.source = "# A\n#"
      subject.source = "           # A\n             #            "
      subject.source = "# A\n=begin\n"
      subject.source = "# A\n=begin\n\n          =end yo"
      subject.source = "# A\n=begin\n\n      asdasd    =end yo"
      subject.source = "# A\n=begin\n\n      !!$$    =end yo"
      subject.source = "\n            =begin\n\n          =end yo"
      subject.source = "=begin YO =end\n\n\n\n asdasd asd"
    end

    it "should remove totally empty source" do
      subject.source = "# Comment\n\n\n\n"
      subject.paragraphs[0].source.should be_empty
    end

    it "should remove semi-empty lines" do
      subject.source = "def hi\n\nend"
      subject.paragraphs[0].source.should == "def hi\n\nend"
    end
  end


  describe "#annotated" do
    let(:source) { "# this" }
    subject { described_class.new(source, :ruby) }
  end
end
