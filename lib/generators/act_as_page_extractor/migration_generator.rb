require 'rails/generators/active_record'
require 'rails/generators/base'

module ActAsPageExtractor
  module Generators # :nodoc:
    class MigrationGenerator < Rails::Generators::Base # :nodoc:
      include Rails::Generators::Migration

      argument :document_class, type: :string, default: 'Document'
      argument :additional_fields, type: :array, default: []

      def self.default_generator_root
        File.dirname(__FILE__)
      end

      def create_migration_file
        migration_template 'create_extracted_pages_table.rb.erb', "db/migrate/create_#{page_extractor_table_name}.rb"
        migration_template 'add_page_extractor_fields_to_documents.rb.erb', "db/migrate/add_page_extractor_fields_to_#{documents_table_name}.rb"
        template "extracted_page.rb.erb", "app/models/extracted_page.rb"
        template "act_as_page_extractor.rb.erb", "config/initializers/act_as_page_extractor.rb"
      end

      private

      def page_extractor_table_name
        'extracted_pages'
      end

      def migration_class_name_page_extractor
        "Create#{page_extractor_table_name.camelize}"
      end

      def documents_table_name
        document_class.underscore.pluralize
      end


      def migration_class_name_documents
        "AddPageExtractorFieldsTo#{document_class.pluralize}"
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
