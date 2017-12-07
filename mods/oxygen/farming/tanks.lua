minetest.register_node("farming:fertilizer_bin", {
    description = "Fertilizer Bin",
    tiles = {
        "farming_bin_border.png",
        "farming_bin_side.png",
        "farming_bin_top.png",
        "farming_bin_bottom.png",
        "farming_bin_top.png",
        "farming_bin_bottom.png",
    },
    drawtype = "glasslike_framed",
    paramtype2 = "glasslikeliquidlevel",
    special_tiles = {"farming_fertilizer_block.png"},
    sunlight_propagates = true,
    groups = {choppy = 3, oddly_breakable_by_hand = 3, flammable = 2, wood = 2},
    sounds = default.node_sound_defaults(),
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    on_punch = function (pos, node, user)
        local count = node.param2
        if count <= 0 then return false end
        local inv = user:get_inventory()
        local stack = "farming:fertilizer"
        if not inv:room_for_item("main", stack) then return false end
        inv:add_item("main", stack)
        node.param2 = node.param2 - 1
        minetest.swap_node(pos, node)
    end,
})

minetest.override_item("bucket:bucket_empty", {
    stack_max = 1,
})

minetest.register_node("farming:water_tank", {
    description = "Water Tank",
    tiles = {
        "farming_tank_side.png",
        "farming_tank_side.png",
        "default_furnace_top.png",
        "default_furnace_top.png",
        "default_furnace_top.png",
        "default_furnace_top.png",
    },
    drawtype = "glasslike_framed",
    paramtype2 = "glasslikeliquidlevel",
    special_tiles = {"default_water.png"},
    sunlight_propagates = true,
    groups = {cracky = 3, oddly_breakable_by_hand = 3},
    sounds = default.node_sound_defaults(),
    on_rightclick = function (pos, node, user, itemstack, pointed_thing)
        if itemstack:get_name() == "bucket:bucket_water" then
            if node.param2 < 60 then
                node.param2 = node.param2 + 4
                minetest.swap_node(pos, node)
                minetest.after(0, function(user) -- If anyone knows why this has to be like this, tell me!
                    user:get_inventory():set_stack("main", user:get_wield_index(), "bucket:bucket_empty")
                end, user)
            end
        end
    end,
    on_punch = function (pos, node, user)
        if user:get_wielded_item():get_name() == "bucket:bucket_empty" then
            if node.param2 > 3 then
                node.param2 = node.param2 - 4
                minetest.swap_node(pos, node)
                user:set_wielded_item("bucket:bucket_water")
            end
        end
    end,
})