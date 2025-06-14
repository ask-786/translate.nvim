local M = {}

local config = {
	translate_to = nil,
	key = nil,
}

local endpoint = 'https://translation.googleapis.com/language/translate/v2'

local function get_visual_selection()
	local mode = vim.api.nvim_get_mode().mode
	local pos1 = vim.fn.getpos('\'<')
	local pos2 = vim.fn.getpos('\'>')

	local srow, scol = pos1[2], pos1[3]
	local erow, ecol = pos2[2], pos2[3]

	if srow > erow or (srow == erow and scol > ecol) then
		srow, erow = erow, srow
		scol, ecol = ecol, scol
	end

	if mode == 'V' then
		local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
		return table.concat(lines, '\n')
	else
		local lines =
			vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
		return table.concat(lines, '\n')
	end
end

local function translate_text(text, target_lang, callback)
	local json = vim.fn.json_encode({
		q = text,
		target = target_lang,
		format = 'text',
		key = config.key,
	})

	local cmd = string.format(
		'curl -s -X POST -H \'Content-Type: application/json\' -d \'%s\' \'%s\'',
		json,
		endpoint
	)

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			vim.schedule(function()
				local response = table.concat(data or {}, '')
				if not response or response == '' then
					callback('[Error] Empty response from API')
					return
				end

				local ok, decoded = pcall(vim.fn.json_decode, response)
				if not ok or not decoded or not decoded.data then
					local err = decoded and decoded.error and decoded.error.message
						or '[Error] Failed to decode response'
					callback(err)
					return
				end

				callback(decoded.data.translations[1].translatedText)
			end)
		end,
	})
end

function M.translate()
	if not config.key or config.key == '' then
		vim.notify(
			'No Google Translate API key set. Use require("...").setup({ key = "..." })',
			vim.log.levels.ERROR
		)
		return
	end

	local mode = vim.api.nvim_get_mode().mode

	if mode:match('v') then
		local text = get_visual_selection()
		if not text or text == '' then
			vim.notify('No text selected', vim.log.levels.WARN)
			return
		end

		vim.ui.input(
			{ prompt = 'Translate to (e.g., "en", "fr"): ' },
			function(lang)
				if not lang or lang == '' then
					return
				end
				translate_text(text, lang, function(result)
					vim.notify('Translation: ' .. result)
				end)
			end
		)
	else
		vim.ui.input({ prompt = 'Enter text to translate: ' }, function(text)
			if not text or text == '' then
				return
			end
			vim.ui.input(
				{ prompt = 'Translate to (e.g., "en", "fr"): ' },
				function(lang)
					if not lang or lang == '' then
						return
					end
					translate_text(text, lang, function(result)
						vim.notify('Translation: ' .. result)
					end)
				end
			)
		end)
	end
end

function M.setup(opts)
	config = vim.tbl_deep_extend('force', config, opts or {})
end

return M
