local M = {}

M.init = function()
	M.predicate = render.predicate({"pass_out"})
end

M.render = function(state, target)
	render.set_render_target(render.RENDER_TARGET_DEFAULT)
	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())
	render.clear(state.clear_buffers)

	render.disable_state(render.STATE_DEPTH_TEST)
	render.disable_state(render.STATE_CULL_FACE)

	render.enable_texture(0, target, render.BUFFER_COLOR0_BIT)
	render.draw(M.predicate)
end

return M
