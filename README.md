# observable-collection
This is a simple way to add observers to Ruby arrays and hashes.

Using nothing but clean, everyday Ruby syntax, you can register callbacks which are called whenever your collection (or any nested collection thereof) is updated.

Observers of an ObservableCollection receive notifications just before and just after any method is invoked on your collection (or any of its nested collections).

Example applications:
* Keeping a persistent copy of your collection on disk, which is read and written on every read/write of your collection
* Hiding database interactions behind Ruby data structure manipulations

## Testing
To run the tests, run this command:

    $ ./test/baseline

## Usage

### Creating an ObservableCollection
Create an observable version of any Hash or Array like this:
```ruby
hash = ObservableCollection.create({ foo: 'bar' }, some_observer)
```
where `some_observer` is an object with an instance method called `update` (see below for details).

### Observing
The observer's `update` method should accept two arguments: (1) the observed collection and (2) a symbol (either `:before` of `:after`), indicating whether the collection is about to be updated (`:before`), or has just been updated (`:after`). For example
```ruby
class Observer
  def update(item, kind)
    if kind == :after
      puts "item is about to be updated: #{item}"
    else
      puts "item was just updated: #{item}"
    end
  end
end
```
### Putting it all together
Let's observe a collection!
```ruby
observer = Observer.new
hash = ObservableCollection.create({ foo: 'bar' }, observer)
hash[:hello] = 'world'
```
Output:

    item is about to be updated: {:foo=>"bar"}
    item was just updated: {:foo=>"bar", :hello=>"world"}

Alternatively, you may simply use ObservableCollection's constructor and add your observer manually:
```ruby
hash = ObservableCollection.new({ foo: 'bar' })
hash.add_observer(Observer.new)
```
Note that you can specify a custom update method name as a symbol, as the second argument to `add_observer`, or as the `:func` option when using the `create` factory method.

See the tests (`regress/`) for more examples.

### Options
The following options are accepted by both the `create` factory method and the constructor (excluding `:func`).
* `:always_update_after` - `:after` updates only occur when a method known to modify collections is called (e.g. `<<=`, `push`, `pop`, `select!`). To override this behavior so that `:after` updates always occur regardless of the method being invoked, provide the option `:always_update_after => true` to `ObservableCollection.create()`.
* `:lock_file` - the path to a file used for locking access to the collection (currently not fully supported).
* `:func` - a custom update method (symbol) defined by your observer (defaults to `:update`).

## Future
* Allow callbacks to change the args or even short-circuit invocations.
