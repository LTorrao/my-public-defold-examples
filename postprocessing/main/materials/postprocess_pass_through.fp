#version 140

in vec2 var_texcoord0;
out vec4 out_color;

uniform sampler2D tex0;

void main()
{
    out_color = texture(tex0, var_texcoord0.xy);
}
