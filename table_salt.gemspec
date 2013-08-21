# -*- encoding: utf-8 -*-
require File.expand_path('../lib/table_salt/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jason Harrelson"]
  gem.email         = ["cjharrelson@iberon.com"]
  gem.description   = %q{Provides ActiveRecord like functionality without a backing database table.}
  gem.summary       = %q{An extentions to provide ActiveRecord like functionality without a backing database table.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "table_salt"
  gem.require_paths = ["lib"]
  gem.version       = TableSalt::VERSION
end
