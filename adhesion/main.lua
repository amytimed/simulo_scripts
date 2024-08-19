Scene:reset();

local hash = Scene:add_component({
    name = "Adhesion",
    id = "@amy/adhesion/adhesion",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/adhesion/adhesion.lua')
});

local box = Scene:add_box({
    position = vec2(0, -6),
    size = vec2(1, 1),
    color = Color:hex(0x8ec25e),
    is_static = false,
});

box:add_component(hash);

local plank = Scene:add_box({
    position = vec2(3, -6),
    size = vec2(2.5, 0.5),
    color = Color:hex(0x946650),
    is_static = false,
});

local plank2 = Scene:add_box({
    position = vec2(3.5, -5),
    size = vec2(2.5, 0.5),
    color = Color:hex(0x946650),
    is_static = false,
});