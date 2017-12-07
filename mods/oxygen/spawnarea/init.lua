local spawnpoint = nil

local function registerSpawn() 
   minetest.register_on_respawnplayer(function(player)
      player:setpos(spawnpoint)
      return true
   end)
   minetest.register_on_newplayer(function(player)
      player:setpos(spawnpoint)
      return true
   end)
end

local function saveSpawnPoint()
   local data = io.open(minetest.get_worldpath().."/spawnpoint.mt", "w")
   data:write(minetest.serialize(spawnpoint))
   data:close()
end

local function drop_node(x, ystart, z, node)
   if minetest.get_node(vector.new(x, ystart, z)).name == "ignore" then return false end
   local y = ystart
   for i = ystart, ystart - 10, -1 do
      if minetest.get_node(vector.new(x, i, z)).name ~= "air" then break end
      y = i
   end
   minetest.set_node(vector.new(x, y, z), {name = node})
end

local function genSpawn()
   for i = spawnpoint.x - 2, spawnpoint.x + 2 do
      for j = spawnpoint.y - 2, spawnpoint.y + 2 do
         for k = spawnpoint.z - 2, spawnpoint.z + 2 do
            local pos = vector.new(i, j, k)
            if minetest.get_node(pos).name == "ignore" then
               minetest.after(1, function() genSpawn() end)
               return false
            else
               if minetest.get_node(pos).name == "apocalypse:ash" then
                  minetest.set_node(pos, {name = "air"})
               elseif minetest.get_node(pos).name == "apocalypse:dirt_with_ash" then
                  minetest.set_node(pos, {name = "default:dirt_with_grass"})
               elseif minetest.get_node(pos).name == "apocalypse:dirt" then
                  minetest.set_node(pos, {name = "default:dirt"})
               end
            end
         end
      end
   end

   minetest.set_node(vector.new(spawnpoint.x, spawnpoint.y - 3, spawnpoint.z), {name = "oxygen:oxygen_extruder_0"})
   minetest.get_meta(vector.new(spawnpoint.x, spawnpoint.y - 3, spawnpoint.z)):get_inventory():add_item("fuel", "oxygen:soul_of_nature")

   drop_node(spawnpoint.x - 2, spawnpoint.y + 7, spawnpoint.z - 2, "default:torch")
   drop_node(spawnpoint.x - 2, spawnpoint.y + 7, spawnpoint.z + 2, "default:torch")
   drop_node(spawnpoint.x + 2, spawnpoint.y + 7, spawnpoint.z - 2, "default:torch")
   drop_node(spawnpoint.x + 2, spawnpoint.y + 7, spawnpoint.z + 2, "default:torch")

   local pos = vector.add(spawnpoint, vector.new(1, -1, 0))
   local vm = minetest.get_voxel_manip()
   local minp, maxp = vm:read_from_map({x=pos.x-16, y=pos.y, z=pos.z-16}, {x=pos.x+16, y=pos.y+16, z=pos.z+16})
   local a = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
   local data = vm:get_data()
   default.grow_tree(data, a, pos, math.random(1, 4) == 1, math.random(1,100000))
   vm:set_data(data)
   vm:write_to_map(data)
   vm:update_map()
end

local data = io.open(minetest.get_worldpath().."/spawnpoint.mt", "r")
if data then
   local table = minetest.deserialize(data:read("*all"))
   if type(table) == "table" then
      spawnpoint = table
      registerSpawn()
   end
end

if spawnpoint == nil then
   minetest.register_on_joinplayer(function(player)
      if spawnpoint == nil then --Make sure it's STILL nil
         spawnpoint = player:getpos()
         saveSpawnPoint()
         minetest.after(1, function() genSpawn() end)
         registerSpawn()
      end
   end)
end