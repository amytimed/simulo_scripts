local image = temp_load_image('./scripts/@amy/pylon_pixel/cone.png');

local pixel_size = 1 / 12;
local half_width = (image.width / 2) * pixel_size;
local half_height = (image.height / 2) * pixel_size;

local base = Scene:add_circle({
    position = vec2(0, 0),
    radius = pixel_size,
    is_static = false,
    color = Color:rgba(0, 0, 0, 0),
});

base:set_angle_locked(true);

for x=0,(image.width - 1) do
    for y=0,(image.height - 1) do
        local pixel = image:get_pixel(vec2(x, y));

        if pixel.a > 0 then
            local box = Scene:add_box({
                position = vec2((x * pixel_size) - half_width + (pixel_size * 0.5), -(y * pixel_size) + half_height - (pixel_size * 0.5)),
                size = vec2(pixel_size, pixel_size),
                is_static = false,
                color = Color:rgba(pixel.r, pixel.g, pixel.b, pixel.a),
                name = "Pixel"
            });
            
            box:set_restitution(0);

            box:bolt_to(base);
        end;
    end;
end;

base:set_name("player_100");

local hash = Scene:add_component({
    name = "Pylon",
    id = "@amy/pylon_pixel/pylon",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/pylon_pixel/pylon.lua')
});

base:add_component(hash);