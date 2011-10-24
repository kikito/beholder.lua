local beholder = require 'beholder'


describe("Acceptance", function()

  before(function()
    beholder:reset()
  end)

  test("Normal behavior", function()

    local counter = 0

    local id = beholder:observe("EVENT", function() counter = counter + 1 end)

    beholder:trigger("EVENT")
    beholder:trigger("EVENT")

    assert_equal(counter, 2)

    beholder:stopObserving(id)

    beholder:trigger("EVENT")

    assert_equal(counter, 2)

  end)

end)
