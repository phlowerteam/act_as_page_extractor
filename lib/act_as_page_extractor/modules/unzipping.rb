module ActAsPageExtractor
 def unzip_document
    @document_path = @copy_document_path
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
end
