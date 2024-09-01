local beam_color = Color:hex(0x34ff67);

local target_beam_length = 2;
local beam_length = 0;
local beam_speed = 0.2;

local enabled = false;

function on_update()
    if Input:key_just_pressed("E") then
        enabled = not enabled;
    end;
end;

local gizmos = {};

function clear_gizmos()
    for i=1,#gizmos do
        gizmos[i]:destroy();
    end;
    gizmos = {};
end;

function gizmo_circle(pos, color, r, name)
    local c = Scene:add_circle({
        position = pos,
        radius = r,
        is_static = true,
        color = color,
        name = name,
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

function vec2_dot(v1, v2)
    return (v1.x * v2.x) + (v1.y * v2.y);
end;

function on_step()
    clear_gizmos();

    if enabled then
        beam_length += beam_speed;
        beam_length = math.min(beam_length, target_beam_length);
    else
        beam_length -= beam_speed;
        beam_length = math.max(beam_length, 0);
    end;

    if beam_length < 0.05 then return; end;

    local angle = self:get_angle();
    local direction = vec2(math.cos(angle), math.sin(angle));

    local origin = self:get_position() + (direction * (12.1 * 0.0625));

    local hits = Scene:raycast({
        origin = origin,
        direction = direction,
        distance = beam_length,
        closest_only = false,
    });

    local segments = 100;

    local unbeam = Color:rgba(beam_color.r, beam_color.g, beam_color.b, 0);
    
    for i=1,segments do
        draw_line(origin + (((direction * beam_length) / segments) * (i - 1)), origin + (((direction * beam_length) / segments) * i), 0.03, Color:mix(beam_color, unbeam, i / segments), true);
    end;

    for i=1,#hits do
        if not hits[i].object:temp_get_is_static() then
            local lin_vel = hits[i].object:get_linear_velocity();
            local ang_vel = hits[i].object:get_angular_velocity();
            hits[i].object:detach();
            hits[i].object:set_linear_velocity(lin_vel);
            hits[i].object:set_angular_velocity(ang_vel);

            local object_position = hits[i].object:get_position()
            local hit_to_origin = object_position - origin

            -- Determine the perpendicular direction
            local perp_direction = vec2(-direction.y, direction.x)  -- Perpendicular direction
            local dot_product = vec2_dot(hit_to_origin, perp_direction)

            -- Decide which direction to push based on the dot product
            local push_direction = perp_direction
            if dot_product < 0 then
                push_direction = -perp_direction
            end

            hits[i].object:apply_force_to_center(push_direction * 1)
        end;
        if hits[i].object:get_name() ~= "Simulo Planet" then
            gizmo_circle(hits[i].point, Color:rgb(80,80,80), 0.01, "Light");
            gizmo_circle(hits[i].point, Color:hex(0xffffff), 0.03, "Joe");
        end;
        --[[local away = hits[i].object:get_position() - hits[i].point;
        hits[i].object:apply_force_to_center(away * 10);]]
    end;
end;

function on_destroy()
    clear_gizmos();
end;