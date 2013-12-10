require 'ghost_writer/index_writer/base'

class GhostWriter::IndexWriter
  class Rst < Base
    private

    def extname
      "rst"
    end

    def template
      path = File.join(File.expand_path(File.dirname(__FILE__)), "templates", "rst.erb")
      ERB.new(File.read(path), nil, "%-")
    end
  end
end
