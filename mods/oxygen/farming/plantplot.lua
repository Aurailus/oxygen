farming.crops = {}

--Group: farmplot
--4: Wet, has crop
--3: Dry, has crop
--2: Wet, no crop
--1: Dry, no crop

local function gen_formspec(pos)
	local meta = minetest.get_meta(pos)
	return [[
		size[8,8]
		bgcolor[#080808BB;false]
		liscolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
		label[0,0;Water]
		image[0,0.6;1,3;farming_bar_back.png^[lowpart:]] .. meta:get_float("water") .. [[:farming_bar_water.png^farming_bar_front.png]
		label[7.005,0;Fertilizer]
		image[7,0.6;1,3;farming_bar_back.png^[lowpart:]] .. meta:get_float("fertilizer") .. [[:farming_bar_fertilizer.png^farming_bar_front.png]
		list[current_player;main;0,3.75;8,1;]
		list[current_player;main;0,5;8,3;8]
	]]
end

--Default farmplot table
local farmplot = {
	tiles = {
		"farming_plantplot_top_wet.png",
		"default_wood.png",
		"farming_plantplot_side.png",
	},
	drawtype = "nodebox",
	selection_box = { type = "regular" },
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.375, -0.4375, 0.4375, 0.5, -0.375}, -- Stick
			{-0.375, -0.375, -0.375, -0.4375, 0.5, -0.4375}, -- Stick
			{0.375, -0.375, 0.375, 0.4375, 0.5, 0.4375}, -- Stick
			{-0.4375, -0.375, 0.375, -0.375, 0.5, 0.4375}, -- Stick
			{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}, -- Wood_Base
			{-0.375, -0.375, -0.4375, 0.375, -0.3125, 0.4375}, -- Plant_Base
			{-0.4375, -0.5, -0.375, -0.375, -0.3125, 0.375}, -- Plant_Base_2
			{0.375, -0.5, -0.375, 0.4375, -0.3125, 0.375}, -- Plant_Base_3
			{-0.5, 0.3125, -0.4375, -0.4375, 0.375, 0.4375}, -- Pole_1
			{0.4375, 0.3125, -0.4375, 0.5, 0.375, 0.4375}, -- Pole_2
			{-0.5, 0.25, 0.4375, 0.5, 0.3125, 0.5}, -- Pole_3
			{-0.5, 0.25, -0.5, 0.5, 0.3125, -0.4375}, -- Pole_4
			{-0.375, -0.3125, 0.1875, 0.375, 0.25, 0.1875}, -- Plant_p1
			{-0.375, -0.3125, -0.1875, 0.375, 0.25, -0.1875}, -- plant_p2
			{0.1875, -0.5, -0.375, 0.1875, 0.25, 0.375}, -- plant_p3
			{-0.1875, -0.5, -0.375, -0.1875, 0.25, 0.375}, -- plant_p4
		}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('crop', 1)
		meta:set_float("water", 0)
		meta:set_float("fertilizer", 0)
		meta:set_int("growth_stage", 0)
		meta:set_int("growth_tick", 0)
		minetest.get_meta(pos):set_string("formspec", gen_formspec(pos))
	end,
	on_punch = function (pos, node, user)
		local nodename = minetest.get_node(pos).name
		local crop
		if minetest.registered_nodes[nodename] then
			crop = minetest.registered_nodes[nodename]._crop
			if not crop then return false end
		end

		meta = minetest.get_meta(pos)
		local cropdata = farming.crops[crop]
		local growth_stage = meta:get_int("growth_stage")
		if growth_stage == cropdata.stages - 1 then

			local pinv = user:get_inventory()
			local stack = cropdata.drop .. " " .. (math.random(cropdata.drop_count[1], cropdata.drop_count[2]))
			if not pinv:room_for_item("main", stack) then return false end
			pinv:add_item("main", stack)

			print(stack)

			meta:set_int("growth_stage", 0)
			meta:set_int("growth_tick", 0)

			local wetness = "dry"
			if meta:get_float("water") > 0 then wetness = "wet" end
			projected_name = "farming:farmplot_" .. wetness .. "_" .. cropdata.name .. "_0"
			minetest.swap_node(pos, {name = projected_name})
		end
	end, 
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("crop")
	end,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, farm_plot = 4},
	drop = "farming:farmplot_dry"
}

-- Register empty dry farmplot
local farmtable = table.copy(farmplot)
farmtable.description = "Dry Farmplot"
farmtable.tiles[1] = "farming_plantplot_top_dry.png"
farmtable.groups = {choppy = 2, oddly_breakable_by_hand = 2, farmplot = 1}
minetest.register_node("farming:farmplot_dry", farmtable)

-- Register empty wet farmplot
local farmtable = table.copy(farmplot)
farmtable.description = "Wet Farmplot"
farmtable.tiles[1] = "farming_plantplot_top_wet.png"
farmtable.groups = {choppy = 2, oddly_breakable_by_hand = 2, farmplot = 2}
minetest.register_node("farming:farmplot_wet", farmtable)
farmtable = nil

-- Register crop function
function farming.register_crop(name, crop_definitions)
	farming.crops[name] = {
		name = name,
		stages = crop_definitions.stages,
		growth_rate = crop_definitions.growth_rate,
		drop = crop_definitions.drop,
		drop_count = crop_definitions.drop_count,
	}

	for i = 0, crop_definitions.stages - 1 do
		local farmtable = table.copy(farmplot)
		farmtable.groups = {choppy = 2, oddly_breakable_by_hand = 2, farmplot = 4}
		farmtable.tiles = {
			"farming_plantplot_top_wet.png",
			"default_wood.png",
			crop_definitions.texture .. "_" .. i .. ".png^farming_plantplot_side.png"
		}
		farmtable._crop = name
		minetest.register_node("farming:farmplot_wet_" .. name .. "_" .. i, farmtable)

		local farmtable = table.copy(farmplot)
		farmtable.groups = {choppy = 2, oddly_breakable_by_hand = 2, farmplot = 3}
		farmtable.tiles = {
			"farming_plantplot_top_dry.png",
			"default_wood.png",
			crop_definitions.texture .. "_" .. i .. ".png^farming_plantplot_side.png"
		}
		farmtable._crop = name
		minetest.register_node("farming:farmplot_dry_" .. name .. "_" .. i, farmtable)
	end
end

minetest.register_abm({
	label = "farming:farmplot_updates",
	nodenames = "group:farmplot",
	interval = 2,
	chance = 5,
	catch_up = true,
	action = function(pos)
		local nodename = minetest.get_node(pos).name
		local crop
		if minetest.registered_nodes[nodename] then
			crop = minetest.registered_nodes[nodename]._crop
			-- print(dump(minetest.registered_nodes[nodename]))
			if not crop then return false end
		end

		meta = minetest.get_meta(pos)
		local cropdata = farming.crops[crop]
		local growth_stage = meta:get_int("growth_stage")

		if growth_stage == cropdata.stages - 1 then
			return false 
		end

		local wetness = "dry"
		if meta:get_float("water") > 0 then wetness = "wet" end
		local growth_tick = meta:get_int("growth_tick")
		growth_tick = growth_tick + 1
		while growth_tick >= cropdata.growth_rate do
			growth_tick = growth_tick - cropdata.growth_rate
			growth_stage = growth_stage + 1
			meta:set_int("growth_stage", growth_stage)
		end
		meta:set_int("growth_tick", growth_tick)
		projected_name = "farming:farmplot_" .. wetness .. "_" .. cropdata.name .. "_" .. growth_stage
		if projected_name ~= nodename then
			minetest.swap_node(pos, {name = projected_name})
		end
	end,
})

farming.register_crop("cotton", {
	stages = 6,
	texture = "farming_crop_cotton",
	-- growth_rate = math.floor(300 / 6),
	growth_rate = 1,
			--ABM Ticks till stage update
	drop = "farming:cotton_ball",
	drop_count = {1, 3}
})