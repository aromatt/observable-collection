require_relative '../test/harness'

Harness.test do |observer|
  hash = ObservableCollection.create({}, observer)

  puts "\nTake a nested structure, pass it around, 99 problems and a reference ain't one"
  hash[:b] = {a: 'foo', b: {}}
  b = hash[:b]
  b[:c] = 'set from nested reference'
end
