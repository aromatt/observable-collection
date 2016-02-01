Gem::Specification.new do |s|
  s.name        = 'observable_collection'
  s.version     = '0.2.0'
  s.licenses    = ['MIT']
  s.summary     = "Ruby collections + observer pattern"
  s.description = "A simple, dependency-free library that allows for event-based observation of collections. Provides a wrapper class for `Array` and `Hash` which uses the Observable module to raise events when the underlying collection is updated.
"
  s.authors     = ["Andrew Matteson"]
  s.email       = 'amatteson3@gmail.com'
  s.files       = ["lib/observable_collection.rb"]
  s.homepage    = 'https://github.com/aromatt/observable_collection'
end
