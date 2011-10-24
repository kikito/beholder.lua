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
  end)


  describe(":reset", function()

  end)


end)
