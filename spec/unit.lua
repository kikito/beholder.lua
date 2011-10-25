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

    it("when given an id, it stops observing it", function()
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
  end)


  describe(":reset", function()

  end)


end)
