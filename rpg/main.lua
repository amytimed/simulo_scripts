Scene:reset();
Scene:set_gravity(vec2(0, 0));

local hash = Scene:add_component({
    name = "Player",
    id = "@amy/rpg/player",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/rpg/player.lua')
});

function draw_wall(start_p, end_p, wall_height, wall_color, ceiling_color)
    local x = (start_p.x + end_p.x) / 2;
    local y = math.min(start_p.y, end_p.y);

    local width = math.abs(end_p.x - start_p.x);
    local height = math.abs(end_p.y - start_p.y);

    local size = vec2(width, height);
    local pos = vec2((end_p.x + start_p.x) / 2, (end_p.y + start_p.y) / 2);

    Scene:add_box({
        position = pos,
        size = size,
        color = 0xff0000,
        is_static = true,
    });

    Scene:add_box({
        position = (start_p + end_p) / 2,
        size = vec2(math.abs(start_p.x - end_p.x), math.abs(start_p.y - end_p.y)),
        color = color,
        is_static = true,
    }):temp_set_collides(false);
end;

draw_wall(vec2(0, 5), vec2(10, 10), 1, Color:hsva(0, 50, 10, 128), Color:hsva(0, 50, 100, 128));

local player_collider = Scene:add_box({
    name = "Player Collider",
    position = vec2(0, -5),
    size = vec2(0.5, 0.1),
    is_static = false,
    color = 0xff0000,
});

player_collider:add_component(hash);