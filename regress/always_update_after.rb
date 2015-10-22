require_relative '../test/harness'

Harness.test do |observer|

  never = ObservableCollection.create({foo: :bar}, observer)
  puts "\nWe did not specify :always_update_after, so we will not receive " +
       "updates unless we modify the hash."
  never.to_s

  always = ObservableCollection.create({foo: :bar}, observer,
                                       always_update_after: true)

  puts "\nEven though we are not changing the hash, we receive an `:after` update"
  always.to_s
end
