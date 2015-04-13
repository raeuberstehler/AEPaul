/// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Example 18-1: User input


PFont f;


// Variable to store text currently being typed
String typing = "";
// Variable to store saved text when return is hit
String[] texts = {
  "afxsa", 
  "afxsa", 
  "afxsa", 
  "afxsa"
};

// Home Positions of the device
float xhome = -199;
float yhome = -1;
// Current  Positions of the mirror
float xcurrent = xhome;
float ycurrent = yhome;

// Variables needed for the delay at the end of the aepaul function, performed after each letter
int time;
int wait = 2700;
int waitBetweenTexts = 5000;

boolean pause = true;

import processing.serial.*;
Serial plotter;
// ARDUINO PORT TO REPLACE
String grbl = "/dev/tty.usbmodem411"; // MAC

void setup() {  
  boolean printerReady = true;
  time = millis();//store the current time
  size(500, 400);
  f = createFont("Arial", 16, true);

  // write the stepper positions for each letter into an array
  calculateGridPositions();

  print("current Ports open: "); 
  println(Serial.list());
  //  plotter = new Serial(this, Serial.list()[1], 115200); // Windows: update port XX in Serial.list()[XX] for your port
  plotter = new Serial(this, grbl, 115200); // mac: update grbl  for your port
  while (plotter.available () < 1) { // wait for printer to call back
    while (true) {
      if (millis() - time >= 30) {
        time = millis();//also update the stored time
        //   println(time);
        break;
      }
    }
    print(".");
    if (millis() > 8000) {
      println("\nNo printer found");
      printerReady = false;
      exit();
      break;
    }
  }
  if (printerReady) {
    println();
    viewGrblCommands();
    plotter.write("$H\n"); // run Homing
  }
  println("\n____Homing____");
  moveTo(letterpos[0], letterpos[0 + 1]);
  printArray(texts);
  while (true) {
    if (millis() - time >= 15000) {
      time = millis();//also update the stored time
      //   println(time);
      break;
    }
  }
}

void draw() {
  background(255);
  int indent = 25;

  // Set the font and fill for text
  textFont(f);
  fill(0);

  // Display everything
  text("Click in this applet and type. Press DEL to start \n Hit return to send to the printer.", indent, 40);
  text(typing, indent, 90);
  text(texts[currentText], indent, 130);

  if (pause == false) {
    while (true) {
      if (millis() - time >= waitBetweenTexts) {
        time = millis();//also update the stored time
        // println(time);
        break;
      }
    } 
    plotter.write("m4\n"); // open shutter
    println("MOVING AROUND FIELD");
    moveTo((tlx-2), (tly-2));
    moveTo((tlx+2), (tly-2));
    moveTo((tlx-.5), (tly-.5));
    moveTo((tlx-.5), (tly-.5));
    moveTo((tlx-2), (tly-2));
    while (true) {
      if (millis() - time >= 15000) {
        time = millis();//also update the stored time
        // println(time);
        break;
      }
    } 
    plotter.write("m3\n"); // close shutter

    println("WRITING");
    aepaul(texts[currentText]); 
    println("\n" + texts[currentText]); 
    currentText++;
    if (currentText >= texts.length) {
      currentText = 0;
    }
  }
  while (plotter.available () > 0) {
    print(char(plotter.read()));
  }
}

int currentText = 0;
void keyPressed() {
  // If the return key is pressed, save the String and clear it

  switch(key) {
  case '\n':
    print("texts: ");
    // send new text to array
    for (int i = texts.length-1; i > 0; i--) {
      texts[i] = texts[i-1];
      print(texts[i]);
      print(" , ");
    } 
    texts[0] = typing.toLowerCase();
    println(texts[0]);

    // A String can be cleared by setting it equal to ""
    typing = "";
    break;
  case BACKSPACE:
    typing = typing.substring(0, max(0, typing.length()-1));
    break;
  case '4':
    xcurrent += searchmoveinc;
    println("LEFT" + "  x: " + xcurrent + "  y: " + ycurrent);
    plotter.write("g0x" + xcurrent + "y" + ycurrent + "\n"); // send point coords to plotter
    break;
  case '6':
    xcurrent -= searchmoveinc;
    println("RIGHT" + "  x: " + xcurrent + "  y: " + ycurrent);
    plotter.write("g0x" + xcurrent + "y" + ycurrent + "\n"); // send point coords to plotter
    break;
  case '8':
    ycurrent += searchmoveinc;
    println("UP" + "  x: " + xcurrent + "  y: " + ycurrent);
    plotter.write("g0x" + xcurrent + "y" + ycurrent + "\n"); // send point coords to plotter
    break;
  case '2':
    ycurrent -= searchmoveinc;
    println("DOWN" + "  x: " + xcurrent + "  y: " + ycurrent);
    plotter.write("g0x" + xcurrent + "y" + ycurrent + "\n"); // send point coords to plotter
    break;
  case DELETE:
    if (pause == true) {
      pause = false;
      println("WRITING CONTINUES");
    } 
    else {
      pause = true;
      println("WRITING PAUSED");
    }  
    break;  
  case ';':
    println("WRITE SETTINGS TO GRBL");
    // plotter.write("$H\n"); // homing
    // plotter.write("$26=150\n"); // homing debounce
    // plotter.write("$101=50\n"); // (y, step/mm)
    // plotter.write("$102=50\n"); // (z, step/mm)
    break;
  case '/':
    println("HOMING");
    moveTo(-112, -20); // send point coords to plotter
    plotter.write("$H\n"); // run Homing
    break;   
  case '_':
    println("GRBL SETTINGS");
    plotter.write("$$\n"); // view GRBL settings
    break;
  case '$':
    println("HELP");
    plotter.write("$\n"); // view Help
    break;
  case '*':
    println("CURRENT POSITION");
    plotter.write("?\n"); // view current position
    break;   
  case '#':
    println("PARAMETERS");
    plotter.write("$#\n"); // view Parameters
    break;    
  case '%': // print Shortcuts
    viewGrblCommands();
    break;
  case '<':
    println("SHUTTER");
    plotter.write("m4\n"); // open shutter
    while (true) {
      if (millis() - time >= 200) {
        time = millis();//also update the stored time
        //   println(time);
        break;
      }
    }
    plotter.write("m3\n"); // close shutter
    break;
  default:
    // Otherwise, concatenate the String
    // Each character typed by the user is added to the end of the String variable.
    typing = typing + key;
    break;
  }
}

void aepaul(String t) {
  for ( int i = 0; i < t.length (); i++) {
    char c = t.charAt(i);
    int charNr = (int(c)-97)*2;

    switch (c) {
    case 'a':
    case 'b':
    case 'c':
    case 'd':
    case 'e':
    case 'f':
    case 'g':
    case 'h':
    case 'i':
    case 'j':
    case 'k':
    case 'l':
    case 'm':
    case 'n':
    case 'o':
    case 'p':
    case 'q':
    case 'r':
    case 's':
    case 't':
    case 'u':
    case 'v':
    case 'w':
    case 'x':
    case 'y':
    case 'z':
      println(c + " = " + charNr + ":  x: " + letterpos[charNr] + "  y: " + letterpos[charNr + 1]);
      moveTo(letterpos[charNr], letterpos[charNr + 1]); // send point coords to plotter
      break;
    case ' ':
      println("leerzeichen");
      moveTo(letterpos[52], letterpos[52 + 1]); // send point coords to plotter
      break;
    case '.': // needed ?
      println(".");
      moveTo(letterpos[54], letterpos[54+ 1]); // send point coords to plotter
      break;
    case ',':
      println(",");
      moveTo(letterpos[56], letterpos[56 + 1]); // send point coords to plotter
      break;
    case '!':
      println("!");
      // moveTo(letterpos[56], letterpos[56 + 1]); // send point coords to plotter
      break;
    case '?':
      println("?");
      moveTo(letterpos[58], letterpos[58 + 1]); // send point coords to plotter
      break;
    case '-':
      println("-");
      // moveTo(letterpos[56], letterpos[56 + 1]); // send point coords to plotter
      break;
    }
     plotter.write("m4\n"); // open shutter
    while (true) {
      if (millis() - time >= 20) {
        time = millis();//also update the stored time
        //   println(time);
        break;
      }
    }
    plotter.write("m3\n"); // close shutter
    
    // Delay
    // check the difference between now and the previously stored time is greater than the wait interval
    while (true) {
      if (millis() - time >= wait) {
        time = millis();//also update the stored time
        if (time > 50000) time = 0;
        //   println(time);
        break;
      }
    }
  }
}

void moveTo(float x, float y) {
  xcurrent = x;
  ycurrent = y;
  plotter.write("g0x" + xcurrent + "y" + ycurrent + "\n"); // send point coords to plotter
}

void viewGrblCommands() {
  println("\nGRBL command Keys:");
  println("* = current Position");
  println("$ = view Help");
  println("_ = view GRBL Settings");
  println("/ = run Homing");
  println("# = view Parameters");
  println("% = print shortcuts");
}

