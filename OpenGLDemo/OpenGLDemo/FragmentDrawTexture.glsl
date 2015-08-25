precision mediump float;
uniform vec4 SourceColor;
uniform sampler2D Texture;
varying vec2 TextureCoordsOut;

void main()
{
    vec4 mask = texture2D(Texture, TextureCoordsOut);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
