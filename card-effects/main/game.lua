local M = {}

M.MSG_SELECT_CARD = hash("select_card")
M.MSG_RELEASE_CARD = hash("release_card")
M.MSG_ASSIGNED_TO_SLOT = hash("assigned_to_slot")
M.MSG_HOVER = hash("hover")
M.MSG_HOVER_ENTER = hash("hover_enter")
M.MSG_HOVER_LEAVE = hash("hover_leave")

M.CARD_WIDTH = 100
M.CARD_HEIGHT = 144
M.SAFE_ZONE_DIST_Y = 200

M.card_slots = {}
M.cards = {}

local function hit_test(p, x, y)
	local l = p.x - M.CARD_WIDTH / 2
	local r = p.x + M.CARD_WIDTH / 2
	local t = p.y + M.CARD_HEIGHT / 2
	local b = p.y - M.CARD_HEIGHT / 2
	return x > l and x < r and y < t and y > b
end

M.make_card_slots = function(count)
	for i = 1, count do
		M.card_slots[i] = { empty = true, slot = i }
	end
end

M.make_card = function(base_go, card_go)
	local slot = nil

	-- insert in existing slot that is empty
	for k, v in pairs(M.card_slots) do
		if v.empty then
			slot = v
			break
		end
	end

	if slot == nil then
		print("Error: card slots full")
		return
	end
	
	local card = {}
	card.go = base_go
	card.go_card = card_go
	card.slot = slot.slot

	slot.position = go.get_world_position(base_go)
	slot.card = card
	slot.empty = false
	
	table.insert(M.cards, card)
	msg.post(base_go, M.MSG_ASSIGNED_TO_SLOT, { slot = card.slot, first_assignment = true })
end

M.select_card = function(card)
	M.selected_card = card
	msg.post(card.go, M.MSG_SELECT_CARD)
end

M.release_card = function()
	if M.selected_card ~= nil then
		local selected_pos = go.get_world_position(M.selected_card.go_card)
		local selected_slot = M.get_slot(M.selected_card.slot)
		local removed_from_stack = math.abs(selected_pos.y - selected_slot.position.y) > M.SAFE_ZONE_DIST_Y

		msg.post(M.selected_card.go, M.MSG_RELEASE_CARD, { removed_from_stack = removed_from_stack })

		if removed_from_stack then
			M.card_slots[M.selected_card.slot].empty = true
		end
		
		M.selected_card = nil
	end
end

M.get_card_from_xy = function(x, y)
	for k,v in pairs(M.cards) do
		local c_p = go.get_world_position(v.go_card)		
		if hit_test(c_p, x, y) then
			return v
		end
	end
end

M.has_selected_card = function()
	return M.selected_card ~= nil
end

M.swap = function(a, b)
	-- print("swap " .. a .. " <-> " .. b)
	local card_a = M.card_slots[a].card
	local card_b = M.card_slots[b].card
	M.card_slots[a].card = card_b
	M.card_slots[b].card = card_a
	card_a.slot = b
	card_b.slot = a

	msg.post(card_a.go, M.MSG_ASSIGNED_TO_SLOT, { slot = b })
	msg.post(card_b.go, M.MSG_ASSIGNED_TO_SLOT, { slot = a })
end

M.get_slot = function(slot)
	return M.card_slots[slot]
end

M.has_free_slot = function()
	for k, v in pairs(M.card_slots) do
		if v.empty then
			return v
		end
	end
end

M.on_hover_enter = function(card, x, y)
	msg.post(card.go, M.MSG_HOVER_ENTER, { x = x, y = y})
end

M.on_hover_leave = function(card, x, y)
	msg.post(card.go, M.MSG_HOVER_LEAVE, { x = x, y = y})
end

M.on_hover = function(card, x, y)
	msg.post(card.go, M.MSG_HOVER, { x = x, y = y})
end

M.resolve = function()
	local selected_slot_index = M.selected_card.slot
	local selected_pos = go.get_world_position(M.selected_card.go_card)
	
	for k,v in pairs(M.card_slots) do

		local selected_to_slot_dist_y = math.abs(selected_pos.y - v.position.y)
		
		if v.card ~= M.selected_card and selected_to_slot_dist_y < M.SAFE_ZONE_DIST_Y then
			if selected_slot_index > v.slot and selected_pos.x < v.position.x then
				M.swap(selected_slot_index, v.slot)
				break
			elseif selected_slot_index < v.slot and selected_pos.x > v.position.x then
				M.swap(selected_slot_index, v.slot)
				break
			end
		end
	end
end

M.update = function(x,y,pressed,released)
	local card = M.get_card_from_xy(x, y)

	if pressed then
		if card ~= nil then
			M.select_card(card)
		end
	elseif released then
		M.release_card()
	else
		if M.has_selected_card() then
			M.resolve()
		elseif card ~= nil then
			if not M.last_hover then
				M.on_hover_enter(card, x, y)
			elseif M.last_hover ~= card then
				M.on_hover_leave(M.last_hover, x, y)
				M.on_hover_enter(card, x, y)
			else
				M.on_hover(card, x, y)
			end
			M.last_hover = card
		elseif M.last_hover then
			M.on_hover_leave(M.last_hover, x, y)
			M.last_hover = nil
		end
	end
end

return M
