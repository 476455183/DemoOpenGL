attribute vec4 Position; // 1 variable passed into
attribute vec4 ASourceColor; // 2

// 3 variable passed out
// varying means calculating color of every pixel of vertex smoothly according to color of vertex
varying vec4 DestinationColor;

void main(void) { // 4
    DestinationColor = ASourceColor; // 5 config color of destination
    gl_Position = Position; // 6 gl_Position is built-in pass-out variable. Must config for in vertex shader
}