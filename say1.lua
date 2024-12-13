local phrases = {
    "1"
}

local counter = 0
register_callback("player_death", function(event)
    if event:get_pawn("attacker") == entitylist.get_local_player_pawn() then
        engine.execute_client_cmd("say " .. phrases[counter % #phrases + 1])
        counter = counter + 1
    end
end)