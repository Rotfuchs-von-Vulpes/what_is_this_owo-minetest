local what_is_this_owo = {
	players = {},
	players_set = {}
}

local function split (str, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	for char in string.gmatch(str, "([^"..sep.."]+)") do
		table.insert(t, char)
	end

	return t
end

function what_is_this_owo.split_item_name(item_name)
	local splited = split(item_name, ':')

	return splited[1], splited[2]
end

local char_width = {
	A = 12,
	B = 10,
	C = 13,
	D = 12, 
	E = 11, 
	F = 9,
	G = 13,
	H = 12,
	I = 3,
	J = 9,
	K = 11,
	L = 9,
	M = 13,
	N = 11,
	O = 13,
	P = 10,
	Q = 13,
	R = 12,
	S = 10,
	T = 11,
	U = 11,
	V = 10,
	W = 15,
	X = 11,
	Y = 11,
	Z = 10,
	a = 10,
	b = 8,
	c = 8,
	d = 9, 
	e = 9, 
	f = 5,
	g = 9,
	h = 9,
	i = 2,
	j = 6,
	k = 8,
	l = 4,
	m = 13,
	n = 8,
	o = 10,
	p = 8,
	q = 10,
	r = 4,
	s = 8,
	t = 5,
	u = 8,
	v = 8,
	w = 12,
	x = 8,
	y = 8,
	z = 8,
}
char_width[' '] = 5
char_width['_'] = 9

function is_strange(str)
	for char in str:gmatch'.' do
		if char == '' then
			return true
		end
	end

	return false
end

function what_is_this_owo.destrange(str)
	local is_strange = is_strange(str);
	local ignore = true;

	local temp_str
	if is_strange then
		local temp_str = ''
		local reading = true
		local is_special = false
		local between_parenthesis = false
		
		for char in str:gmatch'.' do
			if char == '' then
				reading = false
			elseif char == "\n" then 
				return temp_str
			elseif reading and not between_parenthesis and char ~= "(" then
				temp_str = temp_str..char
			else
				reading = true
			end

			if between_parenthesis then
				if char == ')' then
					between_parenthesis = false
				end
			else
				if char == '(' then
					between_parenthesis = true
				end
			end
		end

		return temp_str
	else
		return str
	end
end

function string_to_pixels(str)
	local size = 0

	str:gsub('.', function(char)
		local pixels = char_width[char]

		if pixels then
			size = size + pixels
		else
			size = size + 14
		end
	end)

	return size
end

function inventorycube(img1, img2, img3)
	if not img1 then return '' end

	img2 = img2 or img1
	img3 = img3 or img1

	img1 = img1..'^[resize:16x16'
	img2 = img2..'^[resize:16x16'
	img3 = img3..'^[resize:16x16'

	return "[inventorycube"..
		"{"..img1:gsub("%^","&")..
		"{"..img2:gsub("%^","&")..
		"{"..img3:gsub("%^","&")
end

function what_is_this_owo.register_player(name)
	if not what_is_this_owo.players_set[name] then
		what_is_this_owo.players_set[name] = true
	end
end

function what_is_this_owo.remove_player(name)
	if what_is_this_owo.players_set[name] then
		what_is_this_owo.players_set[name] = nil
	end
end

function what_is_this_owo.get_node_tiles(node_name)
	local node = minetest.registered_nodes[node_name]

	if not node then
		return 'ignore', 'node', false
	end

	if node.groups['not_in_creative_inventory'] then
		drop = node.drop
		if drop and type(drop) == 'string' then
			node_name = drop
			node = minetest.registered_nodes[drop]
			if not node then 
				node = minetest.registered_craftitems[drop]
			end
		end
	end

	if not node or (not node.tiles and not node.inventory_image) then
		return 'ignore', 'node', false
	end

	local tiles = node.tiles

	local mod_name, item_name = what_is_this_owo.split_item_name(node_name)

	if node.inventory_image:sub(1, 14) == '[inventorycube' then

		return node.inventory_image..'^[resize:146x146', 'node', minetest.registered_nodes[node_name]
	elseif node.inventory_image ~= '' then

		return node.inventory_image..'^[resize:16x16', 'craft_item', minetest.registered_nodes[node_name]
	elseif item_name:sub(-2) == '_a' or item_name:sub(-2) == '_b' or item_name:sub(-2) == '_c' then
		local temp = mod_name..':'..item_name:sub(1, -3)
		local tile_temp = minetest.registered_craftitems[temp].inventory_image

		return tile_temp..'^[resize:16x16', 'craft_item', minetest.registered_nodes[node_name]
	else
		if not tiles[1] then
			return '', 'node', minetest.registered_nodes[node_name]
		end
		if not tiles[3] then
			tiles[3] = tiles[1]
		end
		if not tiles[6] then
			tiles[6] = tiles[3]
		end

		if type(tiles[1]) == 'table' then
			tiles[1] = tiles[1].name
		end
		if type(tiles[3]) == 'table' then
			tiles[3] = tiles[3].name
		end
		if type(tiles[6]) == 'table' then
			tiles[6] = tiles[6].name
		end

		return inventorycube(tiles[1], tiles[6], tiles[3]), 'node', minetest.registered_nodes[node_name]
	end
end

function what_is_this_owo.show_background(player, meta)
	player:hud_change(
		meta:get_string('wit:background_left'),
		'text',
		'left_side.png'
	)
	player:hud_change(
		meta:get_string('wit:background_middle'),
		'text',
		'middle.png'
	)
	player:hud_change(
		meta:get_string('wit:background_right'),
		'text',
		'right_side.png'
	)
end

function what_is_this_owo.show(player, meta, form_view, node_description, node_name, item_type, mod_name)
	if meta:get_string('wit:pointed_thing') == 'ignore' then
		what_is_this_owo.show_background(player, meta)
	end

	meta:set_string('wit:pointed_thing', node_name)

	local size
	if #node_description >= #mod_name then
		size = string_to_pixels(node_description)
	else
		size = string_to_pixels(mod_name)
	end

	player:hud_change(
		meta:get_string('wit:background_middle'),
		'scale',
		{x = size / 16 + 2, y = 2}
	)
	player:hud_change(
		meta:get_string('wit:background_right'),
		'offset',
		{x = size, y = 35}
	)

	player:hud_change(
		meta:get_string('wit:image'),
		'text',
		form_view
	)
	player:hud_change(
		meta:get_string('wit:name'),
		'text',
		node_description
	)
	player:hud_change(
		meta:get_string('wit:mod'),
		'text',
		mod_name
	)

	if meta:get_string('wit:item_type_in_pointer') ~= item_type then
		local scale = {}

		meta:set_string('wit:item_type_in_pointer', item_type)

		if item_type == 'node' then
			scale.x = 0.3
			scale.y = 0.3
		else
			scale.x = 2.5
			scale.y = 2.5
		end

		player:hud_change(
			meta:get_string('wit:image'),
			'scale',
			scale
		)
	end
end

function what_is_this_owo.unshow(player, meta)
	meta:set_string('wit:pointed_thing', 'ignore')

	player:hud_change(
		meta:get_string('wit:background_left'),
		'text',
		''
	)
	player:hud_change(
		meta:get_string('wit:background_middle'),
		'text',
		''
	)
	player:hud_change(
		meta:get_string('wit:background_right'),
		'text',
		''
	)

	player:hud_change(
		meta:get_string('wit:image'),
		'text',
		''
	)
	player:hud_change(
		meta:get_string('wit:name'),
		'text',
		''
	)
	player:hud_change(
		meta:get_string('wit:mod'),
		'text',
		''
	)
end

return what_is_this_owo
