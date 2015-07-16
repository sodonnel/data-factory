Gem::Specification.new do |s| 
  s.name = "data_factory"
  s.version = "0.3.0"
  s.author = "Stephen O'Donnell"
  s.email = "stephen@betteratoracle.com"
  s.homepage = "http://betteratoracle.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "A gem to generate template insert statements for use when unit testing database code"
  s.files = (Dir.glob("{test,lib}/**/*") + Dir.glob("[A-Z]*")).reject{ |fn| fn.include? "temp" }

  s.require_path = "lib"
  s.description  = "Generates data to insert into database tables, allowing columns to be defaulted or overriden. Intended to be used when testing wide tables where many not null columns may need to be populated but are not part of the test"
#  s.autorequire = "name"
#  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md"]
#  s.add_dependency("dependency", ">= 0.x.x")
end
