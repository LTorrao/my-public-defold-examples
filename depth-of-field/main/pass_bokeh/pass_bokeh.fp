varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_scene;

uniform vec4 u_bokeh_parameters;

#define BOKEH_KERNEL_MEDIUM

#if defined(BOKEH_KERNEL_SMALL)
const int kernelSampleCount = 16;
const vec2 kernel[kernelSampleCount] = vec2[](
    vec2(0, 0),
    vec2(0.54545456, 0),
    vec2(0.16855472, 0.5187581),
    vec2(-0.44128203, 0.3206101),
    vec2(-0.44128197, -0.3206102),
    vec2(0.1685548, -0.5187581),
    vec2(1, 0),
    vec2(0.809017, 0.58778524),
    vec2(0.30901697, 0.95105654),
    vec2(-0.30901703, 0.9510565),
    vec2(-0.80901706, 0.5877852),
    vec2(-1, 0),
    vec2(-0.80901694, -0.58778536),
    vec2(-0.30901664, -0.9510566),
    vec2(0.30901712, -0.9510565),
    vec2(0.80901694, -0.5877853));
#elif defined(BOKEH_KERNEL_MEDIUM)
    const int kernelSampleCount = 22;
    const vec2 kernel[kernelSampleCount] = vec2[](
        vec2(0, 0),
        vec2(0.53333336, 0),
        vec2(0.3325279, 0.4169768),
        vec2(-0.11867785, 0.5199616),
        vec2(-0.48051673, 0.2314047),
        vec2(-0.48051673, -0.23140468),
        vec2(-0.11867763, -0.51996166),
        vec2(0.33252785, -0.4169769),
        vec2(1, 0),
        vec2(0.90096885, 0.43388376),
        vec2(0.6234898, 0.7818315),
        vec2(0.22252098, 0.9749279),
        vec2(-0.22252095, 0.9749279),
        vec2(-0.62349, 0.7818314),
        vec2(-0.90096885, 0.43388382),
        vec2(-1, 0),
        vec2(-0.90096885, -0.43388376),
        vec2(-0.6234896, -0.7818316),
        vec2(-0.22252055, -0.974928),
        vec2(0.2225215, -0.9749278),
        vec2(0.6234897, -0.7818316),
        vec2(0.90096885, -0.43388376));
#endif


float weigh(float coc, float radius)
{
    return clamp((coc - radius + 2) / 2, 0, 1);
}

vec4 bokeh_round(vec2 uv)
{
    vec2 texel_size = 1.0 / u_bokeh_parameters.xy; // vec2(960.0, 640.0);
    
    vec3 bgColor = vec3(0);
    vec3 fgColor = vec3(0);
    
    float bgWeight = 0;
    float fgWeight = 0;

    float coc = texture2D(texture_scene, uv).a;

    for (int k = 0; k < kernelSampleCount; k++) {
        vec2 o = kernel[k] * u_bokeh_parameters.z;
        float radius = length(o);
        o *= texel_size.xy;

        vec4 s = texture2D(texture_scene, uv + o);

        // float sw = weigh(abs(s.a), radius);
        float swg = weigh(max(0, min(coc, s.a)), radius);
        
        bgColor += s.rgb * swg;
        bgWeight += swg;

        float fgw = weigh(-s.a, radius);
        fgColor += s.rgb * fgw;
        fgWeight += fgw;
    }

    bgColor *= 1 / (bgWeight + (bgWeight == 0 ? 1.0 : 0.0));
    fgColor *= 1 / (fgWeight + (fgWeight == 0 ? 1.0 : 0.0));

    float bgfg = min(1, fgWeight * 3.14159265359 / kernelSampleCount);
    vec3 color = mix(bgColor, fgColor, bgfg);
    
    return vec4(color, bgfg);
}

void main()
{
    gl_FragColor = bokeh_round(var_texcoord0);
}
