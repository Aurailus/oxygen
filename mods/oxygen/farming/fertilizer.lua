minetest.register_craftitem("farming:fertilizer", {
  description = "Ash Fertilizer",
  groups = {fertilizer = 1},
  inventory_image = "farming_fertilizer.png",
  stack_max = 99,
  on_place = function(itemstack, user, pointed_thing)
    if pointed_thing.type == "node" then
      local nodepos = pointed_thing.under
      local node = minetest.get_node(nodepos).name
      for k, v in pairs(farming.fertilizable) do
        if k == node or minetest.get_item_group(node, k) > 0 then
          for i = 0, 20 do
            minetest.add_particle({
              pos = vector.new(nodepos.x,
                               nodepos.y,
                               nodepos.z),
              velocity = vector.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
              size = 0.4,
              expirationtime = 0.4,
              collisiondetection = false,
              vertical = false,
              glow = false,
              texture = "farming_particle.png"
            })  
          end

          v(nodepos)
          itemstack:take_item()
          
          break
        end
      end
      return itemstack
    end
  end
})

farming.fertilizable = {}

farming.fertilizable["default:sapling"] = function(nodepos)
  local timer = minetest.get_node_timer(nodepos)
  timer:set(timer:get_timeout(), math.min(timer:get_elapsed() + (60 * 7), timer:get_timeout()))
  print(timer:get_elapsed())
end

farming.fertilizable["group:farm_plot"] = function(nodepos)
  local meta = minetest.get_meta(nodepos)
  meta:set_int("growth_tick", meta:get_int("growth_tick") + 120)
end

minetest.register_craft({
  output = "farming:fertilizer",
  recipe = {
    {"apocalypse:ash", "apocalypse:ash"},
    {"apocalypse:ash", "apocalypse:ash"}
  }
})