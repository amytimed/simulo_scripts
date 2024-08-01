function on_collision_start(other)
    if other:get_name() == "Weapon 1" then
        other:temp_set_is_static(true);
    end;
end;