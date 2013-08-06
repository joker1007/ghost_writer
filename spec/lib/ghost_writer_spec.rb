require "spec_helper"

class AnonymousController
end

describe GhostWriter do

  let(:group) do
    RSpec::Core::ExampleGroup.describe do
      include RSpec::Rails::ControllerExampleGroup
      include GhostWriter

      def described_class
        AnonymousController
      end

      controller do
        def index
          collection = [
            {
              id: 1,
              name: "name",
            },
            {
              id: 2,
              name: "name",
            },
          ]
          render json: collection.as_json
        end

        def show
          render json: {id: 1, name: "name"}
        end
      end

      describe "GET /anonymous" do
        it "first spec", generate_api_doc: true do
          begin
            get :index, param1: "value"
            response.should be_success
          rescue Exception => e
            p e
          end
        end

        it "second spec", generate_api_doc: true do
          begin
            get :index, param1: "value"
            response.should be_success
          rescue Exception => e
            p e
          end
        end
      end

      describe "GET /anonymous/1.json" do
        it "returns a Resource json", generate_api_doc: true do
          begin
            get :show, id: 1, format: :json, param1: "value", params2: ["value1", "value2"]
            response.should be_success
          rescue Exception => e
            p e
          end
        end
      end
    end
  end

  context "Not given output_dir" do
    before do
      GhostWriter.output_dir = nil
      clear_output("api_examples")
    end

    context 'ENV["GENERATE_API_DOC"] is true' do
      before do
        ENV["GENERATE_API_DOC"] = "1"
      end

      it "generate api doc file" do
        group.run(NullObject.new)
        GhostWriter.generate_api_doc
        File.exist?(Rails.root + "doc" + "api_examples" + "anonymous_controller" + "index.markdown").should be_true
        doc_body = File.read(Rails.root + "doc" + "api_examples" + "anonymous_controller" + "index.markdown")
        doc_body.should =~ /# AnonymousController Index/
        doc_body.should =~ /first spec/
        doc_body.should =~ /second spec/
      end

      context "Given github_base_url" do
        let(:github_base_url) { "https://github.com/joker1007/ghost_writer/tree/master/output_examples" }
        it "create index file written github links" do
          GhostWriter.github_base_url = github_base_url
          group.run(NullObject.new)
          GhostWriter.generate_api_doc
          File.read(Rails.root + "doc" + "api_examples" + "#{GhostWriter::DOCUMENT_INDEX_FILENAME}.#{GhostWriter.output_format}").should =~ /#{github_base_url}/
        end
      end
    end

    context 'ENV["GENERATE_API_DOC"] is false' do
      before do
        ENV["GENERATE_API_DOC"] = nil
      end

      it "does not generate api doc file" do
        group.run(NullObject.new)
        GhostWriter.generate_api_doc
        File.exist?(Rails.root + "doc" + "api_examples" + "anonymous_controller" + "index.markdown").should be_false
      end
    end
  end

  context "Given output_dir" do
    let(:output_dir) { "api_docs" }

    before do
      GhostWriter.output_dir = output_dir
      clear_output(output_dir)
    end

    after do
      GhostWriter.output_dir = nil
    end

    it "generate api doc file" do
      ENV["GENERATE_API_DOC"] = "1"
      group.run(NullObject.new)
      GhostWriter.generate_api_doc
      File.exist?(Rails.root + "doc" + output_dir + "anonymous_controller" + "index.markdown").should be_true
      File.read(Rails.root + "doc" + output_dir + "anonymous_controller" + "index.markdown").should =~ /# AnonymousController Index/
    end
  end

  def clear_output(dirname)
    if File.exist?(Rails.root + "doc" + dirname)
      FileUtils.rm_r(Rails.root + "doc" + dirname)
    end
  end
end
