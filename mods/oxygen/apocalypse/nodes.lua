minetest.register_node("apocalypse:dirt", {
	description = "Dry Dirt",
	tiles = {"apocalypse_dirt.png"},
	groups = {crumbly = 3, soil = 1},
	sounds = default.node_sound_dirt_defaults(),
	on_oxygenate = function(pos) minetest.get_node_timer(pos):start(math.random(1, 10)/5) end,
	on_timer = function(pos)
		if oxygen.node_is_oxygenated(pos) then
			minetest.swap_node(pos, {name = "default:dirt"})
		end
	return false end,
})

minetest.override_item("default:dirt", {
	on_oxygenate = function(pos) minetest.get_node_timer(pos):start(math.random(1, 10)/5) end,
	on_timer = function(pos)
		if not oxygen.node_is_oxygenated(pos) then
			minetest.swap_node(pos, {name = "apocalypse:dirt"})
		end
	end
})

minetest.register_node("apocalypse:dirt_with_grass", {
	description = "Dead Grass",
	tiles = {"apocalypse_grass_top.png", "apocalypse_dirt.png",
		{name = "apocalypse_grass_side.png",
			tileable_vertical = false}},
	groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1},
	drop = 'apocalypse:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.25},
	}),
	on_oxygenate = function(pos) minetest.get_node_timer(pos):start(math.random(1, 10)/5) end,
	on_timer = function(pos)
		if oxygen.node_is_oxygenated(pos) then
			minetest.swap_node(pos, {name = "default:dirt_with_grass"})
		end
	return false end,
})

minetest.override_item("default:dirt_with_grass", {
	on_oxygenate = function(pos) minetest.get_node_timer(pos):start(math.random(1, 10)/5) end,
	on_timer = function(pos)
		if not oxygen.node_is_oxygenated(pos) then
			minetest.swap_node(pos, {name = "apocalypse:dirt_with_grass"})
		end
	end
})

minetest.register_node("apocalypse:dirt_with_ash", {
	description = "Dirt with Ash",
	tiles = {"apocalypse_ash_top.png", "apocalypse_dirt.png",
		{name = "apocalypse_grass_side_ash.png",
			tileable_vertical = false}},
	groups = {crumbly = 3, spreading_dirt_type = 1, snowy = 1},
	drop = 'apocalypse:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_snow_footstep", gain = 0.2},
	}),
	on_oxygenate = function(pos) minetest.get_node_timer(pos):start(math.random(1, 10)/5) end,
	on_timer = function(pos)
		if oxygen.node_is_oxygenated(pos) then
			minetest.swap_node(pos, {name = "default:dirt_with_grass"})
		end
	return false end,
})

minetest.register_node("apocalypse:ash", {
	description = "Ash",
	tiles = {"apocalypse_ash_top.png"},
	inventory_image = "apocalypse_ash_item.png",
	wield_image = "apocalypse_ash_item.png",
	paramtype = "light",
	buildable_to = true,
	walkable = false,
	floodable = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
		},
	},
	groups = {crumbly = 3, falling_node = 1, puts_out_fire = 1, snowy = 1},
	-- sounds = default.node_sound_snow_defaults(),

	on_construct = function(pos)
		pos.y = pos.y - 1
		if minetest.get_node(pos).name == "apocalypse:dirt_with_grass" then
			minetest.set_node(pos, {name = "apocalypse:dirt_with_ash"})
		end
	end,

	on_destruct = function(pos)
		pos.y = pos.y - 1
		if minetest.get_node(pos).name == "apocalypse:dirt_with_ash" then
			minetest.set_node(pos, {name = "apocalypse:dirt_with_grass"})
		end
	end,

	on_oxygenate = function(pos) minetest.get_node_timer(pos):start(math.random(1, 10)/5) end,
	on_timer = function(pos)
		if oxygen.node_is_oxygenated(pos) then
			minetest.swap_node(pos, {name = "air"})
		end
	return false end,
})

minetest.register_node("apocalypse:dead_grass_1", {
	description = "Dead Grass",
	drawtype = "plantlike",
	waving = 1,
	tiles = {"apocalypse_tallgrass_1.png"},
	inventory_image = "apocalypse_tallgrass_4.png",
	paramtype = "light",
	sunlight_propogates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flora = 1, attached_node = 1, grass = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -5 / 16, 6 / 16},
	},
	on_place = function(itemstack, placer, pointed_thing)
		local stack = ItemStack("apocalypse:dead_grass_" .. math.random(1,4))
		local ret = minetest.item_place(stack, placer, pointed_thing)
		return ItemStack("apocalypse:dead_grass_1 " ..
		itemstack:get_count() - (1 - ret:get_count()))
	end,
	on_construct = function(pos)
		local ash = 0
		local nodes = {}
		table.insert(nodes, minetest.get_node(vector.add(pos, vector.new(0, 0, 1))).name)
		table.insert(nodes, minetest.get_node(vector.add(pos, vector.new(0, 0, -1))).name)
		table.insert(nodes, minetest.get_node(vector.add(pos, vector.new(1, 0, 0))).name)
		table.insert(nodes, minetest.get_node(vector.add(pos, vector.new(-1, 0, 0))).name)
		for k,v in pairs(nodes) do
			if v == "apocalypse:ash" or v == "apocalypse:dead_grass_ash_1" or v == "apocalypse:dead_grass_ash_2"
			or v == "apocalypse:dead_grass_ash_3" or v == "apocalypse:dead_grass_ash_4" then
				ash = ash + 1
				if ash >= 2 then break end
			end
		end
		if ash >= 2 then
			minetest.set_node(pos, {name = "apocalypse:dead_grass_ash_1"})
		end
	end,
	on_oxygenate = function(pos) minetest.get_node_timer(pos):start(math.random(1, 10)/5) end,
	on_timer = function(pos)
		if oxygen.node_is_oxygenated(pos) then
			-- minetest.swap_node(pos, {name = "default:dirt"})
		end
	return false end,
})

for length = 1, 4 do
	if length ~= 1 then
		minetest.register_node("apocalypse:dead_grass_"..length, {
			description = "Dead Grass",
			drawtype = "plantlike",
			waving = 1,
			tiles = {"apocalypse_tallgrass_"..length..".png"},
			paramtype = "light",
			sunlight_propogates = true,
			walkable = false,
			buildable_to = true,
			groups = {snappy = 3, flora = 1, attached_node = 1, grass = 1, flammable = 1},
			sounds = default.node_sound_leaves_defaults(),
			selection_box = {
				type = "fixed",
				fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 4 / 16, 6 / 16},
			},
			drop = "apocalypse:dead_grass_1",
			on_construct = function(pos)
				local ash = 0
				local nodes = {}
				table.insert(nodes, minetest.get_node(vector.add(pos, vector.new(0, 0, 1))).name)
				table.insert(nodes, minetest.get_node(vector.add(pos, vector.new(0, 0, -1))).name)
				table.insert(nodes, minetest.get_node(vector.add(pos, vector.new(1, 0, 0))).name)
				table.insert(nodes, minetest.get_node(vector.add(pos, vector.new(-1, 0, 0))).name)
				for k,v in pairs(nodes) do
					if v == "apocalypse:ash" or v == "apocalypse:dead_grass_ash_1" or v == "apocalypse:dead_grass_ash_2"
					or v == "apocalypse:dead_grass_ash_3" or v == "apocalypse:dead_grass_ash_4" then
						ash = ash + 1
						if ash >= 2 then break end
					end
				end
				if ash >= 2 then
					minetest.set_node(pos, {name = "apocalypse:dead_grass_ash_"..length})
				end
			end,
			on_oxygenate = function(pos) minetest.get_node_timer(pos):start(math.random(1, 10)/5) end,
			on_timer = function(pos)
				if oxygen.node_is_oxygenated(pos) then
					-- minetest.swap_node(pos, {name = "default:dirt"})
				end
			return false end,
		})
	end

	minetest.register_node("apocalypse:dead_grass_ash_"..length, {
		description = "Dead Grass",
		tiles = {
			"apocalypse_ash_top.png",
			"apocalypse_ash_top.png",
			"apocalypse_tallgrass_snowed_"..length..".png",
			"apocalypse_tallgrass_snowed_"..length..".png",
			"apocalypse_tallgrass_snowed_"..length..".png",
			"apocalypse_tallgrass_snowed_"..length..".png"
		},
		selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 4 / 16, 6 / 16},
		},
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- NodeBox1
				{0, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox2
				{-0.5, -0.5, 0, 0.5, 0.5, 0}, -- NodeBox3
			}
		},
		paramtype = "light",
		sunlight_propogates = true,
		walkable = false,
		buildable_to = true,
		groups = {snappy = 3, flora = 1, attached_node = 1, grass = 1, flammable = 1},
		sounds = default.node_sound_leaves_defaults(),
		drop = "apocalypse:dead_grass_1",
		on_construct = function(pos)
			pos.y = pos.y - 1
			if minetest.get_node(pos).name == "apocalypse:dirt_with_grass" then
				minetest.set_node(pos, {name = "apocalypse:dirt_with_ash"})
			end
		end,
		on_destruct = function(pos)
			pos.y = pos.y - 1
			if minetest.get_node(pos).name == "apocalypse:dirt_with_ash" then
				minetest.set_node(pos, {name = "apocalypse:dirt_with_grass"})
			end
		end,
		on_oxygenate = function(pos) minetest.get_node_timer(pos):start(math.random(1, 10)/5) end,
		on_timer = function(pos)
			if oxygen.node_is_oxygenated(pos) then
				-- minetest.swap_node(pos, {name = "default:dirt"})
			end
		return false end,
	})
end