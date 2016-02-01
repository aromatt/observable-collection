# observable_collection [![Build Status](https://travis-ci.org/aromatt/thejub.pub.svg)](https://travis-ci.org/aromatt/observable-collection)
This is a simple, dependency-free library that allows for event-based observation of collections. It provides a wrapper class for `Array` and `Hash` which uses the [Observable module](http://ruby-doc.org/stdlib-1.9.3/libdoc/observer/rdoc/Observable.html) to raise events when the underlying collection is updated.

When an observed collection (or any of its nested collections) is updated, oberservers' callbacks will be invoked just before and just after the update is carried out.

Example applications:
* Keeping a persistent copy of your collection on disk, which is read and written on every read/write of your collection
* Hiding database interactions behind Ruby data structure manipulations

## Usage

### Creating an ObservableCollection
Create an observable version of any Hash or Array like this:
```ruby
hash = ObservableCollection.create({ foo: 'bar' })
```

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
hash = ObservableCollection.create({ foo: 'bar' })
hash.add_observer(observer)
hash[:hello] = 'world'
```
Output:

    item is about to be updated: {:foo=>"bar"}
    item was just updated: {:foo=>"bar", :hello=>"world"}

Note that you can specify a custom update method name as a symbol, as the second argument to `add_observer`, or as the `:func` option when using the `create` factory method.

See the tests (`regress/`) for more examples.

### Options
The following options are accepted by both the `create` factory method and the constructor (excluding `:func`).
* `:always_update_after` - `:after` updates only occur when a method known to modify collections is called (e.g. `<<=`, `push`, `pop`, `select!`). To override this behavior so that `:after` updates always occur regardless of the method being invoked, provide the option `:always_update_after => true` to `ObservableCollection.create()`.
* `:lock_file` - the path to a file used for locking access to the collection (currently not fully supported).
* `:func` - a custom update method (symbol) defined by your observer (defaults to `:update`).

## Testing
To run the tests, run this command:

    $ ./test/baseline

## Future
* Allow callbacks to change the args or even short-circuit invocations.
