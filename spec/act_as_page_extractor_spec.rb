require 'spec_helper'
require 'act_as_page_extractor'

describe ActAsPageExtractor do
  context 'correct extraction' do
    [
      'test-doc-3-pages.docx',
      'test-doc-3-pages.doc',
      'test-doc-3-pages.pdf',
      'test-doc-3-pages.rtf',
      'test-doc-3-pages.odt',
      'test-doc-3-pages.html',
      'test-doc-3-pages.txt',
      'test-doc-3-pages.docx.zip',
      'test-doc-3-pages.docx.rar',
      'test-doc-3-pages.docx.7z'
    ].each do |document|
      it "extraction valid document #{document}" do
        book = Book.new({doc_path: document})
        allow(Book).to receive_message_chain('where') { [book] }
        ActAsPageExtractor.start_extraction
        expect(book.page_extraction_state).to eq ActAsPageExtractor::EXTRACTING_STATES[:extracted]
        expect(ExtractedPage.array.count).to eq 3
        expect(ExtractedPage.array[0][:page]).to match /require \'act_as_page_extractor\/modules\/interface\'/
        unless document.match /pdf/
          expect(book.pdf_path).to match /pdf/
          expect(book.remove_files.count).to eq 1
        end
        expect(ActAsPageExtractor.statistics).to include(supported_documents:  1)
      end
    end
  end

  context 'incorrect extraction' do
    [
      'test-doc-3-pages.wrong',
    ].each do |document|
      it "extraction invalid document #{document}" do
        book = Book.new({doc_path: document})
        allow(Book).to receive_message_chain('where') { [book] }
        ActAsPageExtractor.start_extraction
        expect(book.page_extraction_state).to eq ActAsPageExtractor::EXTRACTING_STATES[:'error.extraction']
      end
    end
  end
end
