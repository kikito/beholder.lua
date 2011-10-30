-- beholder.lua - v1.0 (2011-11)

-- Copyright (c) 2011 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN callback OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local function copy(t)
  local c={}
  for i=1,#t do c[i]=t[i] end
  return c
end

-- private Node class

local Node = {
  _nodesById = setmetatable({}, {__mode="k"})
}

function Node:new()
  return setmetatable( { callbacks = {}, children = {} }, { __index = Node } )
end

function Node:findById(id)
  return self._nodesById[id]
end

function Node:findOrCreateChild(key)
  self.children[key] = self.children[key] or Node:new()
  return self.children[key]
end

function Node:findOrCreateDescendant(keys)
  local node = self
  for i=1, #keys do
    node = node:findOrCreateChild(keys[i])
  end
  return node
end

function Node:invokeCallbacks(params)
  local counter = 0
  for _,callback in pairs(self.callbacks) do
    callback(unpack(params))
    counter = counter + 1
  end
  return counter
end

function Node:invokeAllCallbacksInSubTree(params)
  local counter = self:invokeCallbacks(params)
  for _,child in pairs(self.children) do
    counter = counter + child:invokeAllCallbacksInSubTree(params)
  end
  return counter
end

function Node:invokeCallbacksFromPath(path)
  local node = self
  local params = copy(path)
  local counter = node:invokeCallbacks(params)

  for i=1, #path do
    node = node.children[path[i]]
    if not node then break end
    table.remove(params, 1)
    counter = counter + node:invokeCallbacks(params)
  end

  return counter
end

function Node:addCallback(callback)
  local id = {}
  self.callbacks[id] = callback
  Node._nodesById[id] = self
  return id
end

function Node:removeCallback(id)
  self.callbacks[id] = nil
  Node._nodesById[id] = nil
end

-- beholder private functions

local function falseIfZero(n)
  return n > 0 and n
end

local function checkSelf(self, methodName)
  assert(type(self)=="table" and self._root, "Use beholder:" .. methodName .. " instead of beholder." .. methodName)
end

local function extractEventAndCallbackFromParams(params)
  assert(#params > 0, "beholder:observe requires at least one parameter - the callback. You usually want to use two, i.e.: beholder:observe('EVENT', callback)")
  local callback = table.remove(params, #params)
  return params, callback
end

local function initialize(self)
  self._root = Node:new()
end

------ Public interface

local beholder = {}

function beholder:observe(...)
  checkSelf(self, 'observe')
  local event, callback = extractEventAndCallbackFromParams({...})
  return self._root:findOrCreateDescendant(event):addCallback(callback)
end

function beholder:stopObserving(id)
  checkSelf(self, 'stopObserving')
  local node = Node:findById(id)
  if not node then return false end
  node:removeCallback(id)
  return true
end

function beholder:trigger(...)
  checkSelf(self, 'trigger')
  return falseIfZero( self._root:invokeCallbacksFromPath({...}) )
end

function beholder:triggerAll(...)
  checkSelf(self, 'triggerAll')
  return falseIfZero( self._root:invokeAllCallbacksInSubTree({...}) )
end

function beholder:reset()
  checkSelf(self, 'reset')
  initialize(self)
end

initialize(beholder)

return beholder
