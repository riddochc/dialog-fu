
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name         'dialog_fu'
  authors      'Chris Riddoch'
  email        'riddochc@gmail.com'
  readme_file  'README.asciidoc'
  url          'https://github.com/riddochc/dialog-fu'
}

