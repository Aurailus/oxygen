oxygen = {}

path = minetest.get_modpath("oxygen")
dofile(path .. "/oxygen.lua")
dofile(path .. "/filters.lua")
dofile(path .. "/nodes.lua")
dofile(path .. "/extruders.lua")

minetest.register_on_joinplayer(function (player)
	player:set_sky("#66552a", "plain", {}, true)
	player:set_clouds({color = "#595752"})
	player:set_attribute("mask", player:hud_add({
		hud_elem_type = "image",
		scale = {x = 20, y = 16},
		text = "oxygen_mask_wield.png",
		alignment = 0,
		direction = 0,
		name = "Oxygen Mask Wield Image",
		position = {x = 0.5, y = 1},
		offset = {x = 0, y = 1000}
	}))
	player:set_attribute("mask_pos", 1000)
end)

minetest.register_craftitem("oxygen:soul_of_nature", {
	inventory_image = "oxygen_soul_of_nature.png",
	description = "Soul of Nature"
})