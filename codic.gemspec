# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codic/version'

Gem::Specification.new do |gem|
  gem.name          = "codic"
  gem.version       = Codic::VERSION
  gem.authors       = ["Keisuke KITA"]
  gem.email         = ["kei.kita2501@gmail.com"]
  gem.description   = %q{simple access codic via terminal}
  gem.summary       = %q{simple access codinc via terminal}
  gem.homepage      = "https://github.com/kitak/codic"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'nokogiri'
end
