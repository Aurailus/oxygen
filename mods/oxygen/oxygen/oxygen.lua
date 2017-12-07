oxygen.oxygenated_nodes = {}
oxygen.oxygen_sources = {}

--
-- Verbose Function, for debugging
--
local verbose = 2

function oxygen.verbose(func, level)
	if verbose then
		if verbose >= (level or 1) then
			return func()
		end
	end
end

--
-- Chunk Functions
-- Not to be used outside of this file
--
local subchunksize = 8
local chunksize = subchunksize * 8

function get_chunk(pos)
	return vector.new(math.floor(pos.x / chunksize), math.floor(pos.y / chunksize), math.floor(pos.z / chunksize))
end
function get_subchunk(pos)
	return vector.new(math.floor(pos.x / subchunksize), math.floor(pos.y / subchunksize), math.floor(pos.z / subchunksize))
end

--
-- Check node Oxygenation state
--
function oxygen.node_is_oxygenated(pos)
	local chunk = oxygen.serializepos(get_chunk(pos))
	local subchunk = oxygen.serializepos(get_subchunk(pos))
	if not oxygen.oxygenated_nodes[chunk] then return false end
	if not oxygen.oxygenated_nodes[chunk][subchunk] then return false end
	return oxygen.oxygenated_nodes[chunk][subchunk][oxygen.serializepos(pos)] or false
end

--
-- Simplify adding / removing oxygenated nodes to the table
-- Not to be used outside of this file
--
local function add_oxygenated_node(pos)
	local chunk = oxygen.serializepos(get_chunk(pos))
	local subchunk = oxygen.serializepos(get_subchunk(pos))
	if not oxygen.oxygenated_nodes[chunk] then
		oxygen.oxygenated_nodes[chunk] = {}
	end
	if not oxygen.oxygenated_nodes[chunk][subchunk] then
		oxygen.oxygenated_nodes[chunk][subchunk] = {}
	end
	oxygen.oxygenated_nodes[chunk][subchunk][oxygen.serializepos(pos)] = true
end

local function remove_oxygenated_node(pos)
	local posstring = oxygen.serializepos(pos)
	local chunk = oxygen.serializepos(get_chunk(pos))
	local subchunk = oxygen.serializepos(get_subchunk(pos))
	if not oxygen.oxygenated_nodes[chunk] then return end
	if not oxygen.oxygenated_nodes[chunk][subchunk] then return end
	oxygen.oxygenated_nodes[chunk][subchunk][oxygen.serializepos(pos)] = nil
end

--
-- Check if node is Oxygen Source (Oxygen Extruder)
--
function oxygen.is_oxygen_source(pos)
	local posString = oxygen.serializepos(pos)
	for k, v in pairs(oxygen.oxygen_sources) do
		if v == posString then
			return true
		end
	end
	return false
end

--
-- Simplify adding / removing Oxygen Sources from the table,
-- notifies the server of the change and recalculates oxygen near pos
--
function oxygen.add_oxygen_source(pos)
	oxygen.verbose(function() print("[Oxygen] Adding oxygen source at " .. pos.x .. ", " .. pos.y .. ", " .. pos.z) end)
	table.insert(oxygen.oxygen_sources, oxygen.serializepos(pos))
	oxygen.recalc_near_node(pos, true)
end

function oxygen.remove_oxygen_source(pos)
	oxygen.verbose(function() print("[Oxygen] Removing oxygen source at " .. pos.x .. ", " .. pos.y .. ", " .. pos.z) end)
	local posstring = oxygen.serializepos(pos)
	for k, v in pairs(oxygen.oxygen_sources) do
		if v == posstring then
			table.remove(oxygen.oxygen_sources, k)
		end
	end
	oxygen.recalc_near_node(pos, false)
end

--
-- Recalculate and Update oxygenated state Near position
-- if it seems overly complicated, it's for the sake of optimization
--
function oxygen.recalc_near_node(sourcepos, active)
	oxygen.verbose(function() print("[Oxygen] Recalculating oxygenated nodes near "..sourcepos.x..", "..sourcepos.y..", "..sourcepos.z) end)
  local starttime = minetest.get_us_time()

  if active then
  	--Add oxygen
		for i = sourcepos.x - 2, sourcepos.x + 2 do
			for j = sourcepos.y - 2, sourcepos.y + 8 do
				for k = sourcepos.z - 2, sourcepos.z + 2 do

					local pos = vector.new(i, j, k)
					if not oxygen.node_is_oxygenated(pos) then
						add_oxygenated_node(pos)
						local nodename = minetest.get_node(pos).name
						if minetest.registered_nodes[nodename] then
							if minetest.registered_nodes[nodename].on_oxygenate then
								minetest.registered_nodes[nodename].on_oxygenate(pos)
							end
						end
					end

				end
			end
		end
	else
		--Remove oxygen
		local modified_nodes = {}

		for i = sourcepos.x - 2, sourcepos.x + 2 do
			for j = sourcepos.y - 2, sourcepos.y + 8 do
				for k = sourcepos.z - 2, sourcepos.z + 2 do
					local pos = vector.new(i, j, k)
					modified_nodes[oxygen.serializepos(pos)] = true
				end
			end
		end

	  local min = vector.new(sourcepos.x - 5, sourcepos.y - 2, sourcepos.z - 5)
	  local max = vector.new(sourcepos.x + 5, sourcepos.y + 2, sourcepos.z + 5)

		for _,source in pairs(oxygen.oxygen_sources) do
			local pos = oxygen.deserializepos(source)
			if pos.x >= min.x and pos.y >= min.y and pos.z >= min.z 
				and pos.x <= max.x and pos.y <= max.y and pos.z <= max.z then

				for i = pos.x - 2, pos.x + 2 do
					for j = pos.y - 2, pos.y + 8 do
						for k = pos.z - 2, pos.z + 2 do

							local posString = oxygen.serializepos(vector.new(i, j, k))
							if modified_nodes[posString] then modified_nodes[posString] = nil end

						end
					end
				end
			end
		end

		for posstring,val in pairs(modified_nodes) do
			if val then
				local pos = oxygen.deserializepos(posstring)
				if oxygen.node_is_oxygenated(pos) then
					remove_oxygenated_node(pos)
					local nodename = minetest.get_node(pos).name
					if minetest.registered_nodes[nodename] then
						if minetest.registered_nodes[nodename].on_oxygenate then
							minetest.registered_nodes[nodename].on_oxygenate(pos)
						end
					end
				end
			end
		end
		--Endif big statement
	end
  local timeelapsed = (minetest.get_us_time() - starttime) / 1000.0
	oxygen.verbose(function() print('[Oxygen] Recalculated oxygenated nodes in ' .. timeelapsed .. 'ms.') end,2)
end

--
-- Serialize and Deserialize position helper functions
-- Turns position vector in string format, eg "10|25|-12" (x = 10, y = 25, z = -12)
--
function oxygen.deserializepos(posString)
	local x = posString:sub(1, posString:find("|", 1, true) - 1)
	local y = posString:sub(x:len() + 2, posString:find("|", x:len() + 2) - 1, true)
	local z = posString:sub(y:len() + 1 + x:len() + 2, posString:find("|", x:len() + 1 + y:len() + 2), true)
	return vector.new(tonumber(x), tonumber(y), tonumber(z))
end

function oxygen.serializepos(pos)
	return pos.x.."|"..pos.y.."|"..pos.z
end

--
-- Player Damage Function
--
function oxygen.processDamage(player)
	local hp = player:get_hp()
	if hp > 0 then
		local item = player:get_wielded_item()
		if item:get_name() == "oxygen:filter" then
			item:add_wear(65535/60)
			player:set_wielded_item(item)
		else
			player:set_hp(hp - 1)
		end
	end
end

--
-- Particle spawner helper functions
-- For borders of Oxygen
--
local density = 1
local small = 0.2
local large = 1.0

oxygen.particle_spawners = {}
local function particle_reg_spawner_hor(pos, min, max)
	table.insert(oxygen.particle_spawners,
		minetest.add_particlespawner({
			amount = density,
			time = 0,
			minpos = vector.add(pos, min),
			maxpos = vector.add(pos, max),
			minvel = vector.new(0, 0, 0),
			maxvel = vector.new(0, 0, 0),
			minacc = vector.new(0, 0, 0),
			maxacc = vector.new(0, 0, 0),
			minexptime = 2,
			maxexptime = 2,
			minsize = small,
			maxsize = large,
			collisiondetection = false,
			vertical = false,
			texture = "oxygen_warning.png"
		})
	)
end

local function particle_reg_spawner_ver(pos, min, max)
	table.insert(oxygen.particle_spawners,
		minetest.add_particlespawner({
			amount = density,
			time = 0,
			minpos = vector.add(pos, min),
			maxpos = vector.add(pos, max),
			minvel = vector.new(0, 0, 0),
			maxvel = vector.new(0, 0, 0),
			minacc = vector.new(0, 0, 0),
			maxacc = vector.new(0, 0, 0),
			minexptime = 2,
			maxexptime = 2,
			minsize = small,
			maxsize = large,
			collisiondetection = false,
			vertical = true,
			texture = "oxygen_warning.png"
		})
	)
end

--
-- Calculate oxygen particle borders
--
local function particle_spawn_borders(pos)
	--Up
	if not oxygen.node_is_oxygenated(vector.add(pos, vector.new(0, 1, 0))) then
		particle_reg_spawner_hor(pos, vector.new(-0.5, 0.5, -0.5), vector.new(0.5, 0.5, 0.5))
	end
	--Down
	if not oxygen.node_is_oxygenated(vector.add(pos, vector.new(0, -1, 0))) then
		particle_reg_spawner_hor(pos, vector.new(-0.5, -0.5, -0.5), vector.new(0.5, -0.4, 0.5))
	end
	--X+
	if not oxygen.node_is_oxygenated(vector.add(pos, vector.new(1, 0, 0))) then
		particle_reg_spawner_ver(pos, vector.new(0.5, -0.5, -0.5), vector.new(0.5, 0.5, 0.5))
	end
	--X-
	if not oxygen.node_is_oxygenated(vector.add(pos, vector.new(-1, 0, 0))) then
		particle_reg_spawner_ver(pos, vector.new(-0.5, -0.5, -0.5), vector.new(-0.4, 0.5, 0.5))
	end
	--Z+
	if not oxygen.node_is_oxygenated(vector.add(pos, vector.new(0, 0, 1))) then
		particle_reg_spawner_ver(pos, vector.new(-0.5, -0.5, 0.5), vector.new(0.5, 0.5, 0.5))
	end
	--Z-
	if not oxygen.node_is_oxygenated(vector.add(pos, vector.new(0, 0, -1))) then
		particle_reg_spawner_ver(pos, vector.new(-0.5, -0.5, -0.5), vector.new(0.5, 0.5, -0.4))
	end
end

-- Benchmarking
damage_benchmark = {}
damage_benchmark[0] = 0
recalc_benchmark = {}
recalc_benchmark[0] = 0

--
-- Globalstep functions
-- Timers for intervalled actions
--
local damage_time = 0
local recalc_time = 0
local mask_time = 0
minetest.register_globalstep(function(dtime)
  damage_time = damage_time + dtime
  recalc_time = recalc_time + dtime
  mask_time = mask_time + dtime

  --
  -- Oxygen filter animation
  --
  if mask_time > 0.2 then
  	mask_time = 0
  	oxygen.filter_animation()
	end

	--
	-- Player damage processing
	--
  if damage_time > 1 then
    damage_time = 0

    local starttime = minetest.get_us_time();

    for _,player in ipairs(minetest.get_connected_players()) do
    	local ppos = player:getpos()
    	if minetest.get_node(ppos).name ~= "ignore" then
	      if not oxygen.node_is_oxygenated(vector.new(math.floor(ppos.x + 0.5), math.floor(ppos.y + 0.5), math.floor(ppos.z + 0.5))) then
	      	oxygen.processDamage(player)
	  		end
  		end
    end

    local timeelapsed = (minetest.get_us_time() - starttime) / 1000.0
    damage_benchmark[1] = damage_benchmark[2]
    damage_benchmark[2] = damage_benchmark[3]
    damage_benchmark[3] = damage_benchmark[4]
    damage_benchmark[4] = damage_benchmark[5]
    damage_benchmark[5] = timeelapsed
    damage_benchmark[0] = damage_benchmark[0] + 1
    if (damage_benchmark[0] > 4) then
    	damage_benchmark[0] = 0
    	local avgtime = (damage_benchmark[1]+damage_benchmark[2]+damage_benchmark[3]+damage_benchmark[4]+damage_benchmark[5])/5
    	oxygen.verbose(function() print('[Oxygen] Average damage processing time is ' .. avgtime .. 'ms.') end, 3)
  	end
  end

  --
  -- Recalculate oxygen particle border and which should be visible
  --
  if recalc_time > 3 then
    recalc_time = 0
    local starttime = minetest.get_us_time();
  	local render_queue = {}
  	local rdist = 7

  	for _,player in ipairs(minetest.get_connected_players()) do
  		local playerpos = player:getpos()
  		local playerpos = vector.new(math.floor(playerpos.x + 0.5), math.floor(playerpos.y + 0.5), math.floor(playerpos.z + 0.5))
  		for i = playerpos.x - rdist, playerpos.x + rdist do
  			for j = playerpos.y - rdist, playerpos.y + rdist do
  				for k = playerpos.z - rdist, playerpos.z + rdist do
  					local nodepos = vector.new(i, j, k)
  					if oxygen.node_is_oxygenated(nodepos) then
  						table.insert(render_queue, nodepos)
						end
					end
				end
			end
		end

		for k,v in pairs(oxygen.particle_spawners) do
			oxygen.particle_spawners[k] = nil
			minetest.delete_particlespawner(v)
		end

  	for _,pos in pairs(render_queue) do
  		particle_spawn_borders(pos)
		end

    local timeelapsed = (minetest.get_us_time() - starttime) / 1000.0
    recalc_benchmark[1] = recalc_benchmark[2]
    recalc_benchmark[2] = recalc_benchmark[3]
    recalc_benchmark[3] = recalc_benchmark[4]
    recalc_benchmark[4] = recalc_benchmark[5]
    recalc_benchmark[5] = timeelapsed
    recalc_benchmark[0] = recalc_benchmark[0] + 1
    if (recalc_benchmark[0] > 4) then
    	recalc_benchmark[0] = 0
    	local avgtime = (recalc_benchmark[1]+recalc_benchmark[2]+recalc_benchmark[3]+recalc_benchmark[4]+recalc_benchmark[5])/5
    	oxygen.verbose(function() print('[Oxygen] Average Particle Spawner recalc time is ' .. avgtime .. 'ms.') end,3)
  	end
  end
end)
