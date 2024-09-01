Scene:reset();

--[[
Scene:add_box({
    position = vec2(1, -10 + 0.5),
    size = vec2(0.1, 1),
    color = 0xffa0a0,
    is_static = true
});

Scene:add_box({
    position = vec2(0, -10 + 0.5),
    size = vec2(1, 1),
    color = Color:rgba(255,255,255,2),
    is_static = true
}):temp_set_collides(false);

Scene:add_box({
    position = vec2(0, -10 + 0.5),
    size = vec2(0.01, 1),
    color = Color:rgba(255,255,255,5),
    is_static = true
}):temp_set_collides(false);

Scene:add_box({
    position = vec2(0, -10 + 0.5),
    size = vec2(1, 0.01),
    color = Color:rgba(255,255,255,5),
    is_static = true
}):temp_set_collides(false);

]]

local spawn_pylon = require('./scripts/@amy/pylon/pylon.lua');

spawn_pylon(vec2(0, 0));