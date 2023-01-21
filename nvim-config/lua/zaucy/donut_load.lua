local M = {}

--[[
    Spinning Donut by Andrew Li
    Ported from donut.c - https://www.a1k0n.net/2011/07/20/donut-math.html
]]

local theta_spacing = 0.07
local phi_spacing = 0.02

local a = 0
local ba = 0
local donut_chars = { '.', ',', '-', '~', ':', ';', '=', '!', '*', '#', '$', '@' }
local z = {}
local b = {}

function M.donut_to_nvim_buf(buf)
	local i, j
	j = 0
	-- zeros arrays
	for l = 1, 1760 do
		z[l] = 0
	end
	for t = 1, 1760 do
		b[t] = ' '
	end
	-- calculate donut
	while j < 6.28 do
		j = j + theta_spacing
		i = 0
		while i < 6.28 do
			i = i + phi_spacing

			local c, d, e, f, g, h, D, l, m, n, t, x, y, o, N
			c = math.sin(i)
			l = math.cos(i)
			d = math.cos(j)
			f = math.sin(j)

			e = math.sin(a)
			g = math.cos(a)
			h = d + 2
			D = 1 / (c * h * e + f * g + 5)

			m = math.cos(ba)
			n = math.sin(ba)
			t = c * h * g - f * e

			x = math.floor(40 + 30 * D * (l * h * m - t * n))
			y = math.floor(12 + 15 * D * (l * h * n + t * m))
			o = math.floor(x + (80 * y))
			N = math.floor(8 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n))

			if 22 > y and y > 0 and 80 > x and x > 0 and D > z[o + 1] then
				z[o + 1] = D
				if N > 0 then
					b[o + 1] = donut_chars[N + 1]
				else
					b[o + 1] = '.'
				end
			end
		end
	end

	-- print
	local buf_lines = { '' }
	local buf_lines_idx = 1
	for l = 1, 1760 do
		if l % 80 ~= 0 then
			-- io.write(tostring(b[l]))
			buf_lines[buf_lines_idx] = buf_lines[buf_lines_idx] .. tostring(b[l])
		else
			-- print()
			table.insert(buf_lines, '')
			buf_lines_idx = buf_lines_idx + 1
		end
	end

	vim.api.nvim_buf_set_lines(buf, 0, buf_lines_idx, false, buf_lines)

	-- increments
	a = a + 0.04
	ba = ba + 0.02
end

return M
