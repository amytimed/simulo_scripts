local gizmos = {};

function clear_gizmos()
    for i=1,#gizmos do
        gizmos[i]:destroy();
    end;
    gizmos = {};
end;

function gizmo_circle(pos, color)
    local c = Scene:add_circle({
        position = pos,
        radius = 0.05,
        is_static = true,
        color = color,
    });
    c:temp_set_collides(false);
    table.insert(gizmos, c);
end;

function gizmo_raycast(tableo, color)
    draw_line(tableo.origin, tableo.origin + (tableo.direction:normalize() * tableo.distance), 0.05, color, true);
end;

function draw_line(line_start, line_end, thickness, color, static)
    local pos = (line_start + line_end) / 2;
    local sx = (line_start - line_end):magnitude();
    local relative_line_end = line_end - pos;
    local rotation = math.atan(relative_line_end.y / relative_line_end.x)
    local line = Scene:add_box({
        position = pos,
        size = vec2(sx, thickness),
        is_static = static,
        color = color
    });

    line:temp_set_collides(false);
    line:set_angle(rotation);

    table.insert(gizmos, line);

    return line
end;

-- Function to calculate the dot product of two vec2 vectors
local function dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

-- Function to multiply a vec2 by a scalar
local function mul_scalar(v, scalar)
    return vec2(v.x * scalar, v.y * scalar)
end

-- Function to subtract one vec2 from another
local function sub(v1, v2)
    return vec2(v1.x - v2.x, v1.y - v2.y)
end

-- Function to reflect a vector `I` across a surface normal `N`
local function reflect(I, N)
    -- R = I - 2 * (dot(I, N)) * N
    local dotIN = dot(I, N)
    local reflectDir = sub(I, mul_scalar(N, 2 * dotIN))
    return reflectDir
end

function on_step()
    clear_gizmos();

    local angle = self:get_angle();
    local direction = vec2(math.cos(angle), math.sin(angle));

    step({
        origin = self:get_position() + direction,
        direction = direction,
        distance = 5,
        closest_only = true,
    });
end;

function step(cast)
    if cast.distance <= 0 then
        return;
    end;

    local hits = Scene:raycast(cast);
    if #hits == 0 then
        draw_line(cast.origin, cast.origin + (cast.direction * cast.distance), 0.05, self.color, true);
        return;
    end;

    local distance = (hits[1].point - cast.origin):magnitude();

    --gizmo_raycast(cast, 0xff0000);
    draw_line(cast.origin, hits[1].point, 0.05, self.color, true);

    --draw_line(hits[1].point, hits[1].point + hits[1].normal, 0.05, 0x0000ff, true);

    local reflected = reflect(cast.direction, hits[1].normal);

    --draw_line(hits[1].point, hits[1].point + reflected, 0.05, 0xffff00, true);

    step({
        origin = hits[1].point,
        direction = reflected,
        distance = cast.distance - distance,
        closest_only = true,
    });
end;