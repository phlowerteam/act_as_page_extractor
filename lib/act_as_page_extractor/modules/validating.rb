module ActAsPageExtractor
  VALIDATE_COMPRESS_TYPES = ['zip', 'rar', '7z', 'gzip'].freeze
  VALIDATE_DOC_TYPES = ['txt', 'pdf', 'doc', 'docx',
                        'rtf', 'odt', 'htm', 'html'].freeze

  def valid_document
    validate_size && validate_doc_types
  end

  def validate_size
    mb = 2**20
    File.size(@copy_document_path) <= 1*mb
  end

  def validate_compress_types
    VALIDATE_COMPRESS_TYPES.include?(@copy_document_path.split('.').last&.downcase)
  end

  def validate_doc_types
    VALIDATE_DOC_TYPES.include?(@document_path.split('.').last&.downcase)
  end
end
