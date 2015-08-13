attribute vec4 Position;
attribute vec4 ASourceColor;

varying vec4 DestinationColor;

void main(void) {
    DestinationColor = ASourceColor;
    gl_Position = Position;
}