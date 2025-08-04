act_as_page_extractor
================

Library for extracting plain text from documents(files) for further processing (indexing and searching).

## Installation

Install appropriate tools before using:

```sh
# Packages for decompression documents by this tool https://github.com/phlowerteam/total_compressor
sudo apt-get install -y zlib1g zlib1g-dev zip rar p7zip-full

# Packages for parsing documents by this util https://documentcloud.github.io/docsplit from the LibreOffice package
sudo apt-get install -y \
  jodconverter \
  nautilus-filename-repairer python3-chardet xfonts-encodings libfontenc1 console-setup \
  fontconfig fontconfig-config fonts-kacst fonts-kacst-one fonts-khmeros-core fonts-lao \
  fonts-liberation fonts-nanum fonts-opensymbol fonts-sil-gentium-basic fonts-takao-pgothic \
  fonts-thai-tlwg fonts-tlwg-garuda fonts-tlwg-kinnari fonts-tlwg-loma fonts-tlwg-mono \
  fonts-tlwg-norasi fonts-tlwg-purisa fonts-tlwg-sawasdee fonts-tlwg-typewriter fonts-tlwg-typist \
  fonts-tlwg-typo fonts-tlwg-umpush fonts-tlwg-waree fonts-ubuntu fonts-wqy-microhei \
  gnome-font-viewer gsfonts gucharmap kbd libfontconfig1 libfontenc1 libfreetype6 libxft2 \
  x11-xfs-utils xfonts-base xfonts-encodings xfonts-scalable xfonts-utils
```

Add this line to your application's Gemfile:

```rb
gem 'act_as_page_extractor'
```
## Usage

For example, for model Document in the Rails framework we need run:

```sh
rails g act_as_page_extractor:migration Document category_id user_id
```

As a result we get two migration files:
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
      save_as_pdf:       true,
      filename:          :filename,
      document_id:       :document_id,
      additional_fields: [:category_id, :user_id],
      root_folder:       "/full/path/to/project" || Rails.root.to_s,
      # file_storage:      "/full/path/to/project/public/uploads/documents/storage",
      # pdf_storage:       "/full/path/to/project/public/uploads/extracted/pdf/storage"
    }

    has_many :extracted_pages, dependent: :destroy
end
```

Now our instance has few new methods:

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

* **document_class** - name of model (e.g. Document)
* **save_as_pdf** - boolean [true, false] when we want save temporary pdf
* **filename** - name of field which contains access to the file and it should be an object with 'url' method that returns path to file (e.g. CarrierWave object with 'filename.url')
* **document_id** - name for saving id
* **additional_fields** - additional fields that added to extracted page (e.g. for indexing, etc.)
* **file_storage** - path for saving tmp files (by default it is "public")
* **pdf_storage** - path for saving pdf (by default it is "public/uploads/extracted/pdf")

## Run tests
```sh
bundle install
rspec
```
## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contacts
https://github.com/phlowerteam
phlowerteam@gmail.com

## License

MIT License © 2025 PhlowerTeam
