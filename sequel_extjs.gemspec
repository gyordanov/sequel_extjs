Gem::Specification.new do |s|
  s.name     = "sequel_extjs"
  s.version  = "0.1"
  s.date     = "2008-12-10"
  s.summary  = "Transform Sequel Datasets to ExtJS JsonStore feed"
  s.email    = "gyordanov@gmail.com"
  s.homepage = "http://github.com/gyordanov/sequel_extjs"
  s.description = "Transform Sequel Dataset to ExtJS JsonStore feed"
  s.has_rdoc = true
  s.authors  = ["Galin Yordanov"]
  s.files    = ["CHANGELOG.rdoc",
    "README.rdoc",
    "Rakefile",
    "sequel_extjs.gemspec",
    ".gitignore",
    "LICENSE",
    "lib/sequel_extjs.rb",
    "lib/array_extjs.rb"]
  s.require_paths = ["lib"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc","CHANGELOG.rdoc"]
  s.add_dependency("sequel", ["> 2.7.0"])
end
