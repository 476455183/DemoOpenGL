uniform mat4 Projection;
uniform mat4 ModelView;
attribute vec4 Position;

void main(void)
{
    gl_Position = Projection * ModelView * Position;
}