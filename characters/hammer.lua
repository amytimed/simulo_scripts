function on_collision_start(data)
    if not data.other:temp_get_is_static() then
        local c = data.other:get_connected_objects();
        for i=1,#c do
            c[i]:detach();
        end;
    end;
end;