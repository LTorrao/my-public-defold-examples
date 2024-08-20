varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_depth;

uniform mediump vec4 u_viewport_parameters;
uniform mediump vec4 u_camera_parameters;

float linearize_depth(float depth)
{
    float ndc = depth * 2.0 - 1.0;
    float near = u_camera_parameters.x;
    float far = u_camera_parameters.y;
    return (2.0 * near * far) / (far + near - ndc * (far - near));
}

float get_coc(float linear_depth)
{
    float focus_distance = u_camera_parameters.z;
    float focus_range    = u_camera_parameters.w;
    float bokeh_radius   = u_viewport_parameters.z;
    float coc            = (linear_depth - focus_distance) / focus_range;
    coc                  = clamp(coc, -1, 1); // * bokeh_radius;
    return coc;
}

void main()
{
    float sample_depth = texture2D(texture_depth, var_texcoord0.xy).r;
    float linear_depth = linearize_depth(sample_depth);
    float coc          = get_coc(linear_depth);
    gl_FragColor       = vec4(coc); // vec4(vec3(linear_depth / u_camera_parameters.y), 1.0);
}
