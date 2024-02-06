-- stylua: ignore
local SPECIAL_KEYS = {
	" ","<Esc>"
}

-- stylua: ignore
local SINGLE_KEYS = {
	"p", "b", "e", "t", "a", "o", "i", "n", "s", "r", "h", "l", "d", "c",
	"u", "m", "f", "g", "w", "v", "k", "j", "x", "z", "y", "q"
}
-- stylua: ignore
local DOUBLE_KEYS = {
	"au", "ai", "ao", "ah", "aj", "ak", "al", "an", "su", "si", "so", "sh",
	"sj", "sk", "sl", "sn", "du", "di", "do", "dh", "dj", "dk", "dl", "dn",
	"fu", "fi", "fo", "fh", "fj", "fk", "fl", "fn", "gu", "gi", "go", "gh",
	"gj", "gk", "gl", "gn", "eu", "ei", "eo", "eh", "ej", "ek", "el", "en",
	"ru", "ri", "ro", "rh", "rj", "rk", "rl", "rn", "cu", "ci", "co", "ch",
	"cj", "ck", "cl", "cn", "wu", "wi", "wo", "wh", "wj", "wk", "wl", "wn"
}

-- stylua: ignore
local SPECIAL_CANDS = {
	{ on = " " },{ on = "<Esc>" }
}

-- stylua: ignore
local SIGNAL_CANDS = {
	{ on = "p" }, { on = "b" }, { on = "e" }, { on = "t" }, { on = "a" },
	{ on = "o" }, { on = "i" }, { on = "n" }, { on = "s" }, { on = "r" },
	{ on = "h" }, { on = "l" }, { on = "d" }, { on = "c" }, { on = "u" },
	{ on = "m" }, { on = "f" }, { on = "g" }, { on = "w" }, { on = "v" },
	{ on = "k" }, { on = "j" }, { on = "x" }, { on = "z" }, { on = "y" },
	{ on = "q" },
}
-- stylua: ignore
local DOUBLE_CANDS = {
	{ on = { "a", "u" } }, { on = { "a", "i" } }, { on = { "a", "o" } },
	{ on = { "a", "h" } }, { on = { "a", "j" } }, { on = { "a", "k" } },
	{ on = { "a", "l" } }, { on = { "a", "n" } }, { on = { "s", "u" } },
	{ on = { "s", "i" } }, { on = { "s", "o" } }, { on = { "s", "h" } },
	{ on = { "s", "j" } }, { on = { "s", "k" } }, { on = { "s", "l" } },
	{ on = { "s", "n" } }, { on = { "d", "u" } }, { on = { "d", "i" } },
	{ on = { "d", "o" } }, { on = { "d", "h" } }, { on = { "d", "j" } },
	{ on = { "d", "k" } }, { on = { "d", "l" } }, { on = { "d", "n" } },
	{ on = { "f", "u" } }, { on = { "f", "i" } }, { on = { "f", "o" } },
	{ on = { "f", "h" } }, { on = { "f", "j" } }, { on = { "f", "k" } },
	{ on = { "f", "l" } }, { on = { "f", "n" } }, { on = { "g", "u" } },
	{ on = { "g", "i" } }, { on = { "g", "o" } }, { on = { "g", "h" } },
	{ on = { "g", "j" } }, { on = { "g", "k" } }, { on = { "g", "l" } },
	{ on = { "g", "n" } }, { on = { "e", "u" } }, { on = { "e", "i" } },
	{ on = { "e", "o" } }, { on = { "e", "h" } }, { on = { "e", "j" } },
	{ on = { "e", "k" } }, { on = { "e", "l" } }, { on = { "e", "n" } },
	{ on = { "r", "u" } }, { on = { "r", "i" } }, { on = { "r", "o" } },
	{ on = { "r", "h" } }, { on = { "r", "j" } }, { on = { "r", "k" } },
	{ on = { "r", "l" } }, { on = { "r", "n" } }, { on = { "c", "u" } },
	{ on = { "c", "i" } }, { on = { "c", "o" } }, { on = { "c", "h" } },
	{ on = { "c", "j" } }, { on = { "c", "k" } }, { on = { "c", "l" } },
	{ on = { "c", "n" } }, { on = { "w", "u" } }, { on = { "w", "i" } },
	{ on = { "w", "o" } }, { on = { "w", "h" } }, { on = { "w", "j" } },
	{ on = { "w", "k" } }, { on = { "w", "l" } }, { on = { "w", "n" } },
}

-- FIXME: refactor this to avoid the loop
local function rel_position(file)
	for i, f in ipairs(Folder:by_kind(Folder.CURRENT).window) do
		if f == file then
			return i
		end
	end
end

-- FIXME: find a better way to do this
local function count_files(url, max)
	local cmd
	if ya.target_family() == "windows" then
		cmd = cx.active.conf.show_hidden and "dir /a " or "dir "
		cmd = cmd .. ya.quote(tostring(url))
	else
		cmd = cx.active.conf.show_hidden and "ls -A  " or "ls "
		cmd = cmd .. ya.quote(tostring(url)) .. " | wc -l"
	end

	if ya.target_family() == "windows" then  
		local i, handle = 0, io.popen(cmd)
		for _ in handle:lines() do
			i = i + 1
			if i == max then
				break
			end
		end
		handle:close()
		return i
	else
		local f = io.popen(cmd)
		local num = tonumber(f:read("*all"))
		f:close()

		if num == nil then
			ya.err("caculate file num error, target folder: " .. ya.quote(tostring(url)))
		end		

		if num > max then
			return max
		else
			return num
		end
	end
end

local function toggle_ui(st)
	ya.render()
	if st.icon or st.mode then
		Folder.icon, Status.mode, st.icon, st.mode = st.icon, st.mode, nil, nil
		return
	end

	st.icon, st.mode = Folder.icon, Status.mode
	Folder.icon = function(self, file)
		local pos = rel_position(file)
		if not pos then
			return st.icon(self, file)
		elseif st.num > #SINGLE_KEYS then
			return ui.Span(DOUBLE_KEYS[pos] .. " " .. file:icon().text .. " ")
		else
			return ui.Span(SINGLE_KEYS[pos] .. " " .. file:icon().text .. " ")
		end
	end
	Status.mode = function(self)
		local style = self.style()
		return ui.Line {
			ui.Span(THEME.status.separator_open):fg(style.bg),
			ui.Span(" KJ-" .. tostring(cx.active.mode):upper() .. " "):style(style),
		}
	end
end

local function next(sync, args) ya.manager_emit("plugin", { "keyjump", sync = sync, args = table.concat(args, " ") }) end

return {
	entry = function(_, args)
		local action = args[1]

		-- Step 1: Patch the UI with our candidates
		if not action or action == "keep" or action == "select" then
			if #SINGLE_KEYS >= Current.area.h then
				state.num = Current.area.h -- Fast path
			else
				state.num = #Folder:by_kind(Folder.CURRENT).window
				if state.num <= Current.area.h then -- Maybe the folder has not been full loaded yet
					state.num = count_files(cx.active.current.cwd, Current.area.h)
				end
			end

			state.type = action
			toggle_ui(state())
			return next(false, { "_read", state.num })
		end

		-- Step 2: Waiting to read the candidate from the user
		if action == "_read" then
			local cands, num = nil, tonumber(args[2])
			if num > #SINGLE_KEYS then
				cands = { table.unpack(DOUBLE_CANDS, 1, num) }
			else
				cands = { table.unpack(SIGNAL_CANDS, 1, num) }
			end

			for i = 1, #SPECIAL_KEYS do --attach special key 
				table.insert(cands, SPECIAL_CANDS[i])
			end

			local cand = ya.which { cands = cands, silent = true }

			if cand == nil then --never auto exit when pressing a nonexistent prompt key
				return next(false, { "_read", num})
			else
				return next(true, { "_apply", cand, num} )
			end
			
		end

		-- Step 3: Restore the UI we patched in step 1, once we read the candidate
		toggle_ui(state())
		if action ~= "_apply" then
			return
		end

		local cand = tonumber(args[2])
		local entry_num = tonumber(args[3]) 
		local folder = Folder:by_kind(Folder.CURRENT)

		-- hit esc key
		if cand > entry_num and SPECIAL_KEYS[cand - entry_num] == "<Esc>" then 
			return
		end

		-- Step 4: select mode, allow use special key in keyjump
		if state.type == "select" then
			if cand <= entry_num then -- hit normal key
				local folder = Folder:by_kind(Folder.CURRENT)
				ya.manager_emit("arrow", { cand - 1 + folder.offset - folder.cursor })

				next(true, { "select" })
				return
			end

			-- hit space key
			if SPECIAL_KEYS[cand - entry_num] == " " then
				local under_cursor_file = Folder:by_kind(Folder.CURRENT).window[folder.cursor - folder.offset + 1 ]
				local toggle_state = under_cursor_file:is_selected() and "false" or "true"
				ya.manager_emit("select", { state=toggle_state })
				ya.manager_emit("arrow", { 1 })
			end

			--never auto exit select mode
			next(true, { "select" })
			return
		end
	
		-- arrow in keep mode and normal mode
		ya.manager_emit("arrow", { cand - 1 + folder.offset - folder.cursor })

		-- Step 5: keep mode, will auto enter when select folder and will auto exit when select file
		if state.type == "keep" and folder.window[cand].cha.is_dir then 
			local folder = Folder:by_kind(Folder.CURRENT)
			ya.manager_emit("enter", {})
			next(true, { "keep" })
		end
	end,
}
