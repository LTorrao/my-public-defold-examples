local pass_scene = require("main/pass_scene/pass_scene")

local M = {}

M.init = function()
	local rt_width = render.get_window_width()
	local rt_height = render.get_window_height()
	
	local color_params = {
		format = render.FORMAT_R32F,
		width  = rt_width,
		height = rt_height,
	}

	M.rt = render.render_target({[render.BUFFER_COLOR_BIT] = color_params})
	M.width = rt_width
	M.height = rt_height
	M.constants = render.constant_buffer()
	M.predicate = render.predicate({"pass_coc"})
end

M.render = function(state)
	render.set_viewport(0, 0, M.width, M.height)
	render.set_render_target(M.rt)
	render.disable_state(render.STATE_DEPTH_TEST)
	render.set_view(vmath.matrix4())
	render.set_projection(vmath.matrix4())

	render.enable_texture(0, pass_scene.target(), render.BUFFER_DEPTH_BIT)

	local inv_width = 1 / pass_scene.width()
	local inv_height = 1 / pass_scene.height()
	local params = state.camera_params

	M.constants.u_camera_parameters = vmath.vector4(params.near_z, params.far_z, params.focus_distance, params.focus_range)
	M.constants.u_viewport_parameters = vmath.vector4(inv_width, inv_height, params.bokeh_radius, 0)
	render.draw(M.predicate, { constants = M.constants })
end

M.target = function()
	return M.rt
end

return M
