-- beholder.lua - v1.0 (2011-11)
-- requires middleclass 2.0

-- Copyright (c) 2011 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- Based on YaciCode, from Julien Patte and LuaObject, from Sebastien Rocca-Serra

local beholder = {}

function beholder:reset()
  self._actions = {}
  self._ids = {}
end

function beholder:observe(event, action)
  local id = {}
  self._actions[event] = self._actions[event] or {}
  self._actions[event][id] = action
  self._ids[id] = event
  return id
end

function beholder:stopObserving(id)
  local event = self._ids[id]
  self._actions[event][id] = nil
end

function beholder:trigger(event)
  local actions = self._actions[event] or {}
  for _,action in pairs(actions) do
    action()
  end
end

beholder:reset()

return beholder
