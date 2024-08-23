Scene:reset();

local laser = Scene:add_box({
    name = "laser",
    position = vec2(2, -19.5) / 2,
    size = vec2(1.5, 0.5),
    is_static = false,
    color = 0xaaaaaa,
});

local hash = Scene:add_component({
    name = "laser Component",
    id = "@amy/laser/laser",
    version = "0.2.0",
    code = temp_load_string('./scripts/@amy/laser/laser.lua')
});

laser:add_component(hash);