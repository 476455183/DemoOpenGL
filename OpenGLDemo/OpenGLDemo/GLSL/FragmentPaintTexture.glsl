precision mediump float;

uniform vec4 SourceColor;

uniform sampler2D Texture;

varying vec2 TextureCoordsOut;

void main()
{
    // mask will be only used to calculate texture pixel
    vec4 mask = texture2D(Texture, TextureCoordsOut);
    
    // texture pixel need the alpha value
    float grey = dot(mask.rgb, vec3(0.3,0.6,0.1));
    
    // color for one texture pixel    
    gl_FragColor = vec4(SourceColor.rgb, grey);
    
    // GLLinePen 1050, use glBlendFunc(GL_SRC_ALPHA, GL_ONE) mode.
    // gl_FragColor = vec4(mask.rgb, grey);
}