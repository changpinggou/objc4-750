#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <stdio.h>

GLuint createGLProgram(const char *vertext, const char *frag);
GLuint createVBO(GLenum target, int usage, int datSize, void *data);
GLuint createTexture2D(GLenum format, int width, int height, void *data);
