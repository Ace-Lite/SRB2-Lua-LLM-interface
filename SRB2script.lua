local prompt_received = ""
local prompt_write = ""

local chat_origin = ""
local chat_history = ""

local function ai_llm_manage_history()
	local history_manager = {}
	
	for line in string.gmatch(s,'[^\r\n]+') do
		table.insert(history_manager, line)
	end
	
	if #history_manager >= 16 then
		chat_history = ""
		for i = (#history_manager-16), #history_manager do
			chat_history = $+history_manager[i]+"\n"
		end
	end
end

local function ai_llm_write(msg)
	if prompt_write ~= "" and prompt_received ~= "" then
		chat_history = $+"You:"+prompt_write+"\nShip-AI:"+prompt_received+"\n"
		ai_llm_manage_history()
	else
		local file = io.openlocal("bluespring/AI-IO/AI_Character1 - startingprompt.txt", "r")
		if file then
			chat_origin = file:read("*a")
			chat_history = $+chat_origin+"\n"
			chatprint("\x89*<RoboGPT>* \x80"..chat_origin)			
			file:close()
		end
	end

	prompt_write = msg
	msg = chat_history+"You:"+msg+"\nShip-AI:"

    local file = io.openlocal("bluespring/AI-IO/input_prompt.txt", "w")
	if file then
		file:seek("set", 0)
		file:write(msg)
		file:close()
	end
end

local function ai_llm_flush()
	chat_history = ""
	prompt_received = ""
    local file = io.openlocal("bluespring/AI-IO/receive_prompt.txt", "w")
	if file then
		file:seek("set", 0)
		file:write("")
		file:close()
	end
	if chat_origin ~= "" then
		chat_history = $+chat_origin+"\n"
		chatprint("\x89*<RoboGPT>* \x80"..chat_origin)
	end
end

COM_AddCommand("ai_write", function(player, ...)
	local n = {...}
	local str = ""
	for i = 1, #n do
		str = str.." "..n[i]
	end
	
	ai_llm_write(str)
end, COM_LOCAL)

COM_AddCommand("ai_flush", function(player)
	ai_llm_flush()	
end, COM_LOCAL)

addHook("MapLoad", function()
	ai_llm_flush()	
end)

local function split_words_literal(og_str)
	local words = {}
	for str in string.gmatch(og_str, "([^%s]+)") do
		table.insert(words, str)
	end
	return words
end

local function split_text(og_str)
	local words = split_words_literal(og_str)
	local new_lines = {}
	local num_line = 1
	local num_char_per_line = 0

	for i = 1,#words do
		local word = new_lines[num_line] and " "..words[i] or words[i]
		num_char_per_line = num_char_per_line+string.len(word)
		if num_char_per_line > 37 then
			word = words[i]
			num_char_per_line = string.len(word)
			num_line = num_line+1
		end
		new_lines[num_line] = new_lines[num_line] and new_lines[num_line]..word or word
	end
	
	return new_lines
end


addHook("PlayerMsg", function(source, typ, t, msg)
	local msg_words = split_words_literal(msg)

	if msg_words[1] == "!AI" then
		if not msg_words[2] then return end
		local new_msg = ""
		for i = 2, #msg_words do
			new_msg = new_msg..msg_words[i].." "
		end
		ai_llm_write(new_msg)
	end
end)