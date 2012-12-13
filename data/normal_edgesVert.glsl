uniform mat3 normalMatrix;
uniform mat4 projmodelviewMatrix;
uniform vec3 lightNormal[8];

attribute vec3 inNormal;
attribute vec4 inVertex;

varying vec3 normal;
varying vec3 lightDir;


void main(){
  normal = normalize(projmodelviewMatrix * inVertex);
  gl_Position = projmodelviewMatrix * inVertex;
}