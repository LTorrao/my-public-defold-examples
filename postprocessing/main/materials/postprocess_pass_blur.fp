#version 140

in vec2 var_texcoord0;
out vec4 out_color;

uniform sampler2D tex0;

uniform fs_uniforms
{
    // width, height, direction_x, direction_y
    uniform vec4 u_params;
};

// Credit: https://github.com/Experience-Monks/glsl-fast-gaussian-blur/blob/master/13.glsl
vec4 blur13(vec2 uv, vec2 resolution, vec2 direction)
{
    vec4 color = vec4(0.0);
    vec2 off1 = vec2(1.411764705882353) * direction;
    vec2 off2 = vec2(3.2941176470588234) * direction;
    vec2 off3 = vec2(5.176470588235294) * direction;
    color += texture(tex0, uv) * 0.1964825501511404;
    color += texture(tex0, uv + (off1 / resolution)) * 0.2969069646728344;
    color += texture(tex0, uv - (off1 / resolution)) * 0.2969069646728344;
    color += texture(tex0, uv + (off2 / resolution)) * 0.09447039785044732;
    color += texture(tex0, uv - (off2 / resolution)) * 0.09447039785044732;
    color += texture(tex0, uv + (off3 / resolution)) * 0.010381362401148057;
    color += texture(tex0, uv - (off3 / resolution)) * 0.010381362401148057;
    return color;
}

void main()
{
    out_color = blur13(var_texcoord0.st, u_params.xy, u_params.zw);
}
