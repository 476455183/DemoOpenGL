precision mediump float;

uniform vec4 SourceColor;

uniform sampler2D Texture;

varying vec2 TextureCoordsOut;

void main()
{
//    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0); // set gl_FragColor to be red color
//    gl_FragColor = SourceColor;
    
    vec4 mask = texture2D(Texture, TextureCoordsOut); // calculate texture pixel
    
    float grey = dot(mask.rgb, vec3(0.3,0.6,0.1)); // texture pixel need the alpha value
    
    gl_FragColor = vec4(mask.rgb, grey); // color for one texture pixel
}