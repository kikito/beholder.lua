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

  test("several actions on the same event", function()
    
    local counter1, counter2 = 0,0

    local id1 = beholder:observe("EVENT", function() counter1 = counter1 + 1 end)
    local id2 = beholder:observe("EVENT", function() counter2 = counter2 + 1 end)

    beholder:trigger("EVENT")
    beholder:trigger("EVENT")

    assert_equal(counter1, 2)
    assert_equal(counter2, 2)

    beholder:stopObserving(id1)

    beholder:trigger("EVENT")
    assert_equal(counter1, 2)
    assert_equal(counter2, 3)

    beholder:stopObserving(id2)

    beholder:trigger("EVENT")
    assert_equal(counter1, 2)
    assert_equal(counter2, 3)

  end)

  test("callback parameters", function()
    local counter = 0

    beholder:observe("EVENT", function(x) counter = counter + x end)

    beholder:trigger("EVENT", 1)

    assert_equal(counter, 1)

    beholder:trigger("EVENT", 5)

    assert_equal(counter, 6)

  end)

end)
