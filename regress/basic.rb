require_relative '../test/harness'

Harness.test do |observer|
  hash = ObservableCollection.create({}, observer)

  puts "Simple as can be..."
  hash[:a] = 'foo'

  puts "\nA little more complicated..."
  hash[:b] = {}
  hash[:b][:foo] = 'bar'
end
