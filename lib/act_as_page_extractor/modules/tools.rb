require 'timeout'

module ActAsPageExtractor
  # :nocov:
  def timeout_wrapper
    result = nil
    begin
      result = Timeout::timeout(60*5) { yield }
    rescue
    ensure
      result
    end
  end
  # :nocov:

  def is_extracted
    @pdf_pages.to_i > 0 && self.extracted_pages.count == @pdf_pages
  end

  def update_state
    updated_attributes = if is_extracted
      {
        page_extraction_state: EXTRACTING_STATES[:extracted],
        page_extraction_pages: @pdf_pages
      }
    else
      {
        page_extraction_state: EXTRACTING_STATES[:'error.extraction'],
        page_extraction_pages: 0
      }
    end.merge({
        page_extraction_doctype: @document_path&.split('.')&.last,
        page_extraction_filesize: Filesize.from("#{File.size(@document_path)} B").pretty
      })
    self.update_attributes(updated_attributes)
  end

  def cleanup_pages
    self.extracted_pages.destroy_all
  end

  # :nocov:
  def debug_info
    # ap "@tmp_dir"
    # ap @tmp_dir
    # ap "@copy_document_path"
    # ap @copy_document_path
    # ap "@document_path"
      # ap @document_path
    # ap "@pdf_path"
    # ap @pdf_path
    # ap "@pdf_pages"
      # ap @pdf_pages
  end
  # :nocov:
end
