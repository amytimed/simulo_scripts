function on_collision_start(data)
    if not data.other:temp_get_is_static() then
        data.other:bolt_to(self);
    end;
end;