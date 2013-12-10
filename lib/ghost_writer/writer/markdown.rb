require 'ghost_writer/writer/base'

class GhostWriter::Writer
  class Markdown < Base
    private

    def extname
      "md"
    end

    def template
      path = File.join(File.expand_path(File.dirname(__FILE__)), "templates", "markdown.erb")
      ERB.new(File.read(path))
    end
  end
end
