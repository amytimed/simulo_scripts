local ratio = 16.0 / 9.0;

local x_pixels = 16;
local y_pixels = 9;

-- 0 gravity since this is top-down
Scene:set_gravity(vec2(0, 0));
--Scene.background_color = 0x000000;

local camera = Scene:add_circle({
    position = vec2(-5, 0),
    radius = 0.15,
    color = 0x63a9ff,
    is_static = false,
});
camera:set_friction(0);

-- We represent the 3D camera with a 2D physics object. we can use :get_position() and :get_angle() on it.
-- we will use Z as up in this 3D. we will assume Z is 0 for all objects

local boxes = {};
local spheres = {};

-- Helper function to spawn a box
function spawn_box(x, y, z, size_x, size_y, size_z)
    local box = Scene:add_box({
        position = vec2(x / 2, y / 2),
        size = vec2(size_x, size_y),
        color = 0xa0a0a0,
        is_static = true,
        name = tostring(size_x) .. "," .. tostring(size_y) .. "," .. tostring(size_z) .. "," .. tostring(z)
    });
    table.insert(boxes, box);
end

function spawn_bullet(x, y, z)
    local box = Scene:add_box({
        position = vec2(x / 2, y / 2),
        size = vec2(0.02, 0.04),
        color = 0xffff00,
        is_static = false,
        name = tostring(0.02) .. "," .. tostring(0.04) .. "," .. tostring(0.02) .. "," .. tostring(z)
    });
    table.insert(boxes, box);
    return box;
end

-- Horizontal wall at y = 5
for i = -5, 5 do
    spawn_box(-10 + i, 5.5, 0, 0.5, 0.1, 0.5)
end

-- Horizontal wall at y = -5
for i = -5, 5 do
    spawn_box(-10 + i, -5.5, 0, 0.5, 0.1, 0.5)
end

-- Vertical wall at x = -15
for i = -5, 5 do
    spawn_box(-15.5, 0 - i, 0, 0.1, 0.5, 0.5)
end

-- Vertical wall at x = -5
for i = -5, 5 do
    spawn_box(-4.5, 0 - i, 0, 0.1, 0.5, 0.5)
end

--[[
local sphere = Scene:add_circle({
    position = vec2(-12, 0),
    radius = 0.5,
    color = 0xff00ff,
    is_static = false,
    name = "0.5"
});
table.insert(spheres, sphere);

local sphere = Scene:add_circle({
    position = vec2(-12, 1),
    radius = 0.1,
    color = 0x00ff00,
    is_static = false,
    name = "0.1"
});
table.insert(spheres, sphere);

local box = Scene:add_box({
    position = vec2(-10, 2),
    size = vec2(0.5, 0.5),
    color = 0xff7070,
    is_static = false,
    name = "0.5,0.5"
});
table.insert(boxes, box);

local box = Scene:add_box({
    position = vec2(-11.1, 2),
    size = vec2(0.5, 0.5),
    color = 0x70ff70,
    is_static = false,
    name = "0.5,0.5"
});
table.insert(boxes, box);

local box = Scene:add_box({
    position = vec2(-8.9, 2),
    size = vec2(0.5, 0.5),
    color = 0x7070ff,
    is_static = false,
    name = "0.5,0.5"
});
table.insert(boxes, box);

local box = Scene:add_box({
    position = vec2(-8.9, 1),
    size = vec2(0.2, 0.2),
    color = 0xffffff,
    is_static = false,
    name = "0.2,0.2"
});

table.insert(boxes, box);
]]

-- We will render just the boxes in boxes as cubes, nothing more

-- Define the vec3 function to create 3D vector objects
function vec3(x, y, z)
    return {x = x, y = y, z = z}
end

-- Constants
local fov = 1.5708;
local aspect_ratio = 16 / 9
local near = 0.1 -- near clipping plane
local far = 100.0 -- far clipping plane

-- Helper function to rotate coordinates
function rotate(a, b, angle)
    return a * math.cos(angle) - b * math.sin(angle), a * math.sin(angle) + b * math.cos(angle)
end

-- Helper function to project a 3D point to 2D using perspective projection
--[[
function project_point(point)
    local camera_position = camera:get_position()
    local yaw = -camera:get_angle()
    local pitch = 0
    local roll = 0

    -- Transform the point to the camera's local space
    local x = point.x - camera_position.x
    local y = point.y - camera_position.y
    local z = point.z - 0.5

    -- Apply yaw (rotation around Z axis)
    x, y = rotate(x, y, yaw)
    -- Apply pitch (rotation around Y axis)
    y, z = rotate(y, z, pitch)
    -- Apply roll (rotation around X axis)
    x, z = rotate(x, z, roll)

    -- Perspective projection formula
    local perspective = x_pixels / (2 * math.tan(fov / 2))
    local screen_x = (x / y) * perspective + x_pixels / 2
    local screen_y = (z / y) * perspective + y_pixels / 2

    return vec2(screen_x, screen_y)
end
]]

local camera_pitch = 0;

-- Helper function to project a 3D point to 2D using perspective projection
function project_point(point)
    local camera_position = camera:get_position()
    local yaw = -camera:get_angle()
    local pitch = camera_pitch;
    local roll = 0

    -- Transform the point to the camera's local space
    local x = point.x - camera_position.x
    local y = point.y - camera_position.y
    local z = point.z - 0.25

    -- Apply yaw (rotation around Z axis)
    x, y = rotate(x, y, yaw)
    -- Apply pitch (rotation around Y axis)
    y, z = rotate(y, z, pitch)
    -- Apply roll (rotation around X axis)
    x, z = rotate(x, z, roll)

    -- Check if the point is behind the camera
    if y <= near then
        y = near
    end

    -- Perspective projection formula
    local perspective = x_pixels / (2 * math.tan(fov / 2))
    local screen_x = (x / y) * perspective + x_pixels / 2
    local screen_y = (z / y) * perspective + y_pixels / 2

    return vec2(screen_x, screen_y), y
end


function draw_line(line_start,line_end,thickness,color,static)
    local pos = (line_start+line_end)/2
    local sx = (line_start-line_end):magnitude()
    local relative_line_end = line_end-pos
    local rotation = math.atan(relative_line_end.y/relative_line_end.x)
    local line = Scene:add_box({
        position = pos / 2,
        size = vec2(sx/2, thickness/2),
        is_static = static,
        color = color
    });

    line:temp_set_collides(false);
    line:set_angle(rotation)

    return line
end;

local lines = {};

-- Helper function to draw a circle (sphere) with projected radius
function draw_circle(center, radius, color)
    local circle = Scene:add_circle({
        position = center,
        radius = radius,
        color = color,
        is_static = true
    });

    circle:temp_set_collides(false);

    return circle
end

Scene:add_box({
    position = vec2(x_pixels / 4, y_pixels / 4),
    size = vec2(x_pixels / 2, y_pixels / 2),
    color = 0x000000,
    is_static = true,
});

-- Render loop
function render()
    for _, line in ipairs(lines) do
        line:destroy();
    end

    lines = {}

    local forward = transform_vector(vec2(0, 100), camera:get_angle());
    local point, depth = project_point(vec3(forward.x, forward.y, 0.5));

    if math.max(0, point.y / 2) ~= 0 then
        table.insert(lines, Scene:add_box({
            position = vec2(x_pixels / 4, math.min(point.y / 4, y_pixels / 4)),
            size = vec2(x_pixels / 2, math.min(math.max(0, point.y / 2), y_pixels / 2)),
            color = 0x222222,
            is_static = true,
        }));
    end;

    -- Draw each sphere
    for _, sphere in ipairs(spheres) do
        local pos = sphere:get_position()
        local radius = tonumber(sphere:get_name());
        
        -- Project the center of the sphere
        local projected_center, depth = project_point(vec3(pos.x, pos.y, radius))
        
        -- Adjust radius based on depth using the formula f * r / sqrt(d^2 - r^2)
        local projected_radius = (x_pixels / (2 * math.tan(fov / 2))) * radius / math.sqrt(depth^2 - radius^2)

        -- Draw the circle with the projected radius
        local circle = draw_circle(projected_center, math.abs(projected_radius), sphere.color)
        table.insert(lines, circle)
    end

    -- Draw each box as a cube (only front edges for simplicity)
    for i, box in ipairs(boxes) do
        if not box:is_destroyed() then
            local pos = box:get_position()
            local angle = box:get_angle()

            -- Parse the size from the box name and double it
            local name = box:get_name()
            local size_x, size_y, size_z, z_offset = name:match("([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+)")
            local size = vec2(tonumber(size_x), tonumber(size_y))

            local height = size_z;

            -- Define the corners of the box in 3D space
            local corners = {
                vec3(pos.x - size.x / 2, pos.y - size.y / 2, z_offset),
                vec3(pos.x + size.x / 2, pos.y - size.y / 2, z_offset),
                vec3(pos.x + size.x / 2, pos.y + size.y / 2, z_offset),
                vec3(pos.x - size.x / 2, pos.y + size.y / 2, z_offset),
                vec3(pos.x - size.x / 2, pos.y - size.y / 2, height + z_offset),
                vec3(pos.x + size.x / 2, pos.y - size.y / 2, height + z_offset),
                vec3(pos.x + size.x / 2, pos.y + size.y / 2, height + z_offset),
                vec3(pos.x - size.x / 2, pos.y + size.y / 2, height + z_offset),
            }

            -- Rotate corners around the Z axis of the box
            for i, corner in ipairs(corners) do
                local x, y = rotate(corner.x - pos.x, corner.y - pos.y, angle)
                corners[i] = vec3(x + pos.x, y + pos.y, corner.z)
            end

            -- Project the corners to 2D
            local projected_corners = {}
            for _, corner in ipairs(corners) do
                local projected, depth = project_point(corner)
                projected_corners[#projected_corners + 1] = {projected, depth}
            end

            -- Draw the edges of the box
            local edges = {
                {1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Front face
                {5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Back face
                {1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Connecting edges
            }

            for _, edge in ipairs(edges) do
                local start = projected_corners[edge[1]]
                local end_point = projected_corners[edge[2]]

                if start[2] > near and end_point[2] > near then
                    table.insert(lines, draw_line(start[1], end_point[1], 0.01, box.color, true))
                elseif start[2] > near then
                    -- Intersect line with near clipping plane
                    local t = (near - end_point[2]) / (start[2] - end_point[2])
                    local intersect_point = vec2(
                        end_point[1].x + t * (start[1].x - end_point[1].x),
                        end_point[1].y + t * (start[1].y - end_point[1].y)
                    )
                    table.insert(lines, draw_line(start[1], intersect_point, 0.01, box.color, true))
                elseif end_point[2] > near then
                    -- Intersect line with near clipping plane
                    local t = (near - start[2]) / (end_point[2] - start[2])
                    local intersect_point = vec2(
                        start[1].x + t * (end_point[1].x - start[1].x),
                        start[1].y + t * (end_point[1].y - start[1].y)
                    )
                    table.insert(lines, draw_line(intersect_point, end_point[1], 0.01, box.color, true))
                end
            end
        else
            table.remove(boxes, i);
        end;
    end
end

local x_move = 0;
local y_move = 0;
local z_spin = 0;
local move_speed = 1;
local spin_speed = 1;
local pitch_speed = 0.01;

-- Helper function to transform a 2D vector by an angle
function transform_vector(vector, angle)
    local x = vector.x * math.cos(angle) - vector.y * math.sin(angle)
    local y = vector.x * math.sin(angle) + vector.y * math.cos(angle)
    return vec2(x, y)
end

local proj_hash = Scene:add_component({
    name = "Projectile",
    id = "@amy/wireframe3d/projectile",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/wireframe3d/projectile.lua')
});

function on_update()
    -- Reset movement and spin values
    x_move = 0;
    y_move = 0;
    z_spin = 0;

    -- Move up
    if Input:key_pressed("W") then
        y_move = move_speed;
    end

    -- Move down
    if Input:key_pressed("S") then
        y_move = -move_speed;
    end

    -- Move left
    if Input:key_pressed("A") then
        x_move = -move_speed;
    end

    -- Move right
    if Input:key_pressed("D") then
        x_move = move_speed;
    end

    -- Spin left
    if Input:key_pressed("ArrowLeft") then
        z_spin = spin_speed;
    end

    -- Spin right
    if Input:key_pressed("ArrowRight") then
        z_spin = -spin_speed;
    end

    if Input:key_pressed("ArrowUp") then
        camera_pitch -= pitch_speed;
    end

    if Input:key_pressed("ArrowDown") then
        camera_pitch += pitch_speed;
    end

    if Input:key_pressed("Z") then
        Input:set_pointer_locked(true);

        local delta_mouse = Input:pointer_movement() * 60.0;
        camera_pitch -= delta_mouse.y * pitch_speed;
        local angle = camera:get_angle();
        angle -= delta_mouse.x * 0.01;

        camera:set_angle(angle);
        if delta_mouse.x ~= 0 or delta_mouse.y ~= 0 then
            render();
        end;
    else
        Input:set_pointer_locked(false);
    end;

    if Input:key_just_pressed("C") then
        -- random rgb color
        local r = math.random(0x40, 0xff);
        local g = math.random(0x40, 0xff);
        local b = math.random(0x40, 0xff);

        -- put it together to form single color value, like 0xRRGGBB
        local color = r * 0x10000 + g * 0x100 + b;

        local box = Scene:add_box({
            position = camera:get_position() + transform_vector(vec2(0, 0.5), camera:get_angle()),
            size = vec2(0.2, 0.2),
            is_static = false,
            color = color,
            name = "0.2,0.2,0.2,0"
        });
        box:set_angle(camera:get_angle());
        table.insert(boxes, box);
    end;

    if Input:key_just_pressed("E") then
        local pos = camera:get_position() + transform_vector(vec2(0, 0.25), camera:get_angle());
        local box = spawn_bullet(pos.x, pos.y, 0.4);
        box:set_angle(camera:get_angle());
        box:temp_set_group_index(-69);
        box:add_component(proj_hash);
        box:set_linear_velocity(transform_vector(vec2(0, 10), camera:get_angle()));
    end;

    if Input:key_just_pressed("V") then
        local box = Scene:add_box({
            position = camera:get_position() + transform_vector(vec2(0, 0.5), camera:get_angle()),
            size = vec2(0.18, 0.18),
            is_static = false,
            color = 0xff0000,
            name = "0.18,0.18,0.4,0"
        });
        box:set_angle(camera:get_angle());
        table.insert(boxes, box);
    end;
end;

-- Call render function in a loop or update it periodically
function on_step()
    local angle = camera:get_angle()

    -- Combine x_move and y_move into a single vector and transform it based on the camera's angle
    local move_vector = vec2(x_move, y_move)
    local transformed_vector = transform_vector(move_vector, angle)

    camera:set_linear_velocity(transformed_vector)
    camera:set_angular_velocity(z_spin)
    render()
end