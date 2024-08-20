varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_scene;
uniform lowp sampler2D texture_depth;

uniform mediump vec4 u_viewport_parameters;
uniform mediump vec4 u_camera_parameters;

const int kernelSampleCount = 16;
vec2 kernel[kernelSampleCount] = vec2[](
    vec2(0.0, 0.0),
    vec2(0.54545456, 0.0),
    vec2(0.16855472, 0.5187581),
    vec2(-0.44128203, 0.3206101),
    vec2(-0.44128197, -0.3206102),
    vec2(0.1685548, -0.5187581),
    vec2(1.0, 0.0),
    vec2(0.809017, 0.58778524),
    vec2(0.30901697, 0.95105654),
    vec2(-0.30901703, 0.9510565),
    vec2(-0.80901706, 0.5877852),
    vec2(-1.0, 0.0),
    vec2(-0.80901694, -0.58778536),
    vec2(-0.30901664, -0.9510566),
    vec2(0.30901712, -0.9510565),
    vec2(0.80901694, -0.5877853));

vec4 get_bokeh()
{
    vec3 color = vec3(0.0);
    float weight = 0.0;
    float bokeh_radius = u_viewport_parameters.z;

    for (int k = 0; k < kernelSampleCount; k++)
    {
        /*
        vec2 o = kernel[k] * bokeh_radius;
        float radius = length(o);
        o *= u_viewport_parameters.xy;

        vec4 s = texture2D(texture_scene, var_texcoord0.st + o);

        if (abs(s.a) >= radius)
        {
            color += s.rgb;
            weight += 1;
        }
        */

        vec2 o = kernel[k];
        o *= u_viewport_parameters.xy * bokeh_radius;
        color += texture2D(texture_scene, var_texcoord0.st + o).rgb;
    }
    // color *= 1.0 / weight;
    color *= 1.0 / kernelSampleCount;
    return vec4(color, 1.0);
}

void main()
{
    vec4 sample_color  = texture2D(texture_scene, var_texcoord0.xy);
    float sample_depth = texture2D(texture_depth, var_texcoord0.xy).r;
    float linear_depth = linearize_depth(sample_depth);
    float coc          = get_coc(linear_depth);
    vec4 bokeh         = get_bokeh();
    
    gl_FragColor = vec4(vec3(linear_depth / u_camera_parameters.y), 1.0);
    gl_FragColor.rgb = vec3(coc);
    gl_FragColor.rgb = bokeh.rgb;
}
