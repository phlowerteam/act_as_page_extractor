act_as_page_extractor
================

A library that extracts plain text from documents for subsequent processing, such as indexing and search.

## Installation

Install all dependencies before use:
```sh
sh Aptfile.sh
```

Add this to your Gemfile:
```rb
gem 'act_as_page_extractor'
```
## Usage

Generate a migration, for example for a Document model:
```sh
rails g act_as_page_extractor:migration Document category_id user_id
```

This will generate two migration files:
```rb
class AddPageExtractorFields < ActiveRecord::Migration
  def change
    add_column :documents, :page_extraction_state, :string, default: ''
    add_column :documents, :page_extraction_pages, :integer, default: 0
    add_column :documents, :page_extraction_doctype, :string, default: ''
    add_column :documents, :page_extraction_filesize, :string, default: ''
    add_column :documents, :pages_extraction_errors, :string, default: ''
  end
end

class CreateExtractedPages < ActiveRecord::Migration
  def change
    create_table :extracted_pages do |t|
      t.text :page
      t.integer :document_id
      t.integer :category_id
      t.integer :user_id
      t.integer :page_number

      t.timestamps null: false
    end

    add_index :extracted_pages, :document_id
    add_index :extracted_pages, :category_id
    add_index :extracted_pages, [:document_id, :category_id]
    add_index :extracted_pages, [:document_id, :page_number]
  end
end
```

Model Document must have field which contains path to file(supports [different archive types](https://github.com/phlowerteam/total_compressor) that contains [txt, pdf, doc/x, txt, html, rtf, ...](https://docs-old.exoplatform.org/public/index.jsp?topic=%2FPLF41%2FPLFAdminGuide.Configuration.JODConverter.html))

Add to model next parameters for initializing:

```rb
  class Document < ActiveRecord::Base
    include ActAsPageExtractor

    act_as_page_extractor options: {
      document_class:    'Document',
      save_as_pdf:       true, # store converted document as PDF
      filename:          :filename,
      document_id:       :document_id,
      additional_fields: [:category_id, :user_id], # copy values of these fields from document to extracted_page
      root_folder:       Rails.root.to_s, # or "/full/path/to/project", it needs to share folder between deployments
      # file_storage:      "/full/path/to/project/public/uploads/documents/storage" # optional
      # pdf_storage:       "/full/path/to/project/public/uploads/extracted/pdf/storage" # optional
    }

    has_many :extracted_pages, dependent: :destroy
end
```

The instance now provides several new methods:
```rb
document = Document.first
document.page_extract!
document.extracted_pages
document.pdf_path # if option 'save_as_pdf' is 'true'

# Access to pages
ExtractedPage.count

# Importing whole directory of documents
ActAsPageExtractor.import_files('/path/to/foler/with/documents')

# We can use cron for run the processing of all the new documents
ActAsPageExtractor.start_extraction

# Getting statistics information of all documents
ActAsPageExtractor.statistics
```

Parameters of initializing **act_as_page_extractor**:

* **document_class** — The name of the model (e.g., `Document`).
* **save_as_pdf** — Boolean (`true`/`false`). Indicates whether to save a temporary PDF.
* **filename** — The field containing access to the file. This should be an object with a `url` method that returns the file path (e.g., a CarrierWave object with `filename.url`).
* **document_id** — The field name for storing the document ID.
* **additional_fields** — Extra fields to be added to the extracted page (useful for indexing, etc.).
* **root_folder** — The root folder to be shared across deployments (e.g., `Rails.root.to_s`).
* **file_storage** — Path for saving temporary files (default: `"public"`).
* **pdf_storage** — Path for saving PDFs (default: `"public/uploads/extracted/pdf"`).

## Run tests
```sh
bundle
rspec
```

## Contacts
https://github.com/phlowerteam / phlowerteam[A]gmail.com

## License

MIT License © 2025 PhlowerTeam
