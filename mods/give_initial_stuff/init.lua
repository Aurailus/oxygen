minetest.register_on_newplayer(function(player)
	print("[Oxygen] Giving initial stuff to " .. player:get_player_name())
	player:get_inventory():add_item('main', 'default:shovel_steel')
	player:get_inventory():add_item('main', 'default:axe_steel')
end)

