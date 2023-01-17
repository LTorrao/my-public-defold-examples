-- Small notes about this:
--------------------------
-- * The cache takes buffers as input, these are loaded via resource.load
-- * Texture binaries are stored in the /textures folder, which is specified under "custom resources" in the game.project
-- * The buffers objects are stored in the cache and written to disk as a single buffer file
-- * The cache layout is stored as a json file next to the binary data,
--   and the json file contains the mapping of cells to offset into the data blob where the texture data for that cell lives
--------------------------

local M = {}

M.load = function(path)
	local json_file, json_error = io.open(path, "rb")
	if json_error then
		print("Error reading file", json_error)
		return nil
	end

	local header = json.decode(json_file:read("*a"))
	json_file:close()

	local C = M.create(header.tex_format, header.cell_size, header.cells_x, header.cells_y)

	print("Cache: Loaded cache from " .. path)

	local tex_file, tex_error = io.open(header.tex_path)
	if tex_error then
		print("Cache: Error! Cache has no texture data!")
		return C
	end

	local tex_data = tex_file:read("*a")
	tex_file:close()

	for k,v in pairs(header.cells) do
		local cell_buffer = buffer.create(v.count, {{ name=hash("data"), type=buffer.VALUE_TYPE_UINT8, count=1 }})
		local cell_stream = buffer.get_stream(cell_buffer, "data")

		for i=1, v.count do
			local tex_ix   = v.offset + i
			cell_stream[i] = string.byte(tex_data, tex_ix)
		end

		C:put(v.x, v.y, cell_buffer)
	end

	return C
end

M.create = function(fmt, cell_size, cells_x, cells_y)

	print("Cache: Creating cache")

	local C = {
		tex_format   = fmt,
		cell_size    = cell_size,
		cells_x      = cells_x,
		cells_y      = cells_y,
		cells        = {},
		tex_res_path = "/texture_cache.texturec"
	}

	local create_args = {
		width            = cell_size * cells_x,
		height           = cell_size * cells_y,
		type             = resource.TEXTURE_TYPE_2D,
		format           = resource.TEXTURE_FORMAT_RGBA,
	}

	local blank_basis = resource.load("/textures/blank.bin")

	C.tex_res = resource.create_texture(C.tex_res_path, create_args)

	create_args.compression_type = resource.COMPRESSION_TYPE_BASIS_UASTC
	create_args.format           = fmt
	resource.set_texture(C.tex_res, create_args, blank_basis)

	C.put = function(self, cell_x, cell_y, cell_buffer)
		if not self.cells[cell_y] then
			self.cells[cell_y] = {}
		end

		if not self.cells[cell_y][cell_x] then
			self.cells[cell_y][cell_x] = {}
		end

		print("Cache: Placing at cell (" .. cell_x .. ", " .. cell_y .. ")")
		self.cells[cell_y][cell_x].buffer = cell_buffer

		local set_tex_args = {
			width            = self.cell_size,
			height           = self.cell_size,
			type             = resource.TEXTURE_TYPE_2D,
			format           = self.tex_format,
			x                = self.cell_size * cell_x,
			y                = self.cell_size * cell_y,
			compression_type = resource.COMPRESSION_TYPE_BASIS_UASTC
		}

		resource.set_texture(self.tex_res_path, set_tex_args, cell_buffer)
	end

	C.save = function(self, path)

		print("Cache: Saving to " .. path)

		local json_data = {
			cells      = {},
			cells_x    = self.cells_x,
			cells_y    = self.cells_y,
			cell_size  = self.cell_size,
			tex_path   = path .. ".bin",
			tex_format = self.tex_format,
		}

		local cells = {}
		local buffer_size = 0

		for y=0,self.cells_y-1 do
			for x=0,self.cells_x-1 do
				if self.cells[y] and self.cells[y][x] and self.cells[y][x].buffer then
					local stream = buffer.get_stream(self.cells[y][x].buffer, "data")
					local stream_len = #stream
					table.insert(cells, {
						buffer = self.cells[y][x].buffer,
						offset = buffer_size,
						count  = stream_len,
						x      = x,
						y      = y
					})
					buffer_size = buffer_size + stream_len
				end
			end
		end

		local json_file, json_error = io.open(path, "wb")
		if json_error then
			print(json_error)
			return
		end

		for k,v in pairs(cells) do
			table.insert(json_data.cells, {
				x      = v.x,
				y      = v.y,
				offset = v.offset,
				count  = v.count
			})
		end

		json_file:write(json.encode(json_data))
		json_file:close()

		if buffer_size > 0 then
			local id = buffer.create(buffer_size, {{ name=hash("data"), type=buffer.VALUE_TYPE_UINT8, count=1 }})

			for k,v in pairs(cells) do
				buffer.copy_buffer(id, v.offset, v.buffer, 0, #v.buffer)
			end

			local tex_data, tex_error = io.open(json_data.tex_path, "wb")
			if tex_error then
				print(tex_error)
				return
			end
			tex_data:write(buffer.get_bytes(id, hash("data")))
			tex_data:close()
		end
	end

	C.clear = function(self)
		print("Cache: Clearing..")
		local clear_args = {
			width            = cell_size * cells_x,
			height           = cell_size * cells_y,
			type             = resource.TEXTURE_TYPE_2D,
			format           = resource.TEXTURE_FORMAT_RGBA,
			compression_type = resource.COMPRESSION_TYPE_BASIS_UASTC,
			format           = fmt
		}
		
		resource.set_texture(self.tex_res, clear_args, blank_basis)

		self.cells = {}
	end

	C.get_texture = function(self)
		return self.tex_res
	end

	C.get_empty = function(self)
		for y=0,self.cells_y-1 do
			for x=0,self.cells_x-1 do
				if not self.cells[y] or not self.cells[y][x] then
					return x, y
				end
			end
		end
	end

	C.full = function(self)
		for y=0,self.cells_y-1 do
			for x=0,self.cells_x-1 do
				if self:is_free(x,y) then
					return false
				end
			end
		end
		return true
	end

	C.is_free = function(self, x, y)
		return not self.cells[y] or not self.cells[y][x]
	end

	C.get_cells_x = function(self)
		return self.cells_x
	end

	C.get_cells_y = function(self)
		return self.cells_y
	end

	return C
end

return M