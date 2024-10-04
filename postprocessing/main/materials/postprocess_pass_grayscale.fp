#version 140

in vec2 var_texcoord0;
out vec4 out_color;

uniform sampler2D tex0;

vec3 grayscale(vec3 color, float str) {
    float g = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(color, vec3(g), str);
}

void main()
{
    vec3 color = texture(tex0, var_texcoord0.xy).rgb;
    out_color = vec4(grayscale(color, 1.0), 1.0);
}
