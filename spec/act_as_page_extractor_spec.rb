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
      it "extraction valid document #{document}" do
        book = Book.new({doc_path: document})
        allow(Book).to receive_message_chain('where') { [book] }
        ActAsPageExtractor.start_extraction
        expect(book.page_extraction_state).to eq ActAsPageExtractor::EXTRACTING_STATES[:extracted]
        expect(ExtractedPage.array.count).to eq 4
        expect(ExtractedPage.array[0][:page]).to match /on a tall column, stood the statue of the Happy Prince/
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
      'Oscar_Wilde_The_Happy_Prince_en.wrong',
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
