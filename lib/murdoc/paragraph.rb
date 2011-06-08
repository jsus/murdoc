require "rubygems"
begin
  require "rdiscount"
rescue LoadError
  require "kramdown"
end
require "cgi"
require "tempfile"

module Murdoc
  class Paragraph
    attr_accessor :source
    attr_accessor :annotation
    attr_accessor :source_type
    attr_accessor :starting_line
    attr_accessor :options

    def initialize(source, annotation, starting_line = 0, source_type = nil, options ={})
      self.source = source
      self.annotation = annotation
      self.starting_line = starting_line
      self.source_type = source_type
      self.options = options
    end

    def source_type
      @source_type
    end

    def source_type=(source_type)
      @source_type = source_type.to_s
    end


    def formatted_annotation
      if defined?(Markdown)
        Markdown.new(annotation, :smart).to_html
      else
        Kramdown::Document.new(annotation, :input => :markdown).to_html
      end
    end

    def formatted_source
      @formatted_source ||= if pygments_installed? && options[:highlight_source]
        IO.popen("pygmentize -l #{source_type} -O encoding=UTF8 -f html -O nowrap", "w+") do |pipe|
          pipe.puts source
          pipe.close_write
          pipe.read
        end
      else
        CGI.escapeHTML(source)
      end
    end

    protected
    def pygments_installed?
      @@pygments_installed ||= ENV['PATH'].split(':').any? { |dir| File.exist?("#{dir}/pygmentize") }
    end
  end
end
