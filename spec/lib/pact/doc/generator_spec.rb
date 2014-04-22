require 'spec_helper'
require 'pact/doc/generator'
require 'fileutils'

module Pact
  module Doc
    describe Generator do

      let(:doc_dir) { './tmp/doc' }
      let(:pact_dir) { './tmp/pacts' }
      let(:file_name) { "Some Consumer - Some Provider#{file_extension}" }
      let(:interactions_renderer) { double("InteractionsRenderer", :call => doc_content) }
      let(:doc_content) { "doc_content" }
      let(:index_content) { "index_content" }
      let(:expected_doc_path) { "#{doc_dir}/#{doc_type}/#{file_name}" }
      let(:expected_index_path) { "#{doc_dir}/#{doc_type}/#{index_name}#{file_extension}" }
      let(:doc_type) { 'markdown' }
      let(:file_extension) { ".md" }
      let(:actual_file_contents) { File.read(expected_doc_path) }
      let(:actual_index_contents) { File.read(expected_index_path)}
      let(:index_renderer) { double("IndexRenderer", :call => index_content)}
      let(:index_name) { 'README' }
      let(:after_hook) { double("hook", :call => nil)}

      before do
        FileUtils.rm_rf doc_dir
        FileUtils.rm_rf pact_dir
        FileUtils.mkdir_p doc_dir
        FileUtils.mkdir_p pact_dir
        FileUtils.cp './spec/support/markdown_pact.json', pact_dir
      end

      let(:options) { { interactions_renderer: interactions_renderer, doc_type: doc_type, file_extension: file_extension, index_renderer: index_renderer, index_name: index_name } }

      subject { Generator.new(pact_dir, doc_dir, options) }

      it "creates an index" do
        expect(index_renderer).to receive(:call).with("Some Consumer", {"Some Provider"=>"Some Consumer - Some Provider.md"})
        subject.call
        expect(actual_index_contents).to eq(index_content)
      end

      it "creates documentation" do
        subject.call
        expect(actual_file_contents).to eq(doc_content)
      end

      context "with an after hook specified" do

        subject { Generator.new(pact_dir, doc_dir, options.merge(:after => after_hook)) }

        it "executes the hook" do
          expect(after_hook).to receive(:call).with(pact_dir, "#{doc_dir}/#{doc_type}", instance_of(Array))
          subject.call
        end

        it "passes in the consumer_contracts" do
          expect(after_hook).to receive(:call) do | _, _, consumer_contracts |
            expect(consumer_contracts.first).to be_instance_of(Pact::ConsumerContract)
          end
          subject.call
        end

      end


    end
  end
end