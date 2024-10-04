#version 140

in vec2 var_texcoord0;
out vec4 out_color;

uniform sampler2D tex0;

void main()
{
    vec3 color = texture(tex0, var_texcoord0.xy).rgb;
    out_color = vec4(1.0 - color, 1.0);
}
