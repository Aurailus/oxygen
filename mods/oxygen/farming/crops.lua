farming.register_crop("cotton", {
	stages = 6,
	texture = "farming_crop_cotton",
	growth_rate = math.floor(300 / 6),
			--ABM Ticks till stage update
	drop = "farming:cotton_ball",
	drop_count = {1, 3}
})