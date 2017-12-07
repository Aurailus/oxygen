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
          if v(nodepos) then itemstack:take_item() end
          break
        end
      end
      return itemstack
    end
  end
})

local function particles(pos)
  for i = 0, 20 do
    minetest.add_particle({
      velocity = vector.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
      size = 0.4,
      expirationtime = 0.4,
      collisiondetection = false,
      vertical = false,
      glow = false,
      texture = "farming_particle.png"
    })  
  end
end

farming.fertilizable = {}

farming.fertilizable["default:sapling"] = function(nodepos)
  particles(pos)
  local timer = minetest.get_node_timer(nodepos)
  timer:set(timer:get_timeout(), math.min(timer:get_elapsed() + (60 * 7), timer:get_timeout()))
  print(timer:get_elapsed())
  return true
end

farming.fertilizable["farming:fertilizer_bin"] = function(nodepos)
  local fertilizer_count = minetest.get_node(nodepos).param2 + 1
  if fertilizer_count < 63 then
    minetest.swap_node(nodepos, {name = "farming:fertilizer_bin", param2 = minetest.get_node(nodepos).param2 + 1})
    return true
  end
  return false
end

farming.fertilizable["farm_plot"] = function(nodepos)
  particles(pos)
  local meta = minetest.get_meta(nodepos)
  meta:set_int("growth_tick", meta:get_int("growth_tick") + 120)
  return true
end

minetest.register_craft({
  output = "farming:fertilizer",
  recipe = {
    {"apocalypse:ash", "apocalypse:ash"},
    {"apocalypse:ash", "apocalypse:ash"}
  }
})