varying mediump vec2 var_texcoord0;
uniform lowp sampler2D texture_sampler;

void main()
{
    vec4 color_sample = texture2D(texture_sampler, var_texcoord0);

    float coc = color_sample.r;
    if (coc < 0.0)
    {
        color_sample = coc * vec4(-1, 0, 0, 1);
    }
    else
    {
        color_sample = coc * vec4(1);
    }

    gl_FragColor = color_sample;
}

