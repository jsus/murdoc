require 'spec_helper'

describe Murdoc::Languages do
  subject { described_class }

  describe '#detect' do
    it "detects ruby files" do
      subject.detect('hello.rb').should == :ruby
    end

    it "detects javascript files" do
      subject.detect('hello.js').should == :js
    end

    it "detects html files" do
      subject.detect('hello.html').should == :html
    end

    it "returns nil in case of failure" do
      subject.detect('hello.txt').should == nil
    end
  end
end
