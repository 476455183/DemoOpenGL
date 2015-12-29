// 1 passed into from vertex shader.
// varying means calculating color of every pixel of vertex smoothly according to color of vertex
varying lowp vec4 DestinationColor;

void main(void) { // 2
    gl_FragColor = DestinationColor; // 3, must set gl_FragColor for fragment shader
}