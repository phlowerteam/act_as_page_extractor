require 'act_as_page_extractor'

class Filename
  attr_accessor :url
  def initialize(params)
    @url = params[:url]
  end
end

class Book
  cattr_accessor :id,
                :category_id,
                :user_id,
                :page_extraction_state,
                :page_extraction_pages,
                :page_extraction_doctype,
                :page_extraction_filesize,
                :pages_extraction_errors

  def self.before_create &block
    yield
  end

  def self.before_destroy *args
  end

  def self.count
    1
  end

  include ActAsPageExtractor

  act_as_page_extractor options: {
    document_class:    'Book',
    save_as_pdf:       true,
    filename:          :filename, # CarrierWave class with 'filename.url' method
    document_id:       :document_id,
    additional_fields: [:category_id, :user_id],
    root_folder:       Dir.pwd.to_s,
    file_storage:      "#{Dir.pwd}/test/",
    pdf_storage:       "#{Dir.pwd}/test/uploads/extracted/pdf"
  }

  def initialize(params)
    @doc_path = params[:doc_path]
    @id = @category_id = @user_id = nil
    @page_extraction_state = @page_extraction_pages = nil
    @page_extraction_doctype = @page_extraction_filesize = nil
    @pages_extraction_errors = ''
    ExtractedPage.cleanup
  end

  def filename
    Filename.new(url: @doc_path)
  end

  def extracted_pages
    array ||= ExtractedPage.array

    def array.destroy_all
    end

    array
  end

  def update params
    params.each do |key, value|
      if value.nil?
        instance_eval("self.#{key} = nil")
      elsif value.class == String
        instance_eval("self.#{key} = \"#{value}\"")
      else
        instance_eval("self.#{key} = #{value}")
      end
    end
  end
end

class ExtractedPage
  attr_accessor :id, :page, :document_id, :category_id, :page_number, :user_id

  def document
  end

  def self.transaction &block
    yield
  end

  def self.create params
    @@array ||= []
    @@array << params
  end

  def self.array
    @@array ||= []
  end

  def self.cleanup
    @@array = []
  end
end
