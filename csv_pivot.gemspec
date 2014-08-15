# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csv_pivot/version'

Gem::Specification.new do |spec|
  spec.name          = "csv_pivot"
  spec.version       = CsvPivot::VERSION
  spec.authors       = ["Knut Knutson"]
  spec.summary       = %q{Pivots an row major ordered array or csv file and returns an array or csv file.}
  spec.homepage      = "https://github.com/KnutKnutson/csv_pivot"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
