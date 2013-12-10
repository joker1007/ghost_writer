require 'ghost_writer/index_writer/base'

class GhostWriter::IndexWriter
  class Rack < Base
    def write_file
      unless File.exist?(File.dirname(@document_index.basename))
        FileUtils.mkdir_p(File.dirname(@document_index.basename))
      end

      File.open(app_path, "w") do |f|
        f.write template.result(@document_index.instance_eval { binding })
      end

      File.open(configru_path, "w") do |f|
        f.write "require_relative 'mock_server'\n"
        f.write "run MockServer.new"
      end
    end

    private

    def app_path
      File.join(File.dirname(@document_index.basename), "mock_server.rb")
    end

    def configru_path
      File.join(File.dirname(@document_index.basename), "config.ru")
    end

    def extname
      "rb"
    end

    def template
      path = File.join(File.expand_path(File.dirname(__FILE__)), "templates", "rack.erb")
      ERB.new(File.read(path), nil, "%-")
    end
  end
end
