require_relative '../test/harness'

Harness.test do |observer|
  hash = ObservableCollection.create({foo: :bar}, observer)
  array = ObservableCollection.create([1, 2, 3], observer)

  puts "\nIterate over an array"
  array.map! { |x| x + 1 }

  puts "\nUpdate a nested ObservableCollection during an iteration"
  array << hash
  array.each { |x| x[:foo] = :baz if x.is_a? Hash }
end
