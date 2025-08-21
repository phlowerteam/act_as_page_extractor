require 'act_as_page_extractor/version'

require 'active_record'

require 'awesome_print'
require 'filesize'
require 'total_compressor'
require 'docsplit'
require 'pdf_utils'
require 'prawn'
require 'pdf-reader'

require 'act_as_page_extractor/modules/tools.rb'
require 'act_as_page_extractor/modules/validating.rb'
require 'act_as_page_extractor/modules/unzipping.rb'
require 'act_as_page_extractor/modules/extracting.rb'
require 'act_as_page_extractor/modules/saving.rb'

require 'act_as_page_extractor/modules/interface'

module ActAsPageExtractor
  extend ActiveSupport::Concern

  DEFAULT_ROOT_FOLDER = Dir.pwd.to_s
  ERRORS = {
    unknown_docsplit_error: 'Unknown Docsplit error'
  }.freeze
  ERROR_BACKTRACE_LINES = 15
  EXTRACTING_STATES = {
    new: 'new',
    extracting: 'extracting',
    extracted: 'extracted',
    error_doctype: 'error_doctype',
    error_extraction: 'error_extraction',
    error_filesize: 'error_filesize'
  }.freeze
  EXTRACTION_TIMEOUT = 60*5 # 5 minutes
  VALIDATE_COMPRESS_TYPES = ['zip', 'rar', '7z', 'gzip'].freeze
  VALIDATE_DOC_TYPES = ['txt', 'pdf', 'doc', 'docx',
                        'rtf', 'odt', 'htm', 'html'].freeze

  included do
    before_create { self.page_extraction_state = EXTRACTING_STATES[:new] }
    before_destroy :remove_files
  end

  module ClassMethods
    def act_as_page_extractor(options: {})
      define_method(:save_as_pdf){|*args| options[:save_as_pdf] }
      define_method(:extracted_filename){|*args| self.send(options[:filename].to_sym) }
      ActAsPageExtractor.define_singleton_method(:extracted_filename) {|*args| options[:filename] }
      ActAsPageExtractor.define_singleton_method(:document_class) {|*args| Object.const_get(options[:document_class]) }
      define_method(:extracted_document_id){|*args| options[:document_id] }
      define_method(:additional_fields){|*args| options[:additional_fields] || [] }
      define_method(:root_folder){|*args| options[:root_folder] || DEFAULT_ROOT_FOLDER }
      define_method(:file_storage){|*args| options[:file_storage] || "#{root_folder}/public".freeze }
      define_method(:pdf_storage){|*args| options[:pdf_storage] || "#{file_storage}/uploads/extracted/pdf".freeze }
      define_method(:tmp_extraction_file_storage){|*args| "#{root_folder}/tmp/page_extraction" }
    end
  end

  def initialized
    @page_extraction_state = nil
    @pages_extraction_errors = ''
    # add all need callbacks
      #on destroy remove pdf

    #Add to Readme!!
    #rails g act_as_page_extractor:migration Document category_id user_id
    # add to [Document] model:
    # has_many :extracted_pages, dependent: :destroy
    create_pdf_dir
  end

  def page_extract!
    initialized
    cleanup_pages
    create_tmp_dir
    begin
      copy_document
      unzip_document
      if valid_document
        extract_pages
        save_to_db
      end
    ensure
      update_state
      save_pdf
      debug_info
      finish
    end
  end

  private

  def create_pdf_dir
    if save_as_pdf
      FileUtils::mkdir_p(pdf_storage) unless File.exist?(pdf_storage)
    end
  end

  def create_tmp_dir
    @tmp_dir = "#{tmp_extraction_file_storage}/#{SecureRandom.hex(6)}"
    FileUtils::mkdir_p(@tmp_dir) unless File.exist?(@tmp_dir)
  end

  def copy_document
    @origin_document_path = "#{file_storage}#{self.send(:extracted_filename).url.to_s}"
    FileUtils.cp(@origin_document_path, @tmp_dir)
    @copy_document_path = "#{@tmp_dir}/#{@origin_document_path.split("/").last}"
    @document_filename = @origin_document_path.split("/").last
  end

  def finish
    remove_tmp_dir
  end

  def remove_tmp_dir
    FileUtils.rm_rf(@tmp_dir) if @tmp_dir =~ /\/tmp\//
  end
end

# rails g model ExtractedPage page:text document_id:integer category_id:integer page_number:integer

# Rails 4 way
# 9.2.7.1 Multiple Callback Methods in One Class
# 258 page

# class ActiveRecord::Base
#   def self.acts_as_page_extractor(document_field=:filename)
#     auditor = Auditor.new(audit_log)
#     after_create auditor
#     after_update auditor
#     after_destroy auditor
#   end
# end
