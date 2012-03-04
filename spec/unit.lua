local beholder = require 'beholder'

describe("Unit", function()

  before(function()
    beholder.reset()
  end)

  describe(".observe", function()
    it("notices simple events so that trigger works", function()
      local counter = 0
      beholder.observe("EVENT", function() counter = counter + 1 end)
      beholder.trigger("EVENT")
      assert_equal(counter, 1)
    end)

    it("remembers if more than one action is associated to the same event", function()
      local counter1, counter2 = 0,0
      beholder.observe("EVENT", function() counter1 = counter1 + 1 end)
      beholder.observe("EVENT", function() counter2 = counter2 + 1 end)
      beholder.trigger("EVENT")
      assert_equal(counter1, 1)
      assert_equal(counter2, 1)
    end)

    it("allows observing composed events", function()
      local counter = 0
      beholder.observe("KEYPRESS", "start", function() counter = counter + 1 end)
      beholder.trigger("KEYPRESS", "start")
      assert_equal(counter, 1)
    end)

    it("observes all events with the nil event", function()
      local counter = 0
      beholder.observe(function(_,x) counter = counter + x end)
      beholder.trigger("FOO", 1)
      beholder.trigger("BAR", 2)
      assert_equal(3, counter)
    end)

    it("throws an error if called without at least one parameter", function()
      assert_error(function() beholder.observe() end)
    end)

    it("does not store hard references to variables", function()
      local counter = 0
      local x = {}
      beholder.observe(x, function() counter = counter + 1 end)
      beholder.triggerAll()
      x = nil
      collectgarbage("collect")
      beholder.triggerAll()
      assert_equal(1, counter)
    end)
  end)

  describe(".stopObserving", function()
    it("stops noticing events so trigger doesn't work any more", function()
      local counter = 0
      local id = beholder.observe("EVENT", function() counter = counter + 1 end)
      beholder.trigger("EVENT")
      beholder.stopObserving(id)
      beholder.trigger("EVENT")
      assert_equal(counter, 1)
    end)

    it("stops observing one id without disturbing the others", function()
      local counter1, counter2 = 0,0
      local id1 = beholder.observe("EVENT", function() counter1 = counter1 + 1 end)
      beholder.observe("EVENT", function() counter2 = counter2 + 1 end)
      beholder.trigger("EVENT")

      assert_equal(counter1, 1)
      assert_equal(counter2, 1)
      beholder.stopObserving(id1)
      beholder.trigger("EVENT")

      assert_equal(counter1, 1)
      assert_equal(counter2, 2)

    end)

    it("passes parameters to the actions", function()
      local counter = 0

      beholder.observe("EVENT", function(x) counter = counter + x end)
      beholder.trigger("EVENT", 1)

      assert_equal(counter, 1)
      beholder.trigger("EVENT", 5)

      assert_equal(counter, 6)
    end)

    it("does not raise an error when stopping observing an inexisting event or group", function()
      assert_not_error(function() beholder.stopObserving({}) end)
    end)

    it("returns false when no action was found for an id", function()
      assert_equal(false, beholder.stopObserving({}))
    end)

    it("returns false when there was a group, but it had no action", function()
      local group = {}
      beholder.group(group, function() end)
      assert_equal(false, beholder.stopObserving(group))
    end)

    it("returns true when an action was found and removed", function()
      local id = beholder.observe("X", function() end)
      assert_true(beholder.stopObserving(id))
    end)

    it("returns true when at least one action from a group was removed", function()
      local group = {}
      beholder.group(group, function()
        beholder.observe("X", function() end)
      end)
      assert_true(beholder.stopObserving(group))
    end)

  end)

  describe(".trigger", function()
    it("does not error on random stuff", function()
      assert_not_error(function() beholder.trigger("FOO") end)
    end)

    it("returns false on events with no actions", function()
      assert_equal(false, beholder.trigger("FOO"))
    end)

    it("returns false if there was a node with no actions", function()
      beholder.observe("ONE","TWO", function() end)
      assert_equal(false, beholder.trigger("ONE"))
    end)

    it("returns the number of actions executed", function()
      beholder.observe("X", function() end)
      beholder.observe("X", function() end)
      assert_equal(2, beholder.trigger("X"))
    end)

    it("triggers callbacks within the nil event only", function()
      local counter = 0
      beholder.observe("X", function() counter = counter + 10 end)
      beholder.observe(function() counter = counter + 5 end)

      beholder.trigger()

      assert_equal(5, counter)
    end)
  end)

  describe(".triggerAll", function()
    it("calls all registered callbacks", function()
      local counter = 0
      beholder.observe("X", function() counter = counter + 1 end)
      beholder.triggerAll()
      assert_equal(1, counter)
    end)
    it("passes parameters to callbacks", function()
      local counter = 0
      beholder.observe(function(x) counter = counter + x end)
      beholder.triggerAll(2)
      assert_equal(2, counter)
    end)
    it("returns false if no actions where found", function()
      assert_false(beholder.triggerAll())
    end)
    it("returns the number of actions executed", function()
      beholder.observe("X", function() end)
      beholder.observe("Y", function() end)
      assert_equal(2, beholder.triggerAll())
    end)
  end)

  describe(".group", function()
    it("throws an error when nested", function()
      assert_error(function()
        beholder.group({}, function()
          beholder.group({}, function()
          end)
        end)
      end)
    end)

    it("creates a group of events that can be cancelled", function()
      local counter = 0
      local increment = function() counter = counter + 1 end
      local group  = {}
      beholder.group(group, function()
        beholder.observe("X", increment)
        beholder.observe("Y", increment)
      end)
      beholder.trigger("X")
      beholder.trigger("Y")
      assert_equal(2, counter)

      beholder.stopObserving(group)

      beholder.trigger("X")
      beholder.trigger("Y")
      assert_equal(2, counter)
    end)
  end)



end)
