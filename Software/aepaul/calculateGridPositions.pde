
float stepsPerDeg = 20 /HALF_PI; // steps entered per 90°

float searchmoveinc = .5;

// positions seen through grid towards machine
// Reference Letter top left 
float tlx = -123.9;
float tly = -88.6; 
// Reference letter top right
float torx = -112.4;
float tory = -88.6; 
// Reference letter bottom right
float brx = -112.4;
float bry = -81.6;
// Reference letter bottom left
float blx = -123.9;
float bly = -81.6; 

// Layout of the lettergrid
int gridcols = 6;
int gridrows = 5;

float rowstartx, rowendx, rowstarty, rowendy;
float[] letterpos = new float[2*50]; // array of stepper positions xyz of all  26 capital letters plus . , ? ! [posX of A, posY of A, posX of B, ...]

void calculateGridPositions() {
  int a = 0;

  println("Gridwidth: " + gridcols + "   Gridheight: " + gridrows);
  println("Reference positions:\ntop left: " + tlx + " / " + tly + "  top right: " + torx + " / " + tory);
  println("bottom left: " + blx + " / " + bly + "  bottom right: " + brx + " / " + bry);

  println("\nStepper positions in the grid:");
  for (int iy = 0; iy < gridrows; iy++) {
    rowstartx = tlx - ((tlx-blx) * iy/(gridrows-1));
    rowendx = torx - ((torx-brx) * iy/(gridrows-1));
    rowstarty = tly - ((tly-bly) * iy/(gridrows-1));
    rowendy = tory - ((tory-bry) * iy/(gridrows-1));
    
    for (float ix = 0; ix < gridcols; ix++) {
      char letter = char((a/2)+65);
      letterpos[a] = rowstartx - ((rowstartx - rowendx) *ix/(gridcols-1)); // stepper x
      letterpos[a+1] = rowstarty - ((rowstarty - rowendy) *ix/(gridcols-1)); // stepper y
      print(letter + ": " + round(letterpos[a]) + " / " + round(letterpos[a+1]) + "  ,  ");
      a += 2;
    }
    println();
  }
  println();
}
