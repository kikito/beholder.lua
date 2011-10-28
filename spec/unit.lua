local beholder = require 'beholder'

describe("Unit", function()

  before(function()
    beholder:reset()
  end)

  describe(":observe", function()
    it("notices simple events so that trigger works", function()
      local counter = 0
      beholder:observe("EVENT", function() counter = counter + 1 end)
      beholder:trigger("EVENT")
      assert_equal(counter, 1)
    end)

    it("remembers if more than one action is associated to the same event", function()
      local counter1, counter2 = 0,0
      beholder:observe("EVENT", function() counter1 = counter1 + 1 end)
      beholder:observe("EVENT", function() counter2 = counter2 + 1 end)
      beholder:trigger("EVENT")
      assert_equal(counter1, 1)
      assert_equal(counter2, 1)
    end)
--[[
    describe("when observing a table", function()
      local counter
      before(function()
        counter = 0
        beholder:observe({"KEYPRESS", "enter"}, function() counter = counter + 1 end)
      end)

      it("matches a trigger of a structurally identical table", function()
        beholder:trigger({"KEYPRESS", "enter"})
        assert_equal(counter, 1)
      end)

      it("matches a trigger of a structurally identical params list", function()
        beholder:trigger("KEYPRESS", "enter")
        assert_equal(counter, 1)
      end)

      --it("triggering partials does not ", function()
      --end)

    end)
]]
  end)

  describe(":stopObserving", function()
    it("stops noticing events so trigger doesn't work any more", function()
      local counter = 0
      local id = beholder:observe("EVENT", function() counter = counter + 1 end)
      beholder:trigger("EVENT")
      beholder:stopObserving(id)
      beholder:trigger("EVENT")
      assert_equal(counter, 1)
    end)

    it("stops observing one id without disturbing the others", function()
      local counter1, counter2 = 0,0
      local id1 = beholder:observe("EVENT", function() counter1 = counter1 + 1 end)
      beholder:observe("EVENT", function() counter2 = counter2 + 1 end)
      beholder:trigger("EVENT")

      assert_equal(counter1, 1)
      assert_equal(counter2, 1)
      beholder:stopObserving(id1)
      beholder:trigger("EVENT")

      assert_equal(counter1, 1)
      assert_equal(counter2, 2)

    end)
--[[
    it("passes parameters to the actions", function()
      local counter = 0

      beholder:observe("EVENT", function(x) counter = counter + x end)
      beholder:trigger("EVENT", 1)

      assert_equal(counter, 1)
      beholder:trigger("EVENT", 5)

      assert_equal(counter, 6)
    end)
]]
  end)


  describe(":reset", function()

  end)


end)
