local what_is_this_owo = dofile(minetest.get_modpath('what_is_this_owo')..'/help.lua')

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()

	local background_id_left = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.5, y = 0},
		scale = {x = 2, y = 2},
		text = '',
		offset = {x = -50, y = 35},
	})
	local background_id_middle = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.5, y = 0},
		scale = {x = 2, y = 2},
		text = '',
		alignment = {x = 1},
		offset = {x = -37.5, y = 35},
	})
	local background_id_right = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.5, y = 0},
		scale = {x = 2, y = 2},
		text = '',
		offset = {x = 0, y = 35},
	})

	local image_id = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.5, y = 0},
		scale = {x = 0.3, y = 0.3},
		offset = {x = -35, y = 35},
	})
	local name_id = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 0},
		scale = {x = 0.3, y = 0.3},
		number = 0xffffff,
		alignment = {x = 1},
		offset = {x = 0, y = 29},
	})
	local mod_id = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 0},
		scale = {x = 0.3, y = 0.3},
		number = 0xff3c0a,
		alignment = {x = 1},
		offset = {x = 0, y = 46},
	})

	meta:set_string('wit:background_left', background_id_left)
	meta:set_string('wit:background_middle', background_id_middle)
	meta:set_string('wit:background_right', background_id_right)
	meta:set_string('wit:image', image_id)
	meta:set_string('wit:name', name_id)
	meta:set_string('wit:mod', mod_id)
	meta:set_string('wit:pointed_thing', 'ignore')
	meta:set_string('wit:item_type_in_pointer', 'node')
	meta:set_string('wit:show_popup', 'true')

	what_is_this_owo.register_player(player, player:get_player_name())
end)

minetest.register_globalstep(function()
	for _, player in ipairs(what_is_this_owo.players) do
		local meta = player:get_meta()

		local pointed_thing = what_is_this_owo.get_pointed_thing(player, meta)

		if pointed_thing then
			local node_name = minetest.get_node(pointed_thing.under).name
			local form_view, item_type, node_definition = what_is_this_owo.get_node_tile(node_name, meta)

			if not node_definition then
				what_is_this_owo.unshow(player, meta)

				return
			end

			local node_description = what_is_this_owo.destrange(node_definition.description)
			local mod_name, _ = what_is_this_owo.split_item_name(node_name)

			if meta:get_string('wit:pointed_thing') ~= node_name then
				what_is_this_owo.show(player, meta, form_view, node_description, node_name, item_type, mod_name)
			end
		else
			what_is_this_owo.unshow(player, meta)
		end
	end
end)

minetest.register_chatcommand('witowo', {
	params = '',
	description = 'Show and unshow the witowo pop-up',
	func = function(name)
		local player = minetest.get_player_by_name(name)

		if what_is_this_owo.players_set[name] then
			what_is_this_owo.remove_player(player, name)
			what_is_this_owo.unshow(player, player:get_meta())
		else
			what_is_this_owo.register_player(player, name)
		end

		return true, 'Option flipped'
	end
})
