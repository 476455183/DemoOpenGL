precision mediump float;

uniform vec4 SourceColor;

void main()
{
//    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0); // set gl_FragColor to be red color
    gl_FragColor = SourceColor;
}