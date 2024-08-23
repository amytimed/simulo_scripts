Scene:reset():destroy();
Scene:set_gravity(vec2(0, 0));

local player = Scene:add_circle({
    name = "player",
    position = vec2(0, 0),
    radius = 0.5,
    is_static = false,
    color = 0xaaaaaa,
});

local hash = Scene:add_component({
    name = "player Component",
    id = "@amy/lasersight/player",
    version = "0.2.0",
    code = temp_load_string('./scripts/@amy/lasersight/player.lua')
});

player:add_component(hash);