-- beholder.lua - v1.0 (2011-11)
-- requires middleclass 2.0

-- Copyright (c) 2011 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- Based on YaciCode, from Julien Patte and LuaObject, from Sebastien Rocca-Serra

local beholder = {}


local function findNode(self, event)
  return self._nodes[event]
end

local function createNode(self, event)
  self._nodes[event] = {actions={}}
  return self._nodes[event]
end

local function findOrCreateNode(self, event)
  return findNode(self,event) or createNode(self,event)
end

local function addActionToNode(self, node, action)
  local id = {}
  node.actions[id] = action
  self._nodesById[id] = node
  return id
end

local function executeNodeActions(node)
  for _,action in pairs(node.actions) do action() end
end

function beholder:reset()
  self._nodes = {}
  self._nodesById = setmetatable({}, {__mode="k"})
end

function beholder:observe(event, action)
  return addActionToNode(self, findOrCreateNode(self, event), action)
end

function beholder:stopObserving(id)
  local node = self._nodesById[id]
  node.actions[id] = nil
end

function beholder:trigger(event)
  local node = findNode(self, event)
  if node then executeNodeActions(node) end
end

beholder:reset()

return beholder
