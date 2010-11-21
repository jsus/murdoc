#
# Annotator class does all the main job: parses out comments
# and returns annotated code
#


# Main module
module Murdoc
  class Annotator
    attr_accessor :paragraphs

    def initialize(source, source_type)
      self.source_type = source_type
      self.source      = source
    end

    def source_type
      @source_type
    end

    def source_type=(source_type)
      @source_type = source_type.to_s
    end

    def source=(src)
      @source = src
      @paragraphs = []

      # lambda for checking source for comments
      is_comment = lambda do |line|
        result = false
        if comment_symbols[:single_line]
          result ||= line =~ /^\s*#{Regexp.escape(comment_symbols[:single_line])}/
        end

        if comment_symbols[:multiline]
          result ||= line =~ /^\s*#{Regexp.escape(comment_symbols[:multiline][:begin])}/
        end
        result
      end

      # splitting stuff into lines and setting cursor into initial position
      lines = src.split("\n")
      i = 0
      while i < lines.size
        comment_lines = []
        # get single line comments (removing optional first space after comment symbol)
        if comment_symbols[:single_line]
          while i < lines.size && lines[i] =~ /^\s*#{Regexp.escape(comment_symbols[:single_line])}\s?(.*)/
            comment_lines << $1
            i += 1
          end
        end

        # getting multiline comments
        if comment_symbols[:multiline]
          begin_symbol = Regexp.escape(comment_symbols[:multiline][:begin])
          end_symbol = Regexp.escape(comment_symbols[:multiline][:end])
          if i < lines.size && lines[i] =~ /\s*#{begin_symbol}/
            begin
              match = lines[i].match /\s*(#{begin_symbol})?\s?(.*?)(#{end_symbol}|$)/
              comment_lines << match[2]
              i += 1
            end while i < lines.size && !(lines[i-1] =~ /\s*#{end_symbol}/)
          end
        end

        # getting source lines
        source_lines = []
        while i < lines.size && !is_comment.call(lines[i])
          source_lines << lines[i]
          i += 1
        end

        source_lines.reject! {|l| l =~ /^\s*$/}
        comment_lines.map! {|l| l.strip }
        comment_lines.delete_at(0) if comment_lines.size > 0 && comment_lines[0].empty?
        comment_lines.delete_at(-1) if comment_lines.size > 0 && comment_lines[-1].empty?
        @paragraphs << Paragraph.new(source_lines.join("\n"), comment_lines.join("\n"), source_type)
      end
    end

    def source
      @source
    end

    def self.from_file(filename, source_type = nil)
      self.new(File.read(filename), source_type || detect_source_type_from_filename(filename))
    end

  protected
    def comment_symbols
      super || {}
    end
  end
end