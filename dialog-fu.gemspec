require './lib/dialog'

spec = Gem::Specification.new do |s| 
  s.name = 'dialog-fu'
  s.version = Dialog::VERSION
  s.author = 'Chris Riddoch'
  s.email = 'riddochc@gmail.com'
  s.homepage = 'http://syntacticsugar.org/software/dialog-fu/'
  s.description = "A high-level API for simple user interfaces with dialog programs"
  s.license = 'LGPL-3.0'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Extracts information from tables in documents'
  s.files = Dir.glob("{docs,bin,lib,spec,templates,benchmarks}/**/*") +
            ['lgpl-3.0.txt', 'README.adoc', 'Rakefile', '.yardopts', __FILE__]
  s.require_paths = ['lib']
  s.has_rdoc = 'yard'
  s.extra_rdoc_files = ['README.adoc']
  s.required_ruby_version = '>= 2.0.0'
  s.add_development_dependency('rake', '~> 10.0', '>= 10.0.0')
  s.add_development_dependency('yard', '~> 0.8', '>= 0.8.7.3')
end

