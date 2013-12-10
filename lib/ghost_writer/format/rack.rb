require 'multi_json'

module GhostWriter
  module Format
    module Rack
      def write_index_file
        rack = <<RUBY
require 'rack'

class DummyApp
  def call(env)
    request = Rack::Request.new(env)
    case [request.request_method, request.path_info]

RUBY
        documents.each do |output, docs|
          docs.each do |d|
            rack += <<RUBY
    when [#{d.request_method.inspect}, #{d.path_info.inspect}]
      if fuzzy_match(request.params, #{parameter_arranging(d.param_example.reject {|k, _| k == "format"}).inspect})
        [200, {"Content-Type" => #{d.content_type.inspect}}, [(<<BODY)]]
#{d.response_example}
BODY
      else
        [404, {"Content-Type" => "text/html"}, ['No match rule']]
      end
RUBY
          end
        end
        rack += <<RUBY
    else
      [404, {"Content-Type" => "text/html"}, ['No match rule']]
    end
  end

  def fuzzy_match(params, other)
    params.all? do |k, v|
      case v
      when Hash
        return false unless other[k].instance_of?(Hash)
        fuzzy_match(v, other[k])
      when Array
        return false unless other[k].instance_of?(Array)
        fuzzy_match_array(v, other[k])
      else
        v.to_s == other[k].to_s
      end
    end
  end

  def fuzzy_match_array(array, other)
    array.each_with_index.all? do |v, i|
      case v
      when Hash
        fuzzy_match(v, other[i])
      when Array
        fuzzy_match_array(v, other[i])
      else
        v.to_s == other[i].to_s
      end
    end
  end
end
RUBY
        File.open("#{output}.#{extname}", "w") do |f|
          f.write rack
        end

        configru = File.join(File.dirname(output), "config.ru")

        File.open(configru, "w") do |f|
          f.write "require_relative '#{File.basename(output)}'\n"
          f.write "run DummyApp.new"
        end
      end

      def write_file(overwrite = false)
      end

      def content_type
        if param_example["format"] == "json"
          "application/json; charset=UTF-8"
        else
          "text/html; charset=UTF-8"
        end
      end

      private

      def extname
        "rb"
      end

      def parameter_arranging(params)
        MultiJson.load(MultiJson.dump(params))
      end
    end
  end
end
