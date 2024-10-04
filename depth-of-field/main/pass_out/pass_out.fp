varying mediump vec2 var_texcoord0;
uniform lowp sampler2D texture_scene;
uniform lowp sampler2D texture_coc;
uniform lowp sampler2D texture_dof;

void main()
{
    vec4 scene_sample  = texture2D(texture_scene, var_texcoord0);
    vec4 coc_sample    = texture2D(texture_coc, var_texcoord0);
    vec4 dof_sample    = texture2D(texture_dof, var_texcoord0);
    
    //float dof_strength = smoothstep(0.1, 1, abs(coc_sample.r));
    //vec3 color         = mix(scene_sample.rgb, dof_sample.rgb, dof_strength);

    float dofStrength = smoothstep(0.1, 1, abs(coc_sample.r));
    vec3 color = mix(
        scene_sample.rgb, dof_sample.rgb,
        dofStrength + dof_sample.a - dofStrength * dof_sample.a
    );

    gl_FragColor = vec4(color, scene_sample.a);

    //gl_FragColor = dof_sample;
}

