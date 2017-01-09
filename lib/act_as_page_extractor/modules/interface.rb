module ActAsPageExtractor
  def origin_file_name
    self.send(:extracted_filename).url.to_s.split('/').last
  end

  def pdf_path
    if page_extraction_state == EXTRACTING_STATES[:extracted] && page_extraction_doctype&.downcase != 'pdf'
      "#{pdf_storage}/#{origin_file_name.split('.').first}.pdf"
    end
  end

  def remove_files
    FileUtils::rm_rf(pdf_path) if File.exists?(pdf_path.to_s)
  end

  def self.start_extraction
    document_class.where(page_extraction_state: EXTRACTING_STATES[:new]).each(&:page_extract!)
  end

  def self.statistics
    totals_documents = document_class.count
    supported_documents = document_class.where("page_extraction_doctype ILIKE ANY (array[#{VALIDATE_DOC_TYPES.map{|dt| '\'%'+dt+'%\''}.join(',')}])").count
    {
      total: totals_documents,
      supported_documents: supported_documents,
      unsupported_documents: totals_documents - supported_documents,
      states: EXTRACTING_STATES.map{|state, value| [ state, document_class.where(page_extraction_state: value).count] }.to_h,
    }
  end
end
