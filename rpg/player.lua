local speed = 1;

local display_color = Color:hex(0x79c5ff);

local display = nil;

function on_update()
    self:set_angle(0);
    if display ~= nil then
        display:set_position(self:get_position() + vec2(0, 0.35));
    end;

    local velocity = vec2(0, 0);

    if Input:key_pressed("W") then
        velocity.y += speed;
    end;
    if Input:key_pressed("D") then
        velocity.x += speed;
    end;
    if Input:key_pressed("S") then
        velocity.y -= speed;
    end;
    if Input:key_pressed("A") then
        velocity.x -= speed;
    end;

    self:set_linear_velocity(velocity);
end;

function on_step()
    self:set_angle(0);
    if display ~= nil then
        display:set_position(self:get_position() + vec2(0, 0.35));
    else
        display = Scene:add_box({
            name = "Player Display",
            position = vec2(0, 0),
            size = vec2(0.5, 0.8),
            is_static = true,
            color = display_color,
        });
        display:temp_set_collides(false);
        display:set_position(self:get_position() + vec2(0, 0.35));
    end;
end;