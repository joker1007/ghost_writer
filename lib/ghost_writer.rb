require "ghost_writer/version"
require "ghost_writer/document"
require "ghost_writer/document_index"
require "active_support/concern"

module GhostWriter
  extend ActiveSupport::Concern

  module Format
    autoload "Markdown", "ghost_writer/format/markdown"
    autoload "Rst", "ghost_writer/format/rst"
    autoload "Rack", "ghost_writer/format/rack"
  end

  DEFAULT_OUTPUT_DIR = "api_examples".freeze
  DEFAULT_FORMAT = :markdown
  DOCUMENT_INDEX_FILENAME = "document_index".freeze

  class << self
    attr_writer :output_dir, :output_flag, :output_format
    attr_accessor :github_base_url

    def document_group
      @document_group ||= {}
      @document_group
    end

    def generate_api_doc
      if output_flag
        unless File.exist?(output_path)
          FileUtils.mkdir_p(output_path)
        end
        document_index = GhostWriter::DocumentIndex.new(output_path + "#{DOCUMENT_INDEX_FILENAME}", document_group, GhostWriter.output_format)
        document_index.write_index_file
        document_group.each do |output, docs|
          docs.sort_by!(&:location)
          docs.shift.write_file(true)
          docs.each(&:write_file)
        end

        document_group.clear
      end
    end

    def output_flag
      !!(@output_flag ? @output_flag : ENV["GENERATE_API_DOC"])
    end

    def output_dir
      @output_dir ? @output_dir : DEFAULT_OUTPUT_DIR
    end

    def output_path
      Rails.root + "doc" + output_dir
    end

    def output_format
      @output_format || DEFAULT_FORMAT
    end
  end

  def collect_example
    output = File.join(doc_dir, "#{doc_name}")
    document = GhostWriter::Document.new(output, {
      title: "#{described_class} #{doc_name.titleize}",
      description: example.full_description.dup,
      location: example.location.dup,
      request_method: request.env["REQUEST_METHOD"],
      path_info: request.env["PATH_INFO"],
      param_example: controller.params.reject {|key, val| key == "controller" || key == "action"},
      status_example: response.status.inspect,
      response_example: response.body,
      format: GhostWriter.output_format
    })

    GhostWriter.document_group[output] ||= []
    GhostWriter.document_group[output] << document
  end

  private
  def doc_dir
    GhostWriter.output_path + described_class.to_s.underscore
  end

  def doc_name
    metadata = example.metadata[:generate_api_doc] || example.metadata[:ghost_writer]
    case metadata
    when String, Symbol
      example.metadata[:generate_api_doc].to_s
    else
      controller.action_name
    end
  end

  included do
    after do
      target_type = example.metadata[:type] == :controller || example.metadata[:type] == :request
      target_metadata = example.metadata[:generate_api_doc] || example.metadata[:ghost_writer]
      if target_type && target_metadata
        collect_example if GhostWriter.output_flag
      end
    end
  end
end
