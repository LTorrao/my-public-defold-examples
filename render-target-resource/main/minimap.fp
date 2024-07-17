varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;

const float rt_w = 512.0;
const float rt_h = 512.0;

void main()
{
    float w = 1.0 / rt_w;
    float h = 1.0 / rt_h;

    vec4 n_0 = texture2D(texture_sampler, var_texcoord0 + vec2( -w, -h));
    vec4 n_1 = texture2D(texture_sampler, var_texcoord0 + vec2(0.0, -h));
    vec4 n_2 = texture2D(texture_sampler, var_texcoord0 + vec2(  w, -h));
    vec4 n_3 = texture2D(texture_sampler, var_texcoord0 + vec2( -w, 0.0));
    vec4 n_4 = texture2D(texture_sampler, var_texcoord0);
    vec4 n_5 = texture2D(texture_sampler, var_texcoord0 + vec2(  w, 0.0));
    vec4 n_6 = texture2D(texture_sampler, var_texcoord0 + vec2( -w, h));
    vec4 n_7 = texture2D(texture_sampler, var_texcoord0 + vec2(0.0, h));
    vec4 n_8 = texture2D(texture_sampler, var_texcoord0 + vec2(  w, h));

    vec4 sobel_edge_h = n_2 + (2.0*n_5) + n_8 - (n_0 + (2.0*n_3) + n_6);
    vec4 sobel_edge_v = n_0 + (2.0*n_1) + n_2 - (n_6 + (2.0*n_7) + n_8);
    vec4 sobel = sqrt((sobel_edge_h * sobel_edge_h) + (sobel_edge_v * sobel_edge_v));

    gl_FragColor = vec4( vec3(length(sobel.rgb)), 1.0 );
}
