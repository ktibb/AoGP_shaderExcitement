import SimpleOpenNI.*;
SimpleOpenNI kinect;

//toon shading
PShader toon, edges;
PShader normalEdges;
boolean shaderEnabled = true;  

int spacing =5;
int maxZ = 2000;
int rotation= 0;

int aveZ = 0;

void setup() {
  size(1024, 768, P3D);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.alternativeViewPointDepthToImage();
  toon = loadShader("ToonFrag.glsl", "ToonVert.glsl");
  edges = loadShader("edges.glsl");
  normalEdges = loadShader("normal_edgesFrag.glsl", "normal_edgesVert.glsl");
  noStroke();
}

void draw() {
  background(0);
  lights();
  kinect.update();
  PVector[] depthPoints = kinect.depthMapRealWorld();
  PImage rgbImage = kinect.rgbImage();

  int numPoints = 0;

  // cleanup pass
  for (int y = 0; y < 480; y+=spacing) {
    for (int x = 0; x < 640; x+= spacing) { 
      int i = y * 640 + x;
      PVector p = depthPoints[i];

      aveZ += p.z;
      numPoints++;

      // if the point is on the edge or if it has no depth
      if (p.z < 10 || p.z > maxZ ) {//|| y == 0 || y == 480 - spacing || x == 0 || x == 640 - spacing
        // replace it with a point at the depth of the backplane (i.e. maxZ)
        PVector realWorld = new PVector();
        PVector projective = new PVector(x, y, maxZ);
        // to get the point in the right place, we need to translate
        // from x/y to realworld coordinates to match our other points:
        kinect.convertProjectiveToRealWorld(projective, realWorld);

        depthPoints[i] = realWorld;
      }
    }
  }

  aveZ /= numPoints;

  translate(width/2, height/2, aveZ);

  float plusX = map(mouseX, 0, width, 0, 4000);

  rotateX(radians(180));
  //rotateY(radians(180));
 // rotateY(radians(rotation));
  //rotation++;
  translate(0, 0, -aveZ);
  
  translate(0,0,2000-plusX);
  


  //toon shading
  if(false){
    shader(toon);
     float dirY = (mouseY / float(height) - 0.5) * 2;
    float dirX = (mouseX / float(width) - 0.5) * 2;
    directionalLight(204, 204, 204, -dirX, -dirY, -1);
  }

  beginShape(TRIANGLES);

  for (int y = 0; y < 480 - spacing; y+= spacing) {
    for (int x = 0; x < 640 -spacing; x+= spacing) { 
      int i = y * 640 + x;           

      int nw = i;
      int ne = nw + spacing;
      int sw = i + 640 * spacing;
      int se = sw + spacing;

      // nw, ne, sw
      fill(rgbImage.pixels[nw]);
      vertex(depthPoints[nw].x, depthPoints[nw].y, depthPoints[nw].z);

      fill(rgbImage.pixels[ne]);
      vertex(depthPoints[ne].x, depthPoints[ne].y, depthPoints[ne].z);

      fill(rgbImage.pixels[sw]);
      vertex(depthPoints[sw].x, depthPoints[sw].y, depthPoints[sw].z);

      //ne, se, sw
      fill(rgbImage.pixels[ne]);
      vertex(depthPoints[ne].x, depthPoints[ne].y, depthPoints[ne].z);

      fill(rgbImage.pixels[se]);
      vertex(depthPoints[se].x, depthPoints[se].y, depthPoints[se].z);

      fill(rgbImage.pixels[sw]);
      vertex(depthPoints[sw].x, depthPoints[sw].y, depthPoints[sw].z);
     
  }
  }
  endShape();
 
 
  if (shaderEnabled == true) {
    filter(edges);
   // shader(toon);
    

   
  }
}






void keyPressed() {
  if (keyCode == UP) {
    maxZ += 100;
  }
  if (keyCode == DOWN) {
    maxZ -= 100;
  }
  println(maxZ);
}


void mousePressed() {
  if (shaderEnabled) {
    shaderEnabled = false;
    resetShader();
  } 
  else {
    shaderEnabled = true;
  }
}

