import SimpleOpenNI.*;
SimpleOpenNI kinect;

//toon shading
PShader toon, edges;
PShader normalEdges;
boolean shaderEnabled = true;  

int spacing = 1;
int maxZ = 2000;
int rotation= 0;

int aveZ = 0;

int[] userMap;
ArrayList<PVector> userDepthPoints;

void setup() {
  size(1024, 768, P3D);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);
  kinect.alternativeViewPointDepthToImage();
  toon = loadShader("ToonFrag.glsl", "ToonVert.glsl");
  edges = loadShader("edges.glsl");
  normalEdges = loadShader("normal_edgesFrag.glsl", "normal_edgesVert.glsl");
  noStroke();

  userDepthPoints = new ArrayList<PVector>();
}

void draw() {
  background(0);
  lights();
  kinect.update();

  PVector[] depthPoints = kinect.depthMapRealWorld();

  if (kinect.getNumberOfUsers() > 0) {
    println("user(s) recognized: " + kinect.getNumberOfUsers());

    userDepthPoints.clear();


    userMap = kinect.getUsersPixels(SimpleOpenNI.USERS_ALL);
    /*for (int i = 0; i < userMap.length; i++) {
      //for (int y = 0; y < 480; y+=spacing) {
      //  for (int x = 0; x < 640; x+= spacing) {

      //int i = x + y*640;
      if (userMap[i] >0) {
        userDepthPoints.add( depthPoints[i] );
      }
      // }
    }*/

    /*stroke(255);
     translate(width/2, height/2, -1000);
     for(int i = 0; i < userDepthPoints.size(); i++){
     
     PVector currentPoint = userDepthPoints.get(i);
     pushMatrix();
     point(currentPoint.x, currentPoint.y, currentPoint.z);
     popMatrix();
     }
     */



  //  PVector[] depthPoints = kinect.depthMapRealWorld();
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
     if (p.z < 10 || p.z > maxZ || y == 0 || y == 480 - spacing || x == 0 || x == 640 - spacing){
     // replace it with a point at the depth of the backplane (i.e. maxZ)
     PVector realWorld = new PVector();
     PVector projective = new PVector(p.x, p.y, maxZ);
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

    translate(0, 0, 2000-plusX);



    //toon shading
    if (false) {
      shader(toon);
      float dirY = (mouseY / float(height) - 0.5) * 2;
      float dirX = (mouseX / float(width) - 0.5) * 2;
      directionalLight(204, 204, 204, -dirX, -dirY, -1);
    }

    beginShape(TRIANGLES);

    //for (int i = 0; i < userDepthPoints.size(); i++) {
    //spacing = 1;
    for (int y = 0; y < 480 - spacing; y+= spacing) {
      for (int x = 0; x < 640 -spacing; x+= spacing) { 
                int i = y * 640 + x;           

         if (userMap[i] >0) {
        

        int nw = i;
        int ne = nw + spacing;
        int sw = i + 640 * spacing;
        int se = sw + spacing;
        
        if(!allZero(depthPoints[nw]) && !allZero(depthPoints[ne]) && !allZero(depthPoints[sw]) && !allZero(depthPoints[se])){

//        if (nw < userDepthPoints.size() && ne < userDepthPoints.size() && sw < userDepthPoints.size() && se < userDepthPoints.size()) {

//          // nw, ne, sw
//          fill(rgbImage.pixels[nw]);
//
//          vertex(userDepthPoints.get(nw).x, userDepthPoints.get(nw).y, userDepthPoints.get(nw).z);
//
//          fill(rgbImage.pixels[ne]);
//          vertex(userDepthPoints.get(ne).x, userDepthPoints.get(ne).y, userDepthPoints.get(ne).z);
//
//          fill(rgbImage.pixels[sw]);
//          vertex(userDepthPoints.get(sw).x, userDepthPoints.get(sw).y, userDepthPoints.get(sw).z);
//
//          //ne, se, sw
//          fill(rgbImage.pixels[ne]);
//          vertex(userDepthPoints.get(ne).x, userDepthPoints.get(ne).y, userDepthPoints.get(ne).z);
//
//          fill(rgbImage.pixels[se]);
//          vertex(userDepthPoints.get(se).x, userDepthPoints.get(se).y, userDepthPoints.get(se).z);
//
//          fill(rgbImage.pixels[sw]);
//          vertex(userDepthPoints.get(sw).x, userDepthPoints.get(sw).y, userDepthPoints.get(sw).z);
//          

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
      }
    
    }
    endShape();


    if (shaderEnabled == true) {
      filter(edges);
      // shader(toon);
    }
  } 
  else {
    image(kinect.depthImage(), 0, 0);
  }
}



boolean allZero(PVector p){
  return (p.x == 0 && p.y == 0 && p.z == 0);
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

