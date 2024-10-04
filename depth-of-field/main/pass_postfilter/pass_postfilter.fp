varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_bokeh;

uniform vec4 u_postfilter_params;

vec4 postfilter(vec2 uv)
{
    vec2 texel_size = 1 / u_postfilter_params.xy;

    vec4 o = texel_size.xyxy * vec2(-0.5, 0.5).xxyy;
    vec4 s = texture2D(texture_bokeh, uv + o.xy) +
             texture2D(texture_bokeh, uv + o.zy) +
             texture2D(texture_bokeh, uv + o.xw) +
             texture2D(texture_bokeh, uv + o.zw);
    return s * 0.25;
}

void main()
{   
    gl_FragColor = postfilter(var_texcoord0);
    // gl_FragColor =texture2D(texture_bokeh, var_texcoord0);
}
