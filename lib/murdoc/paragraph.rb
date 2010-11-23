require "rubygems"
require "rdiscount"
require "cgi"
require "tempfile"

module Murdoc
  class Paragraph
    attr_accessor :source
    attr_accessor :annotation
    attr_accessor :source_type
    attr_accessor :starting_line

    def initialize(source, annotation, starting_line = 0, source_type = nil)
      self.source = source
      self.annotation = annotation
      self.starting_line = starting_line
      self.source_type = source_type
    end

    def source_type
      @source_type
    end

    def source_type=(source_type)
      @source_type = source_type.to_s
    end


    def formatted_annotation
      Markdown.new(annotation, :smart).to_html
    end

    def formatted_source
      @formatted_source ||= if pygments_installed?
        IO.popen("pygmentize -l #{source_type} -f html", "w+") do |pipe|
          pipe.puts source
          pipe.close_write
          pipe.read
        end
      else
        "<pre>" + CGI.escapeHTML(source) + "</pre>"
      end
    end

    protected
    def pygments_installed?
      @@pygments_installed ||= ENV['PATH'].split(':').any? { |dir| File.exist?("#{dir}/pygmentize") }
    end
  end
end