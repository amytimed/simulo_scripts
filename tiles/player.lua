self:set_restitution(0);
self:set_friction(1);
self:set_angle_locked(true);

local tile_type = "wood";

local ground_check_points = {
    vec2(0, 0.401),
    vec2(0.05, 0.401),
    vec2(-0.05, 0.401),
    vec2(0.19, 0.3),
    vec2(-0.19, 0.3),
    vec2(-0.1, 0.38),
    vec2(0.1, 0.38),
    vec2(0.14, 0.35),
    vec2(-0.14, 0.35),
    vec2(0.16, 0.33),
    vec2(-0.16, 0.33),
};

local inventory = {
    wood = 10000,
    stairs = 10000,
    slab = 10000,
};

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
    local line = draw_line(tableo.origin, tableo.origin + (tableo.direction:normalize() * tableo.distance), 0.01, color, true);
    table.insert(gizmos, line);
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

    return line
end;

local purged_prev = false;

local speed = 2.5;
local air_control_speed = 5;
local jump_force = 3.5;

local health_bar_fg = nil;
local health_bar_bg = nil;
local health_bar_offset = vec2(0, 0.55);
local health_bar_width = 0.8;
local health_bar_height = 0.05;
local prev_hp_value = 100;

local block_overlay = nil;

function update_health_bar(value)
    if health_bar_fg ~= nil then
        health_bar_fg:destroy();
    end;
    if health_bar_bg ~= nil then
        health_bar_bg:destroy();
    end;
    health_bar_bg = Scene:add_box({
        position = self:get_position() + health_bar_offset,
        size = vec2(health_bar_width, health_bar_height),
        color = 0x353341,
        is_static = true,
        name = "health_bg"
    });
    health_bar_bg:temp_set_collides(false);
    health_bar_fg = Scene:add_box({
        position = self:get_position() + health_bar_offset + (vec2(((value / 100.0) * health_bar_width) - health_bar_width, 0)) / 2,
        size = vec2((value / 100.0) * health_bar_width, health_bar_height),
        color = 0x93c472,
        is_static = true,
        name = "health_fg"
    });
    health_bar_fg:temp_set_collides(false);
end;

local place = false;

function on_update()
    if not purged_prev then
        -- On start we want to clear any lingering objects like healthbar or block overlay
        -- because if user saves and loads, those objects will sit there forever, since player creates new ones
        local all_objs = Scene:get_all_objects();
        for i=1,#all_objs do
            if (
                (all_objs[i]:get_name() == "health_bg") or
                (all_objs[i]:get_name() == "health_fg") or
                (all_objs[i]:get_name() == "block_overlay")
            ) then
                all_objs[i]:destroy();
            end;
        end;

        update_health_bar(100);

        purged_prev = true;
    end;

    local current_vel = self:get_linear_velocity();
    local update_vel = false;
    local grounded = ground_check();

    if grounded then
        --[[
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
        ]]
        if (not Input:key_pressed("D")) and (not Input:key_pressed("A")) then
            if current_vel.x > 0.01 or current_vel.x < -0.01 then
                current_vel.x /= 2;
                update_vel = true;
            end;
        end;
    end;
    --else
        -- air control
        if Input:key_pressed("D") then
            if current_vel.x < speed then
                self:apply_force_to_center(vec2(air_control_speed, 0));
            end;
        end;
        if Input:key_pressed("A") then
            if current_vel.x > -speed then
                self:apply_force_to_center(vec2(-air_control_speed, 0));
            end;
        end;
    --end;
    --[[
    if (not Input:key_pressed("D")) and (not Input:key_pressed("A")) then
        if current_vel.x > 0.01 or current_vel.x < -0.01 then
            current_vel.x /= 2;
            update_vel = true;
        end;
    end;]]
    if Input:key_pressed("W") and grounded then
        if current_vel.y < jump_force then
            current_vel.y = jump_force;
            update_vel = true;
            contacts = 0;
        end;
    end;

    if Input:key_just_pressed("Q") then
        debug = not debug;
    end;

    if Input:key_just_pressed("1") then
        tile_type = "wood";
    end;
    if Input:key_just_pressed("2") then
        tile_type = "stairs";
    end;
    if Input:key_just_pressed("3") then
        tile_type = "slab";
    end;

    if Input:key_just_pressed("R") then
        local snapped = snap(Input:pointer_pos(), 0.25);

        local objs = Scene:get_objects_in_circle({
            position = snapped,
            radius = 0.1,
        });

        for i=1,#objs do
            if starts(objs[i]:get_name(), "tile_") then
                local pos = objs[i]:get_position();
                local offset = snapped - pos;
--[[
                objs[i]:set_angle(objs[i]:get_angle() + math.rad(90));
                objs[i]:set_position(pos + vec2(offset.x * 2, 0)); -- temporary since setangle doesnt update transform]]
                -- Determine the current rotation step (0, 1, 2, 3)
                local rotation_step = math.floor((objs[i]:get_angle() / math.rad(90)) % 4)

                -- Adjust the position based on the rotation step
                if rotation_step == 0 then
                    objs[i]:set_position(pos + vec2(offset.x * 2, 0))
                elseif rotation_step == 1 then
                    objs[i]:set_position(pos + vec2(0, offset.y * 2))
                elseif rotation_step == 2 then
                    objs[i]:set_position(pos + vec2(offset.x * 2, 0))
                elseif rotation_step == 3 then
                    objs[i]:set_position(pos + vec2(0, offset.y * 2))
                end

                -- Rotate the tile by 90 degrees
                objs[i]:set_angle(objs[i]:get_angle() + math.rad(90))
                print("did it, breaking");
                break;
            end;
        end;
        print("Done hahah lmao gotty");
    end;

    if update_vel then
        self:set_linear_velocity(current_vel);
    end;

    if Input:pointer_just_pressed() then
        --toggle_block(Input:pointer_pos());
        place = not check(Input:pointer_pos());
    end;

    if Input:pointer_pressed() then
        set_block(Input:pointer_pos(), place);
    end;

    if block_overlay ~= nil then
        if not block_overlay:is_destroyed() then
            block_overlay:destroy();
        end;
    end;

    block_overlay = Scene:add_box({
        position = snap(Input:pointer_pos(), 0.25),
        size = vec2(0.25, 0.25),
        is_static = true,
        color = Color:rgba(255, 255, 255, 10),
        name = "block_overlay"
    });
    block_overlay:temp_set_collides(false)
end;

function on_step()
    clear_gizmos();

    if Input:key_pressed("D") then
        local hits1 = Scene:raycast({
            origin = self:get_position() + vec2(0.2, -0.23),
            direction = vec2(1, 0),
            distance = 0.01,
            closest_only = false,
        });
        local origin = self:get_position() + vec2(0.2, -0.24);
        local hits2 = Scene:raycast({
            origin = origin,
            direction = vec2(0, -1),
            distance = 0.155,
            closest_only = true,
        });
        if (#hits1 == 0) and (#hits2 > 0) then
            local distance = (hits2[1].point - origin):magnitude();
            self:set_position(self:get_position() + vec2(0, distance));
        end;
    end;

    if debug then
        --[[for _, offset in ipairs(ground_check_points) do
            gizmo_circle(self:get_position() - offset, 0xff0000);
        end;]]
        gizmo_raycast({
            origin = self:get_position() + vec2(-0.19, -0.3),
            direction = vec2(1, -1),
            distance = 0.15,
            closest_only = false,
        }, 0xff0000);
        gizmo_raycast({
            origin = self:get_position() + vec2(0.19, -0.3),
            direction = vec2(-1, -1),
            distance = 0.15,
            closest_only = false,
        }, 0xff0000);
        gizmo_raycast({
            origin = self:get_position() + vec2(0.2, -0.23),
            direction = vec2(1, 0),
            distance = 0.01,
            closest_only = false,
        }, 0xffff00);
        gizmo_raycast({
            origin = self:get_position() + vec2(0.2, -0.24),
            direction = vec2(0, -1),
            distance = 0.155,
            closest_only = false,
        }, 0xffff00);
    end;

    local hp_value = tonumber(string.match(self:get_name(), "player_(%d+)"))
    if hp_value then
        if hp_value <= 0 then
            if health_bar_fg ~= nil then
                health_bar_fg:destroy();
            end;
            if health_bar_bg ~= nil then
                health_bar_bg:destroy();
            end;
            self:destroy();
            return;
        end;
    end;

    --weapon:set_position(self:get_position() + weapon_offset);
    self:set_angle(0);

    if hp_value ~= prev_hp_value then
        update_health_bar(hp_value);
    elseif health_bar_bg ~= nil then
        health_bar_bg:set_position(self:get_position() + health_bar_offset);
        health_bar_fg:set_position(self:get_position() + health_bar_offset + (vec2(((hp_value / 100.0) * health_bar_width) - health_bar_width, 0)) / 2);
    end;

    prev_hp_value = hp_value;
end;

function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function snap(pos, grid_size)
    return vec2(
        math.floor((pos.x + 0.5 * grid_size) / grid_size) * grid_size,
        math.floor((pos.y + 0.5 * grid_size) / grid_size) * grid_size
    );
end;

function set_block(point, place)
    local snapped = snap(point, 0.25);

    local objs = Scene:get_objects_in_circle({
        position = snapped,
        radius = 0.1,
    });

    local had_tile = false;

    for i=1,#objs do
        if not objs[i]:is_destroyed() then
            if starts(objs[i]:get_name(), "tile_") then
                if not place then
                    local tile_name = string.match(objs[i]:get_name(), "^tile_(.+)$");
                    if inventory[tile_name] == nil then
                        inventory[tile_name] = 0;
                    end;
                    inventory[tile_name] += 1;

                    for _, obj in ipairs(objs[i]:get_connected_objects()) do
                        obj:destroy();
                    end;
                end;
                had_tile = true;
            end;
        end;
    end;

    if place and (not had_tile) then
        if (inventory[tile_type] == nil) or (inventory[tile_type] < 1) then
            return;
        end;

        if tile_type == "wood" then
            local tile = Scene:add_box({
                position = snapped,
                size = vec2(0.25, 0.25),
                is_static = true,
                color = 0xc1a17b,
                name = "tile_wood"
            });
            tile:set_restitution(0);
            tile:set_friction(0.5);
        end;
        if tile_type == "stairs" then
            local tile = Scene:add_box({
                position = snapped - vec2(0.125 / 2, 0.125 / 2),
                size = vec2(0.125, 0.125),
                is_static = true,
                color = 0xc1a17b,
                name = "tile_stairs"
            });
            tile:set_restitution(0);
            tile:set_friction(0.5);
            local tile2 = Scene:add_box({
                position = snapped + vec2(0.125 / 2, 0),
                size = vec2(0.125, 0.25),
                is_static = true,
                color = 0xc1a17b,
                name = "unreal"
            });
            tile2:set_restitution(0);
            tile2:set_friction(0.5);
            tile2:bolt_to(tile);
        end;
        if tile_type == "slab" then
            local tile = Scene:add_box({
                position = snapped - vec2(0, 0.125 / 2),
                size = vec2(0.25, 0.125),
                is_static = true,
                color = 0xc1a17b,
                name = "tile_slab"
            });
            tile:set_restitution(0);
            tile:set_friction(0.5);
        end;

        inventory[tile_type] -= 1;
    end;
end;

function check(point)
    local snapped = snap(point, 0.25);

    local objs = Scene:get_objects_in_circle({
        position = snapped,
        radius = 0.1,
    });

    local had_tile = false;

    for i=1,#objs do
        if starts(objs[i]:get_name(), "tile_") then
            had_tile = true;
        end;
    end;

    return had_tile;
end;

function ground_check()
    --[[for _, offset in ipairs(ground_check_points) do
        local objs = Scene:get_objects_in_circle({
            position = self:get_position() - offset,
            radius = 0,
        })

        if #objs > 0 then
            return true
        end
    end]]

    local hits1 = Scene:raycast({
        origin = self:get_position() + vec2(-0.19, -0.3),
        direction = vec2(1, -1),
        distance = 0.15,
        closest_only = false,
    });
    if #hits1 > 0 then return true; end;

    local hits2 = Scene:raycast({
        origin = self:get_position() + vec2(0.19, -0.3),
        direction = vec2(-1, -1),
        distance = 0.15,
        closest_only = false,
    });
    if #hits2 > 0 then return true; end;

    return false;
end
