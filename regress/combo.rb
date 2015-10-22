require_relative '../test/harness'

Harness.test do |observer|
  hash = ObservableCollection.create({}, observer)
  array = ObservableCollection.create([], observer)

  puts "\nUse an array inside a hash"
  hash[:a] = array
  array << 1
  array << 2

  puts "\nPut a hash inside the array"
  array << ObservableCollection.create({}, observer)
  array.last[:c] = 'woot'
end
