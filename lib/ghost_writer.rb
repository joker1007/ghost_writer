require 'rspec/rails'
require "ghost_writer/version"
require "ghost_writer/document"
require "ghost_writer/document_index"
require "active_support/concern"
require "multi_json"

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
        unless File.exist?(output_dir)
          FileUtils.mkdir_p(output_dir)
        end
        document_index = GhostWriter::DocumentIndex.new(output_dir + "#{DOCUMENT_INDEX_FILENAME}", document_group, GhostWriter.output_format)
        document_index.write_file(format: output_format)
        document_group.each do |output, docs|
          docs.sort_by!(&:location)
          initial = docs.shift
          initial.header = true
          initial.write_file(format: output_format, overwrite: true)
          docs.each {|d| d.write_file(format: output_format) }
        end

        document_group.clear
      end
    end

    def output_flag
      !!(@output_flag ? @output_flag : ENV["GENERATE_API_DOC"])
    end

    def output_dir
      @output_dir ? Pathname(@output_dir) : Pathname(DEFAULT_OUTPUT_DIR)
    end

    def output_format
      @output_format || DEFAULT_FORMAT
    end
  end

  def collect_example(example)
    output = doc_dir + doc_name(example)
    document = GhostWriter::Document.new(output, {
      title: "#{described_class} #{doc_name(example).titleize}",
      description: example.full_description.dup,
      location: example.location.dup,
      request_method: request.env["REQUEST_METHOD"],
      path_info: request.env["PATH_INFO"],
      param_example: controller.params.reject {|key, val| key == "controller" || key == "action"},
      status_code: response.status,
      response_body: response.body,
      format: GhostWriter.output_format
    })

    GhostWriter.document_group[output] ||= []
    GhostWriter.document_group[output] << document
  end

  private
  def doc_dir
    GhostWriter.output_dir + described_class.to_s.underscore
  end

  def doc_name(example)
    metadata = example.metadata[:generate_api_doc] || example.metadata[:ghost_writer]
    case metadata
    when String, Symbol
      example.metadata[:generate_api_doc].to_s
    else
      controller.action_name
    end
  end

  included do
    after do |example_or_group|
      example = example_or_group.is_a?(RSpec::Core::Example) ?
        example_or_group :
        example_or_group.example
      target_type = example.metadata[:type] == :controller || example.metadata[:type] == :request
      target_metadata = example.metadata[:generate_api_doc] || example.metadata[:ghost_writer]
      if target_type && target_metadata
        collect_example(example) if GhostWriter.output_flag
      end
    end
  end
end
