#version 140

in vec2 var_texcoord0;
out vec4 out_color;

uniform sampler2D tex0;

uniform fs_uniforms
{
    uniform vec4 u_params; // x: time
};

void main()
{
    vec3 color = texture(tex0, var_texcoord0.st * 8.0 * sin(u_params.x * 0.1)).rgb;
    out_color = vec4(color, 1.0);
}
