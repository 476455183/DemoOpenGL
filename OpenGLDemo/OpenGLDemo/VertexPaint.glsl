attribute vec4 Position; // output vPosition from the input vec4 position info

attribute vec2 TextureCoords;

varying vec2 TextureCoordsOut;

void main(void)
{
    gl_Position = Position;
    TextureCoordsOut = TextureCoords;
}