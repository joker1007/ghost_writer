require 'ghost_writer/writer/base'

class GhostWriter::Writer
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
