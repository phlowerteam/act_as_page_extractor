module ActAsPageExtractor
  def save_pdf
    if save_as_pdf &&
       is_extracted &&
       @document_path.split('.').last&.downcase != 'pdf'

      if @pdf_path
        FileUtils.cp(@pdf_path, pdf_storage)
      end
    end
  end

  def save_to_db
    self.update(page_extraction_state: EXTRACTING_STATES[:extracting])
    ExtractedPage.transaction do
      @pdf_pages&.times&.each do |pdf_page|
        page_filename = "#{@tmp_dir}/#{@document_filename.split('.').first}_#{(pdf_page + 1).to_s}.txt"
        remove_last_byte(page_filename)
        content = IO.read(page_filename).delete("<" ">" "&" "\u0001" "\u25A0" "\a")

        page_attributes = {
          page:        content,
          page_number: pdf_page + 1
        }

        page_attributes[extracted_document_id] = self.id

        additional_fields.each do |additional_field|
          page_attributes[additional_field] = self.send(additional_field.to_sym)
        end

        ExtractedPage.create(page_attributes)
      end
    end
  end

  #fix for openoffice/jodconverter: delete last ugly byte in converted text page
  def remove_last_byte(file_name)
    file = File.new(file_name, 'a+')
    if file.size > 0
      file.seek(file.size - 1)
      last_byte = file.getc
      file.truncate(file.size - 1) if last_byte == "\f"
    end
    file.close
  end
end
