Scene:reset();

local car_body = Scene:add_box({
    position = vec2(0, -10 + (0.5 * 0.5) + 0.3),
    size = vec2(1.8, 0.6),
    is_static = false,
    color = Color:hex(0xc14f4f),
    name = "Car Body",
});

local hash = Scene:add_component({
    name = "Car",
    id = "@amy/car/car",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/car/car.lua')
});

car_body:add_component(hash);