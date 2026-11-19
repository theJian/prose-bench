-- Show continuations for Neovim mappings when the user pauses on a prefix.
--
-- Each buffer and enabled mode has a prefix tree built from global and
-- buffer-local mappings. Buffer-local definitions take precedence. The module
-- uses attach to add buffer-local triggers at eligible first keys with longer
-- mappings.
-- Neovim's own mapping timeout decides when a trigger runs.
--
-- A trigger calls show, which owns the single active interaction and its
-- floating panel. It reads continuation keys and opens the panel if no key is
-- queued. When the prefix resolves or leaves the tree, show removes the
-- trigger and queues the prefix and any typed continuation keys, with the
-- count and register, for Neovim to interpret. SafeState restores triggers
-- after replay. A complete mapping takes precedence over hints.
--
--   setup(opts)  Start or replace the configuration.
--   refresh()    Reindex the current buffer after mapping changes.
--   show(prefix) Start an interactive hint and replay the resulting key sequence.
--   disable()    Cancel input and remove the module's hooks, triggers, and UI.
--
-- For example, set the Space leader before defining mappings.
--
--   vim.g.mapleader = ' '
--   vim.keymap.set('n', '<leader>ws', '<Cmd>split<CR>', { desc = 'Split window' })
--   local which_key = require('which_key')
--   which_key.setup { groups = { ['<leader>w'] = 'Windows' } }
--
-- Press Space and pause, then press w to see s. Groups label prefixes of
-- existing mappings. Define the actual actions with vim.keymap.set.

local M = {}
local api, fn = vim.api, vim.fn
local defaults = {
	modes = { 'n', 'x' },
	groups = {},
	max_height = 12,
	min_column_width = 30,
	page_down = '<C-d>',
	page_up = '<C-u>',
}
local state = { caches = {}, generation = 0 }
local ns = api.nvim_create_namespace 'native-which-key'
local replay

local function raw(lhs)
	return vim.keycode(lhs)
end

local function tokens(keys)
	local result, i = {}, 1
	while i <= #keys do
		local start = i
		if keys:byte(i) == 128 and keys:byte(i + 1) == 252 then
			i = i + 3
		end
		local byte = keys:byte(i)
		if not byte then
			break
		end
		i = i + (byte == 128 and 3 or byte < 192 and 1 or byte < 224 and 2 or byte < 240 and 3 or 4)
		result[#result + 1] = keys:sub(start, i - 1)
	end
	return result
end

local function mode()
	local current = api.nvim_get_mode().mode
	if current == 'n' or current == 'nt' or current == 'ntT' then
		return 'n'
	elseif current == 'v' or current == 'V' or current == '\22' then
		return 'x'
	end
end

local function hide()
	if state.win and api.nvim_win_is_valid(state.win) then
		api.nvim_win_close(state.win, true)
	end
	state.win = nil
end

local function cancel()
	local active = state.active
	if active and not active.cancelled then
		active.cancelled = true
		if active.reading then
			api.nvim_feedkeys(raw '<Esc>', 'ni', false)
		end
	end
	hide()
end

local function detach(buf, mapping_mode, only_key)
	local cache = state.caches[buf]
	if not cache or not api.nvim_buf_is_valid(buf) then
		return
	end
	for _, m in ipairs(mapping_mode and { mapping_mode } or state.opts.modes) do
		local index = cache[m]
		if index then
			for _, map in ipairs(api.nvim_buf_get_keymap(buf, m)) do
				local key = raw(map.lhs)
				-- A caller may have replaced a trigger since the last refresh.
				if (not only_key or key == only_key) and index.owned[key] and map.callback == index.owned[key] then
					vim.keymap.del(m, map.lhs, { buffer = buf })
					index.owned[key] = nil
				end
			end
		end
	end
end

local function build(buf, mapping_mode)
	local maps = {}
	for _, list in ipairs { api.nvim_get_keymap(mapping_mode), api.nvim_buf_get_keymap(buf, mapping_mode) } do
		for _, map in ipairs(list) do
			local key = raw(map.lhs)
			if not key:find(raw '<Plug>', 1, true) and not key:find(raw '<SNR>', 1, true) then
				maps[key] = map
			end
		end
	end
	local root = { children = {}, count = 0 }
	for key, map in pairs(maps) do
		local node = root
		for _, token in ipairs(tokens(key)) do
			node.count = node.count + 1
			node.children[token] = node.children[token] or { children = {}, count = 0 }
			node = node.children[token]
		end
		node.count = node.count + 1
		node.map = map
	end
	return { root = root, owned = {} }
end

local function node_at(root, prefix)
	local node = root
	for _, token in ipairs(tokens(prefix)) do
		node = node.children[token]
		if not node then
			return
		end
	end
	return node
end

local function label(map)
	return map.desc or (map.rhs and map.rhs ~= '' and map.rhs) or 'Lua callback'
end

local function entries(node, prefix)
	local result = {}
	for key, child in pairs(node.children) do
		local group = state.groups[prefix .. key]
		result[#result + 1] = {
			key = fn.keytrans(key),
			text = child.map and label(child.map) or ('+ ' .. (group or (child.count .. ' mappings'))),
		}
	end
	table.sort(result, function(a, b)
		return a.key < b.key
	end)
	return result
end

local function fit(text, width)
	text = text:gsub('[\r\n\t]', ' ')
	if fn.strdisplaywidth(text) <= width then
		return text
	end
	local lo, hi = 0, fn.strchars(text)
	while lo < hi do
		local mid = math.ceil((lo + hi) / 2)
		if fn.strdisplaywidth(fn.strcharpart(text, 0, mid)) <= width - 1 then
			lo = mid
		else
			hi = mid - 1
		end
	end
	return fn.strcharpart(text, 0, lo) .. '…'
end

local function render(active, node)
	local items = entries(node, active.prefix)
	if #items == 0 or vim.o.lines < 5 or vim.o.columns < 10 then
		hide()
		return
	end
	local width = math.max(1, vim.o.columns - 2)
	local cols = math.max(1, math.floor(width / state.opts.min_column_width))
	cols = math.min(cols, #items)
	local cell = math.floor(width / cols)
	local rows = math.min(math.ceil(#items / cols), state.opts.max_height - 1, vim.o.lines - 4)
	local size = rows * cols
	local pages = math.ceil(#items / size)
	active.page = math.min(active.page or 1, pages)
	active.pages = pages
	-- A real continuation keeps its key even when the list needs pagination.
	active.down = not node.children[raw(state.opts.page_down)] and raw(state.opts.page_down) or nil
	active.up = not node.children[raw(state.opts.page_up)] and raw(state.opts.page_up) or nil
	local title = fn.keytrans(active.prefix)
	if state.groups[active.prefix] then
		title = title .. ' — ' .. state.groups[active.prefix]
	end
	if pages > 1 then
		title = title .. ('  [%d/%d]'):format(active.page, pages)
		if active.down then
			title = title .. '  ' .. state.opts.page_down .. ' next'
		end
		if active.up then
			title = title .. '  ' .. state.opts.page_up .. ' previous'
		end
	end
	local lines, highlights = { fit(title, width) }, {}
	for row = 1, rows do
		local line = ''
		for col = 1, cols do
			local item = items[(active.page - 1) * size + (col - 1) * rows + row]
			if item then
				local text = fit(item.key .. '  ' .. item.text, cell - 2)
				highlights[#highlights + 1] = { row, #line, #line + math.min(#item.key, #text) }
				line = line .. text .. string.rep(' ', cell - fn.strdisplaywidth(text))
			end
		end
		lines[#lines + 1] = line
	end
	if not state.buf or not api.nvim_buf_is_valid(state.buf) then
		state.buf = api.nvim_create_buf(false, true)
		vim.bo[state.buf].bufhidden = 'hide'
		vim.bo[state.buf].filetype = 'which-key'
	end
	api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
	api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
	api.nvim_buf_set_extmark(state.buf, ns, 0, 0, { end_row = 1, hl_group = 'Title' })
	for _, hl in ipairs(highlights) do
		api.nvim_buf_set_extmark(state.buf, ns, hl[1], hl[2], { end_col = hl[3], hl_group = 'Special' })
	end
	local config = {
		relative = 'editor',
		row = math.max(0, vim.o.lines - #lines - math.max(1, vim.o.cmdheight) - 1),
		col = 1,
		width = width,
		height = #lines,
		style = 'minimal',
		focusable = false,
		border = 'none',
		zindex = 60,
		noautocmd = true,
	}
	if state.win and api.nvim_win_is_valid(state.win) then
		api.nvim_win_set_config(state.win, config)
	else
		state.win = api.nvim_open_win(state.buf, false, config)
		vim.wo[state.win].winhighlight = 'Normal:NormalFloat'
		vim.wo[state.win].wrap = false
	end
	vim.cmd.redraw()
end

local function attach(buf, mapping_mode, index)
	for key, child in pairs(index.root.children) do
		-- Leave native count, register, cancel, and command entry keys alone.
		local unsafe = key:match '^[0-9"\27]$' or key == raw '<C-c>' or (mapping_mode == 'n' and key:match '^[dcyrq@]$')
		if not child.map and next(child.children) and not unsafe then
			local callback = function()
				if api.nvim_get_mode().mode:match '^ni' then
					replay {
						buf = buf,
						mode = mapping_mode,
						prefix = key,
						count = vim.v.count,
						register = vim.v.register,
						temporary = true,
					}
					return
				end
				M.show(fn.keytrans(key))
			end
			vim.keymap.set(mapping_mode, fn.keytrans(key), callback, {
				buffer = buf,
				silent = true,
				desc = 'Which-key prefix',
			})
			index.owned[key] = callback
		end
	end
end

-- Rebuild the current buffer only. Events such as BufEnter, FileType and
-- LspAttach request a refresh. Call refresh after changing mappings directly
-- to update the current buffer's triggers. A hint or replay defers rebuilding
-- until the interaction finishes so its tree and triggers stay valid.
function M.refresh()
	if not state.enabled then
		return
	end
	if state.replaying or state.active then
		state.pending = true
		return
	end
	local buf = api.nvim_get_current_buf()
	if buf == state.buf then
		return
	end
	detach(buf)
	local cache = {}
	state.caches[buf] = cache
	for _, m in ipairs(state.opts.modes) do
		cache[m] = build(buf, m)
		attach(buf, m, cache[m])
	end
	state.pending = false
end

local function request_refresh()
	if state.queued then
		return
	end
	state.queued = true
	local generation = state.generation
	vim.schedule(function()
		if state.generation == generation then
			state.queued = false
			M.refresh()
		end
	end)
end

replay = function(active)
	detach(active.buf, active.mode, tokens(active.prefix)[1])
	state.replaying = true
	local context = (active.register ~= '"' and '"' .. active.register or '')
	if active.register == '=' then
		context = context .. raw '<CR>'
	end
	context = context .. (active.count > 0 and tostring(active.count) or '')
	api.nvim_feedkeys((active.temporary and raw '<C-o>' or '') .. context .. active.prefix, 'mi', false)
end

-- After setup, pass a prefix in Neovim key notation such as '<leader>w'.
-- Returns immediately when disabled, outside a configured mode, or while
-- another hint is active. An enabled call can wait for keyboard input.
-- Escape, Ctrl-C, leaving the buffer, window or tab, and switching out of the
-- active mode cancel the hint.
-- On resolution or a missing match, replay starts after the window closes.
function M.show(prefix)
	local mapping_mode = mode()
	if not state.enabled or state.active or not vim.tbl_contains(state.opts.modes, mapping_mode) then
		return
	end
	local active = {
		buf = api.nvim_get_current_buf(),
		win = api.nvim_get_current_win(),
		mode = mapping_mode,
		prefix = raw(prefix),
		count = vim.v.count,
		register = vim.v.register,
		page = 1,
	}
	state.replaying = false
	M.refresh()
	state.active = active
	local ok, err = xpcall(function()
		local root = state.caches[active.buf][mapping_mode].root
		while not active.cancelled do
			local node = node_at(root, active.prefix)
			if not node or node.map or not next(node.children) or fn.reg_executing() ~= '' then
				break
			end
			local key = fn.getcharstr(0)
			if key == '' then
				render(active, node)
				active.reading = true
				key = fn.getcharstr()
				active.reading = false
			end
			if active.cancelled or key == raw '<Esc>' or key == raw '<C-c>' then
				active.cancel_key = not active.cancelled and key or nil
				active.cancelled = true
				break
			end
			if active.pages and active.pages > 1 and (key == active.down or key == active.up) then
				active.page = (active.page - 1 + (key == active.down and 1 or -1)) % active.pages + 1
			else
				active.prefix = active.prefix .. key
				active.page, active.pages = 1, nil
			end
		end
	end, debug.traceback)
	hide()
	state.active = nil
	if not ok then
		active.cancelled = true
		if tostring(err):find('Keyboard interrupt', 1, true) or tostring(err):find('Vim:Interrupt', 1, true) then
			active.cancel_key = raw '<Esc>'
		else
			vim.notify('Which-key: ' .. tostring(err), vim.log.levels.ERROR)
		end
	end
	if not active.cancelled and state.enabled and api.nvim_get_current_buf() == active.buf then
		replay(active)
	else
		if active.cancel_key and api.nvim_get_current_buf() == active.buf then
			api.nvim_feedkeys(active.cancel_key, 'ni', false)
		end
		if state.pending then
			request_refresh()
		end
	end
end

-- Tear down every cached buffer's owned triggers and wake any pending read.
-- Mappings that a caller installed in place of a trigger are preserved.
function M.disable()
	cancel()
	for buf in pairs(state.caches) do
		detach(buf)
	end
	if state.augroup then
		api.nvim_del_augroup_by_id(state.augroup)
	end
	if state.buf and api.nvim_buf_is_valid(state.buf) then
		api.nvim_buf_delete(state.buf, { force = true })
	end
	state = { caches = {}, generation = state.generation + 1 }
end

-- Options override the defaults above. modes accepts 'n' and 'x'. groups maps
-- prefix strings in Neovim key notation to display labels. max_height is at
-- least 2 rows including the title. min_column_width is at least 8 screen
-- cells. page_down and page_up name keys that are available for pagination
-- when no continuation claims them. Setup tears down the previous installation
-- before validating options, so a validation error leaves it disabled.
function M.setup(opts)
	M.disable()
	state.opts = vim.tbl_deep_extend('force', defaults, opts or {})
	assert(state.opts.max_height >= 2 and state.opts.min_column_width >= 8, 'Invalid which-key panel dimensions')
	for _, m in ipairs(state.opts.modes) do
		assert(m == 'n' or m == 'x', 'Which-key supports n and x modes')
	end
	state.groups = {}
	for key, name in pairs(state.opts.groups) do
		state.groups[raw(key)] = name
	end
	state.enabled = true
	state.augroup = api.nvim_create_augroup('NativeWhichKey', { clear = true })
	api.nvim_create_autocmd(
		{ 'VimEnter', 'BufEnter', 'FileType', 'LspAttach', 'LspDetach', 'SourcePost', 'PackChanged' },
		{
			group = state.augroup,
			callback = request_refresh,
		}
	)
	api.nvim_create_autocmd('SafeState', {
		group = state.augroup,
		callback = function()
			if state.replaying then
				state.replaying = false
				M.refresh()
			end
		end,
	})
	api.nvim_create_autocmd({ 'BufLeave', 'WinLeave', 'TabLeave' }, { group = state.augroup, callback = cancel })
	api.nvim_create_autocmd('ModeChanged', {
		group = state.augroup,
		callback = function()
			if state.active and mode() ~= state.active.mode then
				cancel()
			end
		end,
	})
	api.nvim_create_autocmd('VimResized', {
		group = state.augroup,
		callback = function()
			local active = state.active
			if active and not active.cancelled then
				local node = node_at(state.caches[active.buf][active.mode].root, active.prefix)
				if node then
					render(active, node)
				end
			end
		end,
	})
	api.nvim_create_autocmd('BufWipeout', {
		group = state.augroup,
		callback = function(ev)
			state.caches[ev.buf] = nil
		end,
	})
	M.refresh()
end

return M
