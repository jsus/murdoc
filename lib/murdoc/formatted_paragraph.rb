require 'forwardable'
module Murdoc
  class FormattedParagraph
    extend Forwardable

    def_delegators :paragraph, :annotation, :source, :starting_line, :source_type

    attr_reader :paragraph
    attr_reader :highlight

    def initialize(paragraph, highlight = true)
      @paragraph = paragraph
      @highlight = highlight
    end

    def formatted_annotation
      if defined?(Markdown)
        Markdown.new(annotation, :smart).to_html
      else
        Kramdown::Document.new(annotation, :input => :markdown).to_html
      end
    end

    def formatted_source
      @formatted_source ||= if pygments_installed? && highlight
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
