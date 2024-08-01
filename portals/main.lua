Scene:reset();

local hash = Scene:add_component({
    name = "Portal Manager",
    id = "@amy/portals/manager",
    version = "0.2.0",
    code = temp_load_string('./scripts/@amy/portals/manager.lua')
});

local manager = Scene:add_box({
    name = "Portal Manager",
    size = vec2(0.2, 0.2),
    position = vec2(0, -100),
    is_static = true,
    color = 0xa0a0a0,
});

manager:add_component(hash);