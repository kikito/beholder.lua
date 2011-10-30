-- beholder.lua - v1.0 (2011-11)

-- Copyright (c) 2011 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN callback OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local beholder = {}

local function initialize(self)
  self._root = { callbacks={}, children={} }
  self._nodesById = setmetatable({}, {__mode="k"})
end

local function checkSelf(self, methodName)
  assert(type(self)=="table" and self._root and self._nodesById, "Use beholder:" .. methodName .. " instead of beholder." .. methodName)
end

local function falseIfZero(n)
  return n > 0 and n
end

local function copy(t)
  local c={}
  for i=1,#t do c[i]=t[i] end
  return c
end

local function extractEventAndCallbackFromParams(params)
  assert(#params > 0, "beholder:observe requires at least one parameter - the callback. You usually want to use two, i.e.: beholder:observe('EVENT', callback)")
  local callback = table.remove(params, #params)
  return params, callback
end

local function findNodeById(self, id)
  return self._nodesById[id]
end

local function findOrCreateChildNode(node, key)
  node.children[key] = node.children[key] or { callbacks = {}, children = {} }
  return node.children[key]
end

local function findOrCreateDescendantNode(node, keys)
  for i=1, #keys do
    node = findOrCreateChildNode(node, keys[i])
  end
  return node
end

local function executeNodeCallbacks(node, params)
  local counter = 0
  for _,callback in pairs(node.callbacks) do
    callback(unpack(params))
    counter = counter + 1
  end
  return counter
end

local function executeAllCallbacks(node, params)
  local counter = executeNodeCallbacks(node, params)
  for _,child in pairs(node.children) do
    counter = counter + executeAllCallbacks(child, params)
  end
  return counter
end

local function executeEventCallbacks(node, event)
  local params = copy(event)
  local counter = executeNodeCallbacks(node, params)

  for i=1, #event do
    node = node.children[event[i]]
    if not node then break end
    table.remove(params, 1)
    counter = counter + executeNodeCallbacks(node, params)
  end

  return counter
end

local function addCallbackToNode(self, node, callback)
  local id = {}
  node.callbacks[id] = callback
  self._nodesById[id] = node
  return id
end

local function removeCallbackFromNode(node, id)
  if not node then return false end
  node.callbacks[id] = nil
  return true
end

-------

function beholder:observe(...)
  checkSelf(self, 'observe')
  local event, callback = extractEventAndCallbackFromParams({...})
  return addCallbackToNode(self, findOrCreateDescendantNode(self._root, event), callback)
end

function beholder:stopObserving(id)
  checkSelf(self, 'stopObserving')
  return removeCallbackFromNode(findNodeById(self, id), id)
end

function beholder:trigger(...)
  checkSelf(self, 'trigger')
  return falseIfZero( executeEventCallbacks(self._root, {...}) )
end

function beholder:triggerAll(...)
  checkSelf(self, 'triggerAll')
  return falseIfZero( executeAllCallbacks(self._root, {...}) )
end

function beholder:reset()
  checkSelf(self, 'reset')
  initialize(self)
end

initialize(beholder)

return beholder
