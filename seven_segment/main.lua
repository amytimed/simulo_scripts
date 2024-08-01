Scene:reset();

-- Segment patterns for each digit, true means the segment is on
local digits = {
    ['0'] = {
        {true, true, true},
        {true, false, true},
        {true, false, true},
        {true, false, true},
        {true, true, true}
    },
    ['1'] = {
        {false, false, true},
        {false, false, true},
        {false, false, true},
        {false, false, true},
        {false, false, true}
    },
    ['2'] = {
        {true, true, true},
        {false, false, true},
        {true, true, true},
        {true, false, false},
        {true, true, true}
    },
    ['3'] = {
        {true, true, true},
        {false, false, true},
        {true, true, true},
        {false, false, true},
        {true, true, true}
    },
    ['4'] = {
        {true, false, true},
        {true, false, true},
        {true, true, true},
        {false, false, true},
        {false, false, true}
    },
    ['5'] = {
        {true, true, true},
        {true, false, false},
        {true, true, true},
        {false, false, true},
        {true, true, true}
    },
    ['6'] = {
        {true, true, true},
        {true, false, false},
        {true, true, true},
        {true, false, true},
        {true, true, true}
    },
    ['7'] = {
        {true, true, true},
        {false, false, true},
        {false, false, true},
        {false, false, true},
        {false, false, true}
    },
    ['8'] = {
        {true, true, true},
        {true, false, true},
        {true, true, true},
        {true, false, true},
        {true, true, true}
    },
    ['9'] = {
        {true, true, true},
        {true, false, true},
        {true, true, true},
        {false, false, true},
        {true, true, true}
    },
    ['-'] = {
        {false, false, false},
        {false, false, false},
        {true, true, true},
        {false, false, false},
        {false, false, false},
    }
}

local function draw_digit(pos, size, color, digit)
    local digit_pattern = digits[digit]
    local objects = {}

    for y = 1, #digit_pattern do
        for x = 1, #digit_pattern[y] do
            if digit_pattern[y][x] then
                local offset = vec2((x - 1) * size, -(y - 1) * size) / 2;
                local box = Scene:add_box({
                    position = pos + offset,
                    size = vec2(size / 2, size / 2),
                    color = color,
                    is_static = true,
                });
                box:temp_set_collides(false);
                table.insert(objects, {
                    obj = box,
                    offset = offset,
                });
            end;
        end
    end

    return objects
end

local function draw_seven_segment_display(pos, size, color, number)
    local objects = {}
    local num_str = tostring(number);
    pos = pos - (vec2((((#num_str / 2) * 4) - 1) * size, -2 * size)) / 2;

    local final_offset = 0;
    local first_char = num_str:sub(1, 1);
    if first_char == "1" then
        final_offset = -size;
    end;

    for i = 1, #num_str do
        local digit = num_str:sub(i, i)
        local digit_objects = draw_digit(vec2(pos.x + final_offset + (i - 1) * 4 * size, pos.y), size, color, digit)
        for _, data in ipairs(digit_objects) do
            table.insert(objects, {
                obj = data.obj,
                offset = data.offset + (vec2((i - 1) * 4 * size, 0) - vec2((((#num_str / 2) * 4) - 1) * size, -2 * size) + vec2(final_offset, 0)) / 2
            })
        end
    end

    return objects
end;

function move_display(objects, new_pos)
    for _, data in ipairs(objects) do
        data.obj:set_position(new_pos + data.offset);
    end
end;

-- Example usage:
local pos = vec2(5, 5)
local size = 1
local color = 0xffffff
local number = 123
local objects = draw_seven_segment_display(pos, size, color, number)

Scene:add_circle({
    position = vec2(5, 5),
    color = 0xff0000,
    is_static = true,
    radius = 0.1,
});

Scene:add_circle({
    position = vec2(0, 0),
    color = 0xff0000,
    is_static = true,
    radius = 0.1,
});

move_display(objects, vec2(0, 0));