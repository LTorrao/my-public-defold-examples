varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_bokeh;

uniform mediump vec4 u_viewport_parameters;
uniform mediump vec4 u_camera_parameters;

vec4 get_blurred_bokeh()
{
    vec4 o = u_viewport_parameters.xyxy * vec2(-0.5, 0.5).xxyy;
    vec4 s = texture2D(texture_bokeh, var_texcoord0.st + o.xy) +
    texture2D(texture_bokeh, var_texcoord0.st + o.zy) +
    texture2D(texture_bokeh, var_texcoord0.st + o.xw) +
    texture2D(texture_bokeh, var_texcoord0.st + o.zw);
    return s * 0.25;
}

void main()
{
    gl_FragColor = get_blurred_bokeh();
}
