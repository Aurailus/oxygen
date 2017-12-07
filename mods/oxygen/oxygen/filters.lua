minetest.register_tool("oxygen:filter", {
	description = "Leaf Filter",
	groups = { filter = 1 },
	inventory_image = "(default_leaves.png^oxygen_mask_overlay.png)^[makealpha:255,0,0",
	wield_image = "oxygen_nothing.png",
	max_stack = 1,
	liquids_pointable = false,
	tool_capabilities = {
		full_punch_interval = 100.0,
		max_drop_level = 1,
	},
	sound = {
		breaks = "default_tool_break"
	}
})

minetest.register_craft({
	output = "oxygen:filter",
	recipe = {
		{"default:leaves", "default:leaves", "default:leaves"},
		{"default:leaves", "default:leaves", "default:leaves"}
	}
})

oxygen.filter_animation = function()
  for _,player in ipairs(minetest.get_connected_players()) do
  	if player:get_wielded_item():get_name() == "oxygen:filter" then
  		if tonumber(player:get_attribute("mask_pos")) == 1000 then
	  		player:set_attribute("mask_pos", -160)
	  		player:hud_change(player:get_attribute("mask"), "offset", {x = 0, y = -90})

	  		minetest.after(0.03, function(player)
  				if tonumber(player:get_attribute("mask_pos")) == -160 then
		  			player:hud_change(player:get_attribute("mask"), "offset", {x = 0, y = -150})

			  		minetest.after(0.03, function(player)
		  				if tonumber(player:get_attribute("mask_pos")) == -160 then
				  			player:hud_change(player:get_attribute("mask"), "offset", {x = 0, y = -170})

					  		minetest.after(0.03, function(player)
				  				if tonumber(player:get_attribute("mask_pos")) == -160 then
					  				player:hud_change(player:get_attribute("mask"), "offset", {x = 0, y = -180})
				  				end
				  			end, player)

				  		end
		  			end, player)

		  		end
  			end, player)
			end
		else
  		if tonumber(player:get_attribute("mask_pos")) == -160 then
	  		player:set_attribute("mask_pos", 1000)
	  		
	  		player:hud_change(player:get_attribute("mask"), "offset", {x = 0, y = -170})
	  		minetest.after(0.03, function(player)
  				if tonumber(player:get_attribute("mask_pos")) == 1000 then
		  			player:hud_change(player:get_attribute("mask"), "offset", {x = 0, y = -150})

			  		minetest.after(0.03, function(player)
		  				if tonumber(player:get_attribute("mask_pos")) == 1000 then
				  			player:hud_change(player:get_attribute("mask"), "offset", {x = 0, y = -90})

					  		minetest.after(0.03, function(player)
				  				if tonumber(player:get_attribute("mask_pos")) == 1000 then
						  			player:hud_change(player:get_attribute("mask"), "offset", {x = 0, y = 1000})
						  		end
				  			end, player)

				  		end
		  			end, player)

		  		end
  			end, player)
			end
		end
	end
end