Scene:reset();

local hash = Scene:add_component({
    name = "Tetris Manager",
    id = "@amy/tetris/manager",
    version = "0.2.0",
    code = temp_load_string('./scripts/@amy/tetris/manager.lua')
});

local manager = Scene:add_box({
    name = "Tetris Manager",
    size = vec2(0.2, 0.2),
    position = vec2(0, -100),
    is_static = true,
    color = 0xa0a0a0,
});

manager:add_component(hash);