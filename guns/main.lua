Scene:reset();

local hash = Scene:add_component({
    name = "Rifle",
    id = "@amy/guns/rifle",
    version = "0.2.0",
    code = temp_load_string('./scripts/@amy/guns/rifle.lua')
});

local manager = Scene:add_box({
    name = "Rifle",
    size = vec2(1, 0.15),
    position = vec2(0, -9 + (0.15 / 2)),
    is_static = false,
    color = 0xa0a0a0,
});

manager:add_component(hash);