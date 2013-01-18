require "ghost_writer/version"
require "ghost_writer/document"
require "ghost_writer/document_index"
require "active_support/concern"

module GhostWriter
  extend ActiveSupport::Concern

  module Format
    autoload "Markdown", "ghost_writer/format/markdown"
  end

  DOCUMENT_INDEX_FILENAME = "document_index.markdown"

  class << self
    attr_accessor :output_dir, :github_base_url

    def documents
      @documents ||= []
      @documents
    end

    def generate_api_doc
      if ENV["GENERATE_API_DOC"]
        unless File.exist?(output_path)
          FileUtils.mkdir_p(output_path)
        end
        document_index = GhostWriter::DocumentIndex.new(output_path + DOCUMENT_INDEX_FILENAME, documents)
        document_index.write_file
        @documents.sort_by{|d| d.description}.each(&:write_file)
        @documents.clear
      end
    end

    def output_path
      output_dir ? Rails.root + "doc" + output_dir : Rails.root + "doc" + "api_examples"
    end
  end

  def collect_example
    document = GhostWriter::Document.new(File.join(doc_dir, "#{doc_name}.markdown"), {
      title: "#{described_class} #{doc_name.titleize}",
      description: example.full_description.dup,
      location: example.location.dup,
      url_example: "#{request.env["REQUEST_METHOD"]} #{request.env["PATH_INFO"]}",
      param_example: controller.params.reject {|key, val| key == "controller" || key == "action"},
      status_example: response.status.inspect,
      response_example: response.body,
    })
    GhostWriter.documents << document
  end

  private
  def doc_dir
    GhostWriter.output_path + described_class.to_s.underscore
  end

  def doc_name
    if example.metadata[:generate_api_doc].is_a?(String) || example.metadata[:generate_api_doc].is_a?(Symbol)
      example.metadata[:generate_api_doc].to_s
    else
      controller.action_name
    end
  end

  included do
    after do
      if example.metadata[:type] == :controller && example.metadata[:generate_api_doc]
        collect_example if ENV["GENERATE_API_DOC"]
      end
    end
  end
end
