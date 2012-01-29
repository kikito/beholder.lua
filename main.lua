

beholder = require 'beholder'

local directions = {
  up    = {dx =  0, dy = -1},
  down  = {dx =  0, dy =  1},
  left  = {dx = -1, dy =  0},
  right = {dx =  1, dy =  0}
}

function startMoving(entity, direction)
  entity.want[direction] = true
end

function stopMoving(entity, direction)
  if not direction then
    entity.want = {}
  else
    entity.want[direction] = nil
  end
end

function pause(entity)
  entity.paused = true
end

function unpause(entity)
  entity.paused = false
end

function move(entity, dt)
  if not entity.paused then
    for dir,delta in pairs(directions) do
      if entity.want[dir] then
        entity.x = entity.x + delta.dx * entity.speed
        entity.y = entity.y + delta.dy * entity.speed
      end
    end
  end
end

function checkCollision(a,b)
  local ax1, ay1, ax2, ay2 = a.x, a.y, a.x+16, a.y+16
  local bx1, by1, bx2, by2 = b.x, b.y, b.x+16, b.y+16
  if ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1 then
    beholder.trigger("COLLISION", a, b)
    beholder.trigger("COLLISION", b, a)
  end
end

function draw(entity)
  love.graphics.setColor(unpack(entity.color))
  love.graphics.rectangle("line", entity.x, entity.y, 16, 16)
end

function relativePosition(entity)
  local position = {}
  local dx = entity.target.x - entity.x
  local dy = entity.target.y - entity.y
  table.insert(position, dy > 0 and 'down' or dy < 0 and 'up')
  table.insert(position, dx > 0 and 'right' or dx < 0 and 'left')
  return position
end

function chooseDirection(entity)
  if entity.target then
    stopMoving(entity)
    for _,dir in ipairs(relativePosition(entity)) do
      startMoving(entity, dir)
    end
  end
end


function all(collection, f,...)
  for i=#collection,1,-1 do
    f(collection[i], ...)
  end
end

function allWithIndex(collection, f)
  for i=#collection,1,-1 do
    f(collection[i], i, collection)
  end
end

function removeIfDead(entity, id, collection)
  if entity.dead then table.remove(collection, id) end
end

function gameOver()
  print("braains")
  beholder.reset()
  love.event.push('q')
end

entities, zombies = {},{}

function createPlayer()
  player = {
    x = 400,
    y = 300,
    want={},
    color = {200,200,50},
    speed = 2
  }
  setmetatable(player, {__tostring = function(t) return 'player' end})
  for dir,_ in pairs(directions) do
    beholder.observe("KEYPRESSED", dir, function() startMoving(player, dir) end)
    beholder.observe("KEYRELEASED", dir, function() stopMoving(player, dir) end)
  end
  beholder.observe("KEYPRESSED", " ", activateMine)

  beholder.observe("COLLISION", player, gameOver)

  table.insert(entities, player)
end

function createZombie()
  local zombie = {
    x = math.random(20,780),
    y = math.random(20,580),
    want = {},
    color = {50,150,50},
    speed = math.max(math.random()/2, 0.4),
    target = player
  }
  setmetatable(zombie, {__tostring = function(t) return 'zombie' end})
  table.insert(zombies, zombie)
  table.insert(entities, zombie)
end

function createMine()
  mine = {
    x = player.x,
    y = player.y,
    want = {},
    color = {100,100,200},
    speed = 0
  }
  setmetatable(mine, {__tostring = function(t) return 'mine' end})

  beholder.observe("COLLISION", mine, function(zombie)
    if not mine.exploded then
      mine.exploded = true
      mine.color = {50,50,50}
      zombie.dead = true
      beholder.trigger("KILLED", zombie)
    end
  end)

  table.insert(entities, mine)
end

function activateMine()
  if mine.exploded then
    mine.exploded = false
    mine.color = {100,100,200}
    mine.x,mine.y = player.x, player.y
  end
end

function love.update(dt)
  all(zombies,chooseDirection)
  all(entities,move)
  all(zombies,checkCollision,player)
  all(zombies,checkCollision,mine)
  allWithIndex(zombies, removeIfDead)
  allWithIndex(entities, removeIfDead)
end

function love.draw()
  all(entities,draw)
  love.graphics.setColor(255,255,255)
  love.graphics.print("Last pressed key: " .. lastPressedKey, 0, 580)
end

function love.keypressed(key)
  beholder.trigger("KEYPRESSED", key)
end

function love.keyreleased(key)
  beholder.trigger("KEYRELEASED", key)
end

function love.load()
  math.randomseed(os.time())

  local zombieCount = 20
  local killCount = 0

  createPlayer()
  createMine()
  for i=1,zombieCount do
    createZombie()
  end

  beholder.observe(print) -- print every event on the terminal

  -- prints the last pressed key on the screen
  lastPressedKey = "<none yet>"
  beholder.observe("KEYPRESSED", function(key)
    lastPressedKey = key
  end)

  -- binds escape to the gameOver function (quit game)
  beholder.observe("KEYPRESSED", "escape", gameOver)

  -- handle pause
  beholder.observe("KEYPRESSED", "pause", function()
    all(entities, pause)
    local id
    id = beholder.observe("KEYPRESSED", function()
      all(entities, unpause)
      beholder.stopObserving(id)
    end)
  end)


  -- victor is triggered if enough kills are done
  beholder.observe("KILLED", function()
    killCount = killCount + 1
    if killCount == zombieCount then
      print("You win!")
      beholder.reset()
      love.event.push('q')
    end
  end)

end


