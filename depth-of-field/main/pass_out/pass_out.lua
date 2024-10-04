local M = {}

M.init = function()
	M.predicate = render.predicate({"pass_out"})
end

M.render = function(state, target_scene, target_coc, target_dof)
	render.set_render_target(render.RENDER_TARGET_DEFAULT)
	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())
	render.clear(state.clear_buffers)

	render.disable_state(render.STATE_DEPTH_TEST)
	render.disable_state(render.STATE_CULL_FACE)

	render.enable_texture("texture_scene", target_scene, render.BUFFER_COLOR0_BIT)
	render.enable_texture("texture_coc", target_coc, render.BUFFER_COLOR0_BIT)
	render.enable_texture("texture_dof", target_dof, render.BUFFER_COLOR0_BIT)
	
	render.draw(M.predicate)

	render.disable_texture("texture_scene")
	render.disable_texture("texture_coc")
	render.disable_texture("texture_dof")
end

return M
