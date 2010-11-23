require "haml"

module Murdoc
  class Formatter
    attr_accessor :template

    def initialize(template_or_filename)
      if File.exists?(template_or_filename)
        @template = File.read(template_or_filename)
      else
        @template = template_or_filename
      end
    end

    def render(locals = {})
      ::Haml::Engine.new(template).render(self, locals)
    end
  end
end