local M = {}

M.init = function()
	local rt_width = render.get_window_width() / 2
	local rt_height = render.get_window_height() / 2

	local color_params = {
		format = render.FORMAT_RGBA32F,
		width  = rt_width,
		height = rt_height,
	}

	M.rt 		= render.render_target({[render.BUFFER_COLOR_BIT] = color_params})
	M.width     = rt_width
	M.height    = rt_height
	M.predicate = render.predicate({"pass_downsample"})
	M.constants = render.constant_buffer()
end

M.render = function(state, scene_pass, target_coc)

	M.constants.u_prefilter_params = vmath.vector4(scene_pass.width(), scene_pass.height(), 0, 0)

	render.set_render_target(M.rt)
	render.set_viewport(0, 0, M.width, M.height)

	render.set_view(vmath.matrix4())
	render.set_projection(vmath.matrix4())

	render.disable_state(render.STATE_DEPTH_TEST)
	render.disable_state(render.STATE_CULL_FACE)

	render.enable_texture("texture_scene", scene_pass.target(), render.BUFFER_COLOR0_BIT)
	render.enable_texture("texture_coc", target_coc, render.BUFFER_COLOR0_BIT)

	render.draw(M.predicate)

	render.set_render_target(render.RENDER_TARGET_DEFAULT)

	render.disable_texture("texture_scene")
	render.disable_texture("texture_coc")
end

M.target = function()
	return M.rt
end

return M
