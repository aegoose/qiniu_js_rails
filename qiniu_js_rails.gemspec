# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "qiniu_js_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "qiniu_js_rails"
  s.version     = QiniuJsRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["aegoose"]
  s.email       = ["aegoose@126.com"]
  s.homepage    = "https://github.com/aegoose/qiniu_js_rails"
  s.summary     = "Integrate with qiniu ruby sdk, js sdk and plupload-rails"
  s.description = "Integrate with qiniu js sdk and plupload"
  s.license     = "MIT"

  # s.files = Dir["{app,config,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 5.0.2"
  s.add_dependency "plupload-rails"
  s.add_dependency "qiniu"

  s.add_development_dependency "sqlite3"

end
