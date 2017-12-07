local function register_extruder(stage, nbox)
	minetest.register_node("oxygen:oxygen_extruder_" .. stage, {
		description = "Oxygen Extruder",
		tiles = {
			"default_leaves^oxygen_extruder_top.png",
			"oxygen_extruder_bottom.png",
			"default_leaves^oxygen_extruder_side.png"
		},
		selection_box = { type = "regular" },
		collisionbox = {-0.5, 0.0, -0.5, 0.5, 1.0, 0.5},
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, 
				{-0.5, -0.25, 0.375, -0.375, 0.4375, 0.5}, 
				{0.375, -0.25, 0.375, 0.5, 0.4375, 0.5}, 
				{-0.5, -0.25, -0.5, -0.375, 0.4375, -0.375}, 
				{0.375, -0.25, -0.5, 0.5, 0.4375, -0.375}, 
				{-0.5, 0.4375, -0.5, -0.1875, 0.5, 0.5}, 
				{0.1875, 0.4375, -0.5, 0.5, 0.5, 0.5}, 
				{-0.1875, 0.4375, -0.5, 0.1875, 0.5, -0.1875}, 
				{-0.1875, 0.4375, 0.1875, 0.1875, 0.5, 0.5}, 
				{0.125, 0.4375, 0.125, 0.1875, 0.5, 0.1875}, 
				{-0.1875, 0.4375, 0.125, -0.125, 0.5, 0.1875}, 
				{0.125, 0.4375, -0.1875, 0.1875, 0.5, -0.125}, 
				{-0.1875, 0.4375, -0.1875, -0.125, 0.5, -0.125},
				nbox,
			}
		},
		is_ground_content = false,
		paramtype = "light",
		light_source = 10,
		groups = {cracky = 1, level = 2, o2extruder = 1},
		on_construct = function(pos)
			minetest.swap_node(pos, {name = "oxygen:oxygen_extruder_0"})
			minetest.get_meta(pos):set_int("active", 0)
			local inv = minetest.get_meta(pos):get_inventory()
			inv:set_size('fuel', 4)
			minetest.get_meta(pos):set_string("formspec", [[
				size[8,8]
				bgcolor[#080808BB;false]
				liscolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
				label[3,0;Fuel]
				list[context;fuel;3,0.5;2,2;]
				label[0,3.25;Player Inventory]
				list[current_player;main;0,3.75;8,1;]
				list[current_player;main;0,5;8,3;8]
				listring[context;fuel]
				listring[current_player;main]
			]])
		end,
		can_dig = function(pos, player)
			return minetest.get_meta(pos):get_inventory():is_empty("fuel")
		end,
		node_placement_prediction = "oxygen:oxygen_extruder_0",
		on_destruct = function(pos)
			oxygen.remove_oxygen_source(pos)
		end,
		drop = "oxygen:oxygen_extruder_6",
	})
end

local function update_extruder(pos)
	local active = minetest.get_meta(pos):get_int("active")
	if active == 1 then
		if not oxygen.is_oxygen_source(pos) then
			oxygen.add_oxygen_source(pos)
		end
	else
		if oxygen.is_oxygen_source(pos) then
			oxygen.remove_oxygen_source(pos)
		end
	end
end

minetest.register_abm({
	label = "oxygen:abm_oxygen_extruder_state",
	nodenames = "group:o2extruder",
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos) update_extruder(pos) end,
})

local interval = 3
local ticks = 12
local function consume_extruder_fuel(pos) 
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if inv:contains_item("fuel", "oxygen:soul_of_nature") then
		meta:set_int("active", 1)
		meta:set_string("infotext", "∞ Oxygen remaining.")
		minetest.swap_node(pos, {name = "oxygen:oxygen_extruder_6"})

	elseif inv:contains_item("fuel", "default:leaves") then

		if meta:get_int("ticks") == ticks then
			inv:remove_item("fuel", "default:leaves 1")
			meta:set_int("ticks", 0)
		else
			meta:set_int("ticks", meta:get_int("ticks") + 1)
		end
		meta:set_int("active", 1)

		--Get count of leaves
		local leaves = inv:get_stack("fuel", 1):get_count() + inv:get_stack("fuel", 2):get_count() 
								 + inv:get_stack("fuel", 3):get_count() + inv:get_stack("fuel", 4):get_count()
		 
	 	if (leaves > 280) then
			minetest.swap_node(pos, {name = "oxygen:oxygen_extruder_6"})
		elseif (leaves > 150) then
			minetest.swap_node(pos, {name = "oxygen:oxygen_extruder_5"})
		elseif (leaves > 70) then
			minetest.swap_node(pos, {name = "oxygen:oxygen_extruder_4"})
		elseif (leaves > 30) then
			minetest.swap_node(pos, {name = "oxygen:oxygen_extruder_3"})
		elseif (leaves > 10) then
			minetest.swap_node(pos, {name = "oxygen:oxygen_extruder_2"})
		elseif (leaves > 0) then
			minetest.swap_node(pos, {name = "oxygen:oxygen_extruder_1"})
		end

		local secsleft = leaves * (ticks + 1) * interval + ((ticks - meta:get_int("ticks")) - 1) * interval
		meta:set_string("infotext",
			math.floor(secsleft/60) .. "m " .. secsleft%60 .. "s of Oxygen remaining.")
	else
		meta:set_int("active", 0)
		meta:set_string("infotext", "Extruder is out of leaves.")
		minetest.swap_node(pos, {name = "oxygen:oxygen_extruder_0"})
	end
end

minetest.register_abm({
	label = "oxygen:abm_oxygen_extruder_fuel",
	nodenames = "group:o2extruder",
	interval = interval,
	chance = 1,
	catch_up = true,
	action = function(pos) consume_extruder_fuel(pos) end,
})

register_extruder(0, {})
register_extruder(1, {-0.0625, -0.4375, -0.0625, 0.0625, 0.4375, 0.0625})
register_extruder(2, {-0.125, -0.4375, -0.125, 0.125, 0.4375, 0.125})
register_extruder(3, {-0.1875, -0.4375, -0.1875, 0.1875, 0.4375, 0.1875})
register_extruder(4, {-0.25, -0.4375, -0.25, 0.25, 0.4375, 0.25})
register_extruder(5, {-0.3125, -0.4375, -0.3125, 0.3125, 0.4375, 0.3125})
register_extruder(6, {-0.375, -0.4375, -0.375, 0.375, 0.4375, 0.375})

minetest.register_lbm({
	name = "oxygen:abm_oxygen_extruder_load",
	nodenames = "group:o2extruder",
	run_at_every_load = true,
	action = function(pos) update_extruder(pos) end
})