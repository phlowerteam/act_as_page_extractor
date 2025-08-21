module ActAsPageExtractor
  def valid_document
    validate_size && validate_doc_types
  end

  def validate_size
    mb = 2**20
    valid = File.size(@copy_document_path) <= 1*mb

    unless valid
      @page_extraction_state = EXTRACTING_STATES[:error_filesize]
      @pages_extraction_errors << "#{EXTRACTING_STATES[:error_filesize]} "
    end

    valid
  end

  def validate_doc_types
    valid = VALIDATE_DOC_TYPES.include?(@document_path.split('.').last&.downcase)

    unless valid
      @page_extraction_state = EXTRACTING_STATES[:error_doctype]
      @pages_extraction_errors << "#{EXTRACTING_STATES[:error_doctype]} "
    end

    valid
  end
end
