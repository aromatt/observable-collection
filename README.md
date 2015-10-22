# observable-collection
This is a simple way to add observers to Ruby arrays and hashes.

Using nothing but clean, everyday Ruby syntax, you can register callbacks which are called whenever your collection (or any nested collection thereof) is updated.

Observers of an ObservableCollection receive notifications just before and just after any method is invoked on your collection (or any of its nested collections).

Example applications:
* Keeping a persistent copy of your collection on disk, which is read and written on every read/write of your collection
* Sharing state between threads - ObservableCollection supports explicit locking and can be made to be process- and thread-safe
* Hiding database interactions behind Ruby data structure manipulations

## Usage

Create an observable version of any Hash or Array like this:

    hash = { foo: 'bar' }
    obs_hash = ObservableCollection.create(hash, some_observer)

where `some_observer` is an object with a method called `update`. The `update` method should accept two arguments: (1) the observed collection and (2) a symbol (either `:before` of `:after`), indicating whether the collection is about to be updated (`:before`), or has just been updated (`:after`).

For example:

    class Observer
      def update(item, kind)
        if kind == :after
          puts "item is about to be updated: #{item}"
        else
          puts "item was just updated: #{item}"
        end
      end
    end

One caveat: `:after` calls are only made when a method known to modify collections is called (e.g. `<<=`, `push`, `pop`, `select`). To override this behavior so that `:after` updates always occur regardless of the method being invoked, provide the option `:always_update_after => true` to `ObservableCollection.create()`.
