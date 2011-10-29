-- beholder.lua - v1.0 (2011-11)
-- requires middleclass 2.0

-- Copyright (c) 2011 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- Based on YaciCode, from Julien Patte and LuaObject, from Sebastien Rocca-Serra

local beholder = {}

local function copy(t)
  local c={}
  for i=1,#t do c[i]=t[i] end
  return c
end

local function extractEventAndActionFromParams(params)
  local action = table.remove(params, #params)
  return params, action
end

local function findNodeById(self, id)
  return self._nodesById[id]
end

local function findOrCreateNode(self, event)
  local current = self._root
  local key
  for i=1, #event do
    key = event[i]
    current.children[key] = current.children[key] or {actions={},children={}}
    current = current.children[key]
  end
  return current
end

local function executeNodeActions(self, event)
  local current = self._root
  local counter = 0
  local params = copy(event)
  local key

  for i=1,#event do
    key = event[i]
    current = current.children[key]
    if not current then break end
    table.remove(params, 1)
    for _,action in pairs(current.actions) do
      action(unpack(params))
      counter = counter + 1
    end
  end

  return counter > 0 and counter
end

local function addActionToNode(self, node, action)
  local id = {}
  node.actions[id] = action
  self._nodesById[id] = node
  return id
end

local function removeActionFromNode(node, id)
  if not node then return false end
  node.actions[id] = nil
  return true
end

function beholder:reset()
  self._root = { actions={}, children={} }
  self._nodesById = setmetatable({}, {__mode="k"})
end

function beholder:observe(...)
  local event, action = extractEventAndActionFromParams({...})
  return addActionToNode(self, findOrCreateNode(self, event), action)
end

function beholder:stopObserving(id)
  return removeActionFromNode(findNodeById(self, id), id)
end

function beholder:trigger(...)
  return executeNodeActions(self, {...})
end

beholder:reset()

return beholder
