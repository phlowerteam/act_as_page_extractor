module ActAsPageExtractor
  def extract_pages
    convert_to_pdf
    convert_to_text
  end

  def convert_to_pdf
     @pdf_path = if 'pdf' == @document_path.split('.').last.downcase
       @document_path
     else
      if timeout_wrapper{ Docsplit.extract_pdf(@document_path, output: @tmp_dir)}
        pdf_path = (@document_path.split('.')[0..-2] + ['pdf']).join('.')
        pdf_path if File.exists?(pdf_path)
      end
    end
  end

  def convert_to_text
    begin
      @pdf_pages = PdfUtils.info(@pdf_path).pages
      if @pdf_pages
        if timeout_wrapper{ Docsplit::extract_text(@pdf_path, ocr: false, pages: 'all', output: @tmp_dir) }
        else
          # :nocov:
          @pdf_pages = nil
          raise
          # :nocov:
        end
      end
    # :nocov:
    rescue
    end
    # :nocov:
  end
end
