require_relative '../lib/observable_collection'

class Harness
  class AfterObserver
    def update(observed, kind)
      puts "update: #{observed}" if kind == :after
    end
  end

  def self.test
    o = AfterObserver.new
    yield o
  end
end
