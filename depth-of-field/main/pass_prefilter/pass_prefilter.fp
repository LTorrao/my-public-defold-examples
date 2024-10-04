varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_scene;
uniform lowp sampler2D texture_coc;

uniform vec4 u_prefilter_params;

vec4 prefilter(vec2 uv)
{
    vec4 o = u_prefilter_params.xyxy * vec2(-0.5, 0.5).xxyy;
    float coc0 = texture2D(texture_coc, uv + o.xy).r;
    float coc1 = texture2D(texture_coc, uv + o.zy).r;
    float coc2 = texture2D(texture_coc, uv + o.xw).r;
    float coc3 = texture2D(texture_coc, uv + o.zw).r;

    float cocMin = min(min(min(coc0, coc1), coc2), coc3);
    float cocMax = max(max(max(coc0, coc1), coc2), coc3);
    float coc = cocMax >= -cocMin ? cocMax : cocMin;

    return vec4(texture2D(texture_scene, uv).rgb, coc);
}

void main()
{
    gl_FragColor = prefilter(var_texcoord0);
}
