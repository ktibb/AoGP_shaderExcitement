#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec3 normal;
varying vec3 lightDir;

void main() {  
  float intensity;
  vec4 color;
  intensity = max(0.0, dot(lightDir, normal));

  if (intensity > 0.95) {
    color = vec4(1.0, 0.5, 0.5, 1.0);
  } else if (intensity > 0.8) {
    color = vec4(0.6, 0.3, 0.3, 1.0);
  } else if (intensity > 0.1) {
    color = vec4(0.4, 0.2, 0.2, 1.0);
  } else {
    color = vec4(0.2, 0.1, 0.1, 1.0);
  }

  gl_FragColor = color;  
}