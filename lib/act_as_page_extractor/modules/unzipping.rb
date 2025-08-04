module ActAsPageExtractor
 def unzip_document
    @document_path = @copy_document_path

    return if VALIDATE_DOC_TYPES.include?(@document_path.split('.').last&.downcase)

    if validate_compress_types
      result = TotalCompressor.decompress(@copy_document_path)
      if result[:success] && result[:files].length == 1
        origin_document_name = @origin_document_path.split("/").last.split('.').first
        unpacked_document = result[:files].first.split('/').last
        unpacked_document_format = unpacked_document.split('.').last
        @document_path = "#{@tmp_dir}/#{origin_document_name}.#{unpacked_document_format}"
        File.rename(result[:files].first, @document_path)
      end
    end
  end

  def validate_compress_types
    valid = VALIDATE_COMPRESS_TYPES.include?(@copy_document_path.split('.').last&.downcase)

    unless valid
      @page_extraction_state = EXTRACTING_STATES[:error_doctype]
      @pages_extraction_errors << "#{EXTRACTING_STATES[:error_doctype]} "
    end

    valid
  end
end
