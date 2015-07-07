require 'strscan'

module Murdoc
  class Scanner
    attr_reader :language

    def initialize(language)
      @language = language
    end

    def call(source, do_not_count_comment_lines = false)
      paragraphs = []
      ss = StringScanner.new(source)
      line = i = src_line = 0

      loop do
        comment_lines = []
        code_lines = []

        # Multi line comments
        if has_mlc?
          while (ss.scan(mlcb_regex))
            comment = ''

            while (!ss.eos? && !ss.match?(/.*#{mlce_regex}/))
              i += 1
              comment << ss.scan(/.*?$/)
              comment << ss.getch.to_s
            end

            if (fragment = ss.scan(/.*#{mlce_regex}/))
              comment << fragment.sub(mlce_regex, '')
            end

            ss.scan(/[ \t]*\n/) # skip trailing whitespace and a newline
            comment_lines << remove_common_space_prefix(comment)
          end
        end

        # Single line comments
        if has_slc?
          while (ss.scan(slc_regex))
            comment = ''
            comment << ss.scan(/.*?$/)
            comment << ss.getch.to_s
            comment_lines << comment
            i += 1
          end
        end


        # Code
        empty_leading_lines_count = skip_empty_lines(ss)
        i += empty_leading_lines_count
        src_line += empty_leading_lines_count

        line = do_not_count_comment_lines ? src_line : i
        while (!comment_start?(ss) && !ss.eos?)
          code = ss.scan(/^.*?$/)
          code << ss.getch.to_s
          code_lines << code
          i += 1
          src_line += 1
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
      code.rstrip
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
      lines.delete_at(0) while lines[0] && lines[0].empty?
      lines.delete_at(-1) while lines[-1] && lines[-1].empty?

      prefix_lengths =  lines.map {|l| l.match(/^( *)/)[1].length }.reject(&:zero?)
      prefix = ' ' * (prefix_lengths.min || 0)
      lines.map {|line| line.sub(/^#{prefix}/, '') }.join("\n")
    end

    def has_slc?
      !!language.comment_symbols[:single_line]
    end

    def slc_regex
      return @slc_regex unless @slc_regex.nil?
      @slc_regex = has_slc? && /^[ \t]*#{Regexp.escape(language.comment_symbols[:single_line])}/
    end

    def has_mlc?
      language.comment_symbols[:multiline] &&
          language.comment_symbols[:multiline][:begin] &&
          language.comment_symbols[:multiline][:end]
    end

    def mlcb_regex
      has_mlc? && /^[ \t]*#{Regexp.escape(language.comment_symbols[:multiline][:begin])}/
    end

    def mlce_regex
      has_mlc? && /#{Regexp.escape(language.comment_symbols[:multiline][:end])}/
    end
  end
end
