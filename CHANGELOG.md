# Changelog

## [0.7.0] - 2025-08-21
### Added
- Breaking changes: added root folder as an option to access the folder between deployments, improved error processing ([883cafc], [b10a367])

HINT: to upgrade an older version, you need to fix the DB scheme and data migrations like this:
```rb
# db/migrate/20250804182426_upgrade_act_as_page_extractor_to_version.rb
class UpgradeActAsPageExtractorToVersion < ActiveRecord::Migration
  def change
    add_column :documents, :pages_extraction_errors, :string, default: ''
  end
end

# db/data/20250804183544_upgrade_act_as_page_extractor_to_version.rb
class UpgradeActAsPageExtractorToVersion < ActiveRecord::Migration
  def up
    Document
      .where(page_extraction_state: 'error.extraction')
      .update_all(page_extraction_state: 'error_extraction')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
```

## [0.6.0] - 2024-08-31
### Changed
- Upgraded to Ruby 3.2 minimal version ([4b463a1], [be52d9c])
- Upgraded to ActiveRecord >=6.x.x ([7881613], [48e6d8b], [8bd3707])
- Improved docs & Readme ([c405044], [6e895bb])

## [0.5.0] - 2024-08-30
### Changed
- Upgraded to ActiveRecord 6.0 ([9eea586])

## [0.2.3] - 2020-06-05
### Changed
- Upgraded to ActiveRecord-5.2.0 ([cde1f36])

## [0.2.2] - 2020-06-04
### Changed
- Upgraded to ActiveRecord-5.1.0 ([f6ea8d7])

## [0.2.1] - 2020-05-11
### Changed
- Upgraded to ActiveRecord-5.0.0 ([5c595ee], [3eb4ad7])

## [0.1.6] - 2020-05-10
### Changed
- Updated libraries ([eca4346]), ([7d3bb4f], [203c689], [171cf27])

## [0.1.2] - 2018-11-29
### Changed
- Updated rubyzip library ([38c4156])

## [0.1.1] - 2017-01-10
### Changed
- Removed code coverage from Rails generators ([a990357])

## [0.1.0] - 2017-01-09
### Added
- Initial commit ([47c0950], [5225f33])
- Fixed tests ([e68a6b7])
