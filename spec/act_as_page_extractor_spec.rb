require 'spec_helper'
require 'act_as_page_extractor'

describe ActAsPageExtractor do
  context 'correct extraction' do
    [
      'Oscar_Wilde_The_Happy_Prince_en.docx',
      'Oscar_Wilde_The_Happy_Prince_en.doc',
      'Oscar_Wilde_The_Happy_Prince_en.pdf',
      'Oscar_Wilde_The_Happy_Prince_en.rtf',
      'Oscar_Wilde_The_Happy_Prince_en.odt',
      'Oscar_Wilde_The_Happy_Prince_en.html',
      'Oscar_Wilde_The_Happy_Prince_en.txt',
      'Oscar_Wilde_The_Happy_Prince_en.docx.zip',
      'Oscar_Wilde_The_Happy_Prince_en.docx.rar',
      'Oscar_Wilde_The_Happy_Prince_en.docx.7z'
    ].each do |document|
      it "extracts valid document #{document}" do
        book = Book.new({doc_path: document})
        allow(Book).to receive_message_chain('where') { [book] }
        ActAsPageExtractor.start_extraction
        expect(book.page_extraction_state).to eq ActAsPageExtractor::EXTRACTING_STATES[:extracted]
        expect(ExtractedPage.array.count).to eq 4
        expect(ExtractedPage.array[0][:page]).to match /on a tall column, stood the statue of the Happy Prince/
        unless document.match /pdf/
          expect(book.pdf_path).to match /pdf/
          expect(book.remove_files.count).to eq 1
          expect(book.pages_extraction_errors).to be_empty
        end
        expect(ActAsPageExtractor.statistics).to include(supported_documents:  1)
      end
    end
  end

  describe 'errors processing' do
    let(:book) { Book.new({doc_path: document}) }

    before do
      allow(Book).to receive_message_chain('where') { [book] }
    end

    context 'when invalid doctype' do
      let(:document) { 'Oscar_Wilde_The_Happy_Prince_en.wrong' }

      it "logs invalid doctype" do
        ActAsPageExtractor.start_extraction
        expect(book.page_extraction_state).to eq 'error_doctype'
        expect(book.pages_extraction_errors).to match('error_doctype')
      end
    end

    context 'with extraction timeout' do
      let(:error_msg) { 'execution expired' }
      let(:document) { 'Oscar_Wilde_The_Happy_Prince_en.docx' }

      before do
        allow(Docsplit).to receive(:extract_pdf).and_raise(Timeout::Error.new(error_msg))
      end

      it "logs timeout error" do
        ActAsPageExtractor.start_extraction
        expect(book.page_extraction_state).to eq 'error_extraction'
        expect(book.pages_extraction_errors).to match(error_msg)
      end
    end

    context 'when Docsplit returns failure' do
      let(:error_msg) { 'Unknown Docsplit error' }
      let(:document) { 'Oscar_Wilde_The_Happy_Prince_en.docx' }

      before do
        allow(Docsplit).to receive(:extract_pdf).and_raise(Timeout::Error.new(error_msg))
        allow(Docsplit).to receive(:extract_text).and_raise(Timeout::Error.new(error_msg))
      end

      it "logs Docsplit error" do
        ActAsPageExtractor.start_extraction
        expect(book.page_extraction_state).to eq 'error_extraction'
        expect(book.pages_extraction_errors).to match(error_msg)
      end
    end
  end
end
