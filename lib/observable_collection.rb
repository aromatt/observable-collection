require 'observer'

# This class facilitates the modification of collections in a distributed
# fashion. It adds the Observable functionality to collections types like
# Hash and Array. Initialize with the underlying collection you want to wrap.
#
# It supports nested collections. Notifications of changes in lower levels in
# a data structure are bubbled upward by chained-together ObservableCollections,
# where each chain link is an observable-observer relationship.
#
# The object wrapped by an ObservableCollection can be accessed explicitly via
# #subject, but the point of this class is that you can treat an
# ObservableCollection as you would a regular Array or Hash.
#
class ObservableCollection
  include Observable

  # Undefine some of the methods inherited from Object so that invocations of
  # them are passed down to the subject via #method_missing below
  undef :to_s, :to_enum, :inspect, :is_a?, :kind_of?, :class

  attr_accessor :subject

  def initialize(subject, opts = {})
    @subject = subject
    @lock_file = opts[:lock_file]
    @always_update_after = opts[:always_update_after]
  end

  # Factory method - takes in an Array or a Hash, and the observer
  def self.create(subject, observer = nil, *opts)
    observable = subject
    if [Array, Hash].include? observable.class
      observable = ObservableCollection.new(subject, *opts)
      observable.add_observer observer if observer
    end
    observable
  end

  # Gain an exclusive lock on access to this data structure. Accepts a block to
  # execute while the lock is owned. It is best to do this whenever, e.g.,
  # writing to disk upon changes to the collection.
  def lock
    _lock

    # (TL;DR: locking solves more problems than concurrency)
    # Only read from disk once while the lock is kept. Normal behavior is
    # to read every time a method is called at any level of the data
    # structure, which can cause problems when e.g. reading twice in one
    # line, such as `obs_hash[a][b] << obs_hash[c][d].count`. Note that the
    # problem being solved here is not related to concurrency--it's just
    # a convenient way to solve it.
    changed
    notify_observers(self, :before)

    yield

    _unlock
  end

  # Users will treat ObservableCollection like a regular collection, so
  # send method calls to the underlying collection.
  # Extra things we do:
  #   -catch the creation/retrieval of child collections and make them
  #    observable too, so that updates to them bubble up.
  #   -let *our* observers know about this method call, both before and after
  #    we call the desired method.
  def method_missing(meth, *args, &block)

    # Let the our observers know someone is calling a method on us. If we are
    # reporting directly to a user-land observer, its callback will be
    # invoked. If we are reporting to another ObservableCollection, it will
    # just propagate the notification upward.
    unless @locked
      changed
      notify_observers(@subject, :before)
    end

    # Execute the method on the subject
    result = @subject.send(meth, *args, &block)

    # If the return value is another ObservableCollection, add myself as an
    # observer. If it's an ordinary collection, make it an ObservableCollection
    # and add myself as an observer. The exception is when result == @subject,
    # in which case we just want to return the subject unadorned. This is to
    # avoid, e.g., puts() being unable to convert an ObservableArray to a regular
    # Array the way it expects (this exception facilitates, e.g., `puts hash.values`)
    if result.is_a? ObservableCollection
      result.add_observer self
    elsif result != @subject
      result = ObservableCollection.create(result, self, lock_file: @lock_file)
    end

    if (DESTRUCTIVE.include? meth) || @always_update_after
      changed
      notify_observers(@subject, :after)
    end

    result
  end

  # We ignore the arguments because we don't care what the change was
  # downstream--we just need to propagate upward the message that something
  # changed.
  def update(_downstream_object, kind)
    if kind == :after
      changed
      notify_observers(@subject, :after)
    end
  end

  protected

  def _lock
    unless @lock_file
      throw "Can't use lock feature without specifying a lock file"
    end
    @lock = File.open(@lock_file, 'a+')
    @lock.flock(File::LOCK_EX)
    @locked = true
  end

  def _unlock
    @lock.close
    @locked = false
  end

  # The use of one of these methods may result in the subject changing
  DESTRUCTIVE = [
    :[]=,
    :<<,
    :clear,
    :collect!,
    :compact!,
    :concat,
    :delete,
    :delete_at,
    :delete_if,
    :drop,
    :drop_while,
    :fill, :flatten!,
    :keep_if,
    :map!,
    :merge!,
    :inject!,
    :pop,
    :push,
    :shift,
    :unshift,
    :reject!,
    :rehash,
    :replace,
    :reverse!,
    :rotate!,
    :select!,
    :shift,
    :shuffle!,
    :slice!,
    :sort!,
    :sort_by!,
    :store,
    :uniq!,
    :unshift,
    :update,
    :each,
    :each_pair,
    :each_key,
    :each_value
  ]
end
