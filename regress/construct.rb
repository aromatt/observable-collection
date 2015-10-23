require_relative '../test/harness'

# Demonstrates ordinary constructor usage

class RegularObserver
  def update(item, kind)
    puts "Default update: #{item}" if kind == :after
  end
end
class SpecialObserver
  def special_update(item, kind)
    puts "Special update: #{item}" if kind == :after
  end
end

hash = ObservableCollection.new({})
hash.add_observer(RegularObserver.new)
puts "\nDefault update method name"
hash[:a] = 'foo'

special = ObservableCollection.new({})
special.add_observer(SpecialObserver.new, :special_update)
puts "\nSpecial update method name"
special[:a] = 'foo'
