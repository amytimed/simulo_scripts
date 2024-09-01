Scene:reset();

--[[local box1 = Scene:add_box({
    position = vec2(-0.5, 0),
    size = vec2(1,1),
    color = 0xffffff,
    is_static = false,
});

local box2 = Scene:add_box({
    position = vec2(0.5, 0),
    size = vec2(1,1),
    color = 0xff0000,
    is_static = false,
});

Scene:add_fixed_joint_at_world_point({
    point = vec2(0, 0),
    object_a = box1,
    object_b = box2,
    strength = 10,
    damping = 0.1,
    collide_connected = false,
});]]

local grid_size = 5  -- size of the grid (5x5)
local box_size = vec2(1, 1)
local spacing = 0  -- space between boxes
local start_position = vec2(-2, -2)  -- starting position of the grid

-- Create a 2D array to hold the boxes
local boxes = {}

-- Generate the grid of boxes
for y = 1, grid_size do
    boxes[y] = {}
    for x = 1, grid_size do
        local position = vec2(
            start_position.x + (x - 1) * (box_size.x + spacing),
            start_position.y + (y - 1) * (box_size.y + spacing)
        )
        local box = Scene:add_box({
            position = position,
            size = box_size,
            color = 0xffffff,
            is_static = false,
        })
        boxes[y][x] = box
    end
end

-- Create fixed joints between adjacent boxes
for y = 1, grid_size do
    for x = 1, grid_size do
        local box = boxes[y][x]
        
        -- Connect to the box on the right
        if x < grid_size then
            Scene:add_fixed_joint_at_world_point({
                point = box:get_position() + vec2(box_size.x / 2, 0),
                object_a = box,
                object_b = boxes[y][x + 1],
                strength = 10000,
                damping = 0.1,
                collide_connected = false,
            })
        end
        
        -- Connect to the box below
        if y < grid_size then
            Scene:add_fixed_joint_at_world_point({
                point = box:get_position() + vec2(0, box_size.y / 2),
                object_a = box,
                object_b = boxes[y + 1][x],
                strength = 10000,
                damping = 0.1,
                collide_connected = false,
            })
        end
    end
end
