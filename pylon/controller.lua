local enabled = false;

local speed = 4.1;
local jump_force = 5.1;

local debug = false;

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
        radius = 0.01,
        is_static = true,
        color = color,
    });
    c:temp_set_collides(false);
    table.insert(gizmos, c);
end;

function gizmo_raycast(tableo, color)
    local line = line(tableo.origin, tableo.origin + (tableo.direction:normalize() * tableo.distance), 0.01, color, true);
    table.insert(gizmos, line);
end;

function line(line_start,line_end,thickness,color,static)
    local pos = (line_start+line_end)/2
    local sx = (line_start-line_end):magnitude()
    local relative_line_end = line_end-pos
    local rotation = math.atan(relative_line_end.y/relative_line_end.x)
    local line = Scene:add_box({
        position = pos,
        size = vec2(sx, thickness),
        is_static = static,
        color = color
    });

    line:temp_set_collides(false);
    line:set_angle(rotation)

    return line
end;

function on_update()
    if Input:key_just_pressed("X") then
        enabled = not enabled;
        self:set_angle_locked(enabled);
        if enabled then self:set_angle(0); end;
    end;

    if Input:key_just_pressed("Q") then
        debug = not debug;
    end;

    if not enabled then return; end;

    local current_vel = self:get_linear_velocity();
    local update_vel = false;

    if Input:key_pressed("D") then
        if current_vel.x < speed then
            current_vel.x = speed;
            update_vel = true;
        end;
    end;
    if Input:key_pressed("A") then
        if current_vel.x > -speed then
            current_vel.x = -speed;
            update_vel = true;
        end;
    end;

    local grounded = ground_check();

    if Input:key_pressed("W") and grounded then
        if current_vel.y < jump_force then
            current_vel.y = jump_force;
            update_vel = true;
        end;
    end;

    if update_vel then
        self:set_linear_velocity(current_vel);
    end;
end;

function on_step()
    clear_gizmos();

    if debug then
        --[[for _, offset in ipairs(ground_check_points) do
            gizmo_circle(self:get_position() - offset, 0xff0000);
        end;]]
        gizmo_raycast({
            origin = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5)),
            direction = vec2(0, -1),
            distance = (2 / 12) + 0.01,
            closest_only = false,
        }, 0xff0000);
        gizmo_raycast({
            origin = self:get_position() + vec2(0.46875 + 0.01, (-4 * (1 / 12) + 0.5)),
            direction = vec2(0, -1),
            distance = (2 / 12) + 0.01,
            closest_only = false,
        }, 0xff0000);
        gizmo_raycast({
            origin = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5) - (2 / 12) - 0.01),
            direction = vec2(1, 0),
            distance = 0.9375 + 0.02,
            closest_only = false,
        }, 0xff0000);
        gizmo_circle(self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5)), 0xff0000);
        gizmo_circle(self:get_position() + vec2(0.46875 + 0.01, (-4 * (1 / 12) + 0.5)), 0xff0000);
    end;
end;

function ground_check()
    local hits1 = Scene:raycast({
        origin = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5)),
        direction = vec2(0, -1),
        distance = (2 / 12) + 0.01,
        closest_only = false,
    });
    if #hits1 > 0 then return true; end;

    local hits2 = Scene:raycast({
        origin = self:get_position() + vec2(0.46875 + 0.01, (-4 * (1 / 12) + 0.5)),
        direction = vec2(0, -1),
        distance = (2 / 12) + 0.01,
        closest_only = false,
    });
    if #hits2 > 0 then return true; end;

    local hits3 = Scene:raycast({
        origin = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5) - (2 / 12) - 0.01),
        direction = vec2(1, 0),
        distance = 0.9375 + 0.02,
        closest_only = false,
    });
    if #hits3 > 0 then return true; end;

    local circle1 = Scene:get_objects_in_circle({
        position = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5)),
        radius = 0,
    });
    if #circle1 > 0 then return true; end;
    local circle2 = Scene:get_objects_in_circle({
        position = self:get_position() + vec2(0.46875 + 0.01, (-4 * (1 / 12) + 0.5)),
        radius = 0,
    });
    if #circle2 > 0 then return true; end;

    return false;
end;