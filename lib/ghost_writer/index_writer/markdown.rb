require 'ghost_writer/index_writer/base'

class GhostWriter::IndexWriter
  class Markdown < Base
    private

    def extname
      "md"
    end

    def template
      path = File.join(File.expand_path(File.dirname(__FILE__)), "templates", "markdown.erb")
      ERB.new(File.read(path), nil, "%-")
    end
  end
end
