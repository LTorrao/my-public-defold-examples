local M = {}

M.init = function()
	local rt_width = render.get_window_width()
	local rt_height = render.get_window_height()

	local color_params = {
		format = render.FORMAT_RGBA32F,
		width  = rt_width,
		height = rt_height,
	}

	local depth_params = {
		format = render.FORMAT_DEPTH,
		width  = rt_width,
		height = rt_height,
		flags  = render.TEXTURE_BIT,
	}

	M._rt        = render.render_target({[render.BUFFER_COLOR_BIT] = color_params, [render.BUFFER_DEPTH_BIT] = depth_params })
	M._width     = rt_width
	M._height    = rt_height
	M.predicate = render.predicate({"model"})
end

M.render = function(state, constants)
	render.set_render_target(M._rt)
	render.set_viewport(0, 0, M._width, M._height)
	render.set_depth_mask(true)
	render.set_stencil_mask(0xff)
	render.clear(state.clear_buffers)

	local camera_world = state.cameras.camera_world
	render.set_view(camera_world.view)
	render.set_projection(camera_world.proj)

	render.enable_state(render.STATE_DEPTH_TEST)
	render.enable_state(render.STATE_CULL_FACE)
	render.draw(M.predicate, camera_world.frustum)
end

M.target = function()
	return M._rt
end

M.width = function()
	return M._width
end

M.height = function()
	return M._height
end

return M
