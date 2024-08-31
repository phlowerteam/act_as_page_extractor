# GEM publishing

```sh
# Add features or fix bugs
# Increase version number x.y.z
# lib/act_as_page_extractor/version.rb
bundle update
rspec
# git commit & git push

gem build act_as_page_extractor.gemspec
gem install ./act_as_page_extractor-x.y.z.gem
gem push act_as_page_extractor-x.y.z.gem
```
