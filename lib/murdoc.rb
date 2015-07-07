#
# Murdoc is *yet another* Doccu-like documentation generator.
# Murdoc reads ruby source files and produces annotated html documentation.
#
# See also: [Docco][do], [Rocco][ro]
#
# [do]: "http://jashkenas.github.com/docco/"
# [ro]: "http://rtomayko.github.com/rocco"
#


module Murdoc
  def self.generate_from_file(input, output, options = {})
    options = default_options.merge(options)
    annotator = Annotator.from_file(input, nil, options)
    File.open(output, "w+") do |f|
      f.puts Formatter.new(options[:template]).render(:paragraphs => annotator.paragraphs,
                                                      :stylesheet => File.read(options[:stylesheet]))
    end
  end

  def self.generate_from_multiple_files(input_files, output, options = {})
    options = default_options_for_multiple_files.merge(options)
    annotators = input_files.map {|fn| Annotator.from_file(fn, nil, options) }
    File.open(output, "w+") do |f|
      f.puts Formatter.new(options[:template]).render(:annotators => annotators,
                                                      :filenames => input_files,
                                                      :stylesheet => File.read(options[:stylesheet]))
    end
  end

  def self.default_options
    @@options ||= {
        :template =>   "#{markup_dir}/template.haml",
        :stylesheet => "#{markup_dir}/stylesheet.css"
    }
  end

  def self.default_options_for_multiple_files
    @@options ||= {
        :template =>   "#{markup_dir}/template_multifile.haml",
        :stylesheet => "#{markup_dir}/stylesheet.css"
    }
  end

  def self.markup_dir
    File.expand_path("../..", __FILE__)+ "/markup"
  end
end

require "murdoc/annotator"
require "murdoc/scanner"
require "murdoc/paragraph"
require "murdoc/formatter"
require "murdoc/languages/base"
require "murdoc/languages/html"
require "murdoc/languages/javascript"
require "murdoc/languages/ruby"
