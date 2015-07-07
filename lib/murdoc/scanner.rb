require 'strscan'

module Murdoc
  class Scanner
    attr_reader :language

    def initialize(language)
      @language = language
    end

    def call(source)
      paragraphs = []
      ss = StringScanner.new(source)
      line = i = 0

      loop do
        line = i
        comment_lines = []
        code_lines = []


        i += skip_empty_lines(ss)

        # Single line comments
        if has_slc?
          while (ss.scan(slc_regex))
            comment = ''
            comment << ss.scan(/.*$/)
            p ss.peek(5);
            comment << ss.getch.to_s
            comment_lines << comment
            i += 1
          end
        end

        i += skip_empty_lines(ss)
        # Multi line comments
        if has_mlc?
          while (ss.scan(mlcb_regex))
            comment = ''

            while (!ss.eos? && !ss.match?(/.*#{mlce_regex}/))
              i += 1
              comment << ss.scan(/^.*$/)
              comment << ss.getch.to_s
            end

            if (fragment = ss.scan(/.*#{mlce_regex}/))
              comment << fragment.sub(mlce_regex, '')
            end

            comment_lines << remove_common_space_prefix(comment)
          end
        end

        i += skip_empty_lines(ss)

        # Code
        line = i
        while (!comment_start?(ss) && !ss.eos?)
          code = ss.scan(/^.*$/)
          code << ss.getch.to_s
          code_lines << code
          i += 1
        end

        code = post_process_code(code_lines.join(''))
        comments = post_process_comments(comment_lines.join(''))

        paragraphs << Paragraph.new(code,
                                    comments,
                                    line,
                                    language.name)

        break if ss.eos?
      end

      paragraphs
    end

    protected

    def post_process_code(code)
      code.strip
    end

    def post_process_comments(comments)
      comments.strip.gsub(/^\s(\S)/, '\\1')
    end

    def comment_start?(ss)
      (has_slc? && ss.match?(slc_regex)) ||
          (has_mlc? && ss.match?(mlcb_regex))
    end

    def skip_empty_lines(ss)
      i = 0
      while (ss.scan(/\s*?$/) && !ss.eos?)
        i += 1
        ss.getch
      end
      i
    end

    def remove_common_space_prefix(str)
      lines = str.split("\n")
      # delete empty leading and trailing lines
      lines.delete_at(0) while lines[0].empty?
      lines.delete_at(-1) while lines[-1].empty?

      prefix_lengths =  lines.map {|l| l.match(/^( *)/)[1].length }.reject(&:zero?)
      prefix = ' ' * (prefix_lengths.min || 0)
      lines.map {|line| line.sub(/^#{prefix}/, '') }.join("\n")
    end

    def has_slc?
      !!language.comment_symbols[:single_line]
    end

    def slc_regex
      return @slc_regex unless @slc_regex.nil?
      @slc_regex = has_slc? && /^\s*#{Regexp.escape(language.comment_symbols[:single_line])}/
    end

    def has_mlc?
      language.comment_symbols[:multiline] &&
          language.comment_symbols[:multiline][:begin] &&
          language.comment_symbols[:multiline][:end]
    end

    def mlcb_regex
      has_mlc? && /^\s*#{Regexp.escape(language.comment_symbols[:multiline][:begin])}/
    end

    def mlce_regex
      has_mlc? && /#{Regexp.escape(language.comment_symbols[:multiline][:end])}/
    end
  end
end
