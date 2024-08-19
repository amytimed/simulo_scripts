local sticky_hinges = {};

local sticky = true;

function on_collision_start(data)
    if sticky then
        for i=1,#data.points do
            table.insert(sticky_hinges, Scene:add_hinge_at_world_point({
                point = data.points[i],
                object_a = self,
                object_b = data.other,
                motor_enabled = false,
                motor_speed = 0, -- radians per second
                max_motor_torque = 1.25, -- maximum torque for the motor, in newton-meters
                collide_connected = true,
            }));
        end;
    end;
end;

function on_step()
    for i=#sticky_hinges, 1, -1 do
        print(sticky_hinges[i]:get_force():magnitude());
        if sticky_hinges[i]:get_force():magnitude() > 100 then
            sticky_hinges[i]:destroy();
            table.remove(sticky_hinges, i);
        end;
    end;
end;