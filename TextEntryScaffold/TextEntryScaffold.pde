import java.util.Arrays;
import java.util.List;
import java.util.Collections;
import java.util.Random;
import garciadelcastillo.dashedlines.*;


String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 200; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';
//List<List<String>> allLetters = new ArrayList<List<String>>();
String[] allLetters =  {"etaoi", "nshrd", "lcumw", "fgypb", "vkjxqz"};
boolean phaseOne = false;
int currentQuadrant = -1;
// Declare the main DashedLines object
DashedLines dash;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  // Initialize it, passing a reference to the current PApplet
  dash = new DashedLines(this);

  // Set the dash-gap pattern in pixels
  dash.pattern(10, 5);
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  
  fill(100);
  
  //input area should be 1" by 1"
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); 
    
  // draw dash lines to separate the watch screen into 6 areas 
  //width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/2

  //fill(40);
  stroke(255, 255, 255);//make the line white
  float cx = width / 2;
  float cy = height / 2;
  float offsetX = sizeOfInputArea/4;
  float offsetY = sizeOfInputArea/6;
  // h1
  line(cx - sizeOfInputArea/2,  cy - sizeOfInputArea/6, cx + sizeOfInputArea/2, cy - sizeOfInputArea/6);
  // h2
  line(cx - sizeOfInputArea/2,  cy + sizeOfInputArea/6, cx + sizeOfInputArea/2, cy + sizeOfInputArea/6);
  // v1
  line(cx,  cy - sizeOfInputArea/2, cx, cy + sizeOfInputArea/2);
  
  // draw text
  fill(255);
  textAlign(CENTER);
  // ok fine I'll do the math
  if (!phaseOne) {
    for (int i = 0; i < 6; i++) {
      int xc = i % 2;
      int yc = (i-xc) / 2;
      if (i == 5) {
        text("-", cx - sizeOfInputArea/2 + offsetX + sizeOfInputArea/2 * xc,  
        cy - sizeOfInputArea/2 + offsetY + sizeOfInputArea/3 * yc);
      } else {
        text(allLetters[i], cx - sizeOfInputArea/2 + offsetX + sizeOfInputArea/2 * xc,  
        cy - sizeOfInputArea/2 + offsetY + sizeOfInputArea/3 * yc);
      }   
    }  
  } else {
    // draw out each letters
    for (int i = 0; i < 6; i++) {
      int xc = i % 2;
      int yc = (i-xc) / 2;
      if (i == 5 && currentQuadrant != 4) {
        text("", cx - sizeOfInputArea/2 + offsetX + sizeOfInputArea/2 * xc,  
        cy - sizeOfInputArea/2 + offsetY + sizeOfInputArea/3 * yc);
      } else {
        text(allLetters[currentQuadrant].charAt(i), cx - sizeOfInputArea/2 + offsetX + sizeOfInputArea/2 * xc,  
        cy - sizeOfInputArea/2 + offsetY + sizeOfInputArea/3 * yc);
      }   
    } 
  }


  

  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label

    ////my draw code
    //fill(255, 0, 0); //red button
    //rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    //fill(0, 255, 0); //green button
    //rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    //textAlign(CENTER);
    //fill(200);
    //text("" + currentLetter, width/2, height/2-sizeOfInputArea/4); //draw current letter
  }
}

// getQuadrant takes in raw mouseX and mouseY, and return a quadrant if it is inside the watch
int getQuadrant() {
  float cx = width / 2;
  float cy = height / 2;
  float S = sizeOfInputArea;
  // This can be calculated with two lines since we have the (x,y) positino... 
  // but I am concerned that float division might be error prone
  // this is also an excuse to not do the math
  if (didMouseClick(cx-S/2, cy-S/2, S / 2, S/ 3)) {
    return 0; // "etaoi" quadrant
  }
  else if (didMouseClick(cx, cy-S/2, S / 2, S/ 3)) {
    return 1; // "NSHRD" quadrant
  }
  else if (didMouseClick(cx-S/2, cy-S/6, S / 2, S/ 3)) {
    return 2; // "lcumw" quadrant
  }
  else if (didMouseClick(cx, cy-S/6, S / 2, S/ 3)) {
    return 3; // "fgypb" quadrant
  }
  else if (didMouseClick(cx-S/2, cy+S/6, S / 2, S/ 3)) {
    return 4; // "vkjxqz" quadrant
  }
  else if (didMouseClick(cx, cy+S/6, S / 2, S/ 3)) {
    return 5; // space bar quadrant
  }
  return -1; // outside
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

//my terrible implementation you can entirely replace
void mousePressed()
{
  int quadrant = getQuadrant();
  // clicked outside, just ignore
  if (quadrant == -1) {
    //You are allowed to have a next button outside the 1" area
    if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
    {
      nextTrial(); //if so, advance to next trial
    }
    return;
  }
  // if we are on screen 1
  if (!phaseOne) {
    if (quadrant == 5) { // clicked space, simply proceed
      currentTyped+=" ";
      return;
    }
    currentQuadrant = quadrant;
    phaseOne = true;
    return;
  } else {
    // catch the edge case where we click the 5th quadrant but we are at the frist four cases
    if (currentQuadrant <= 4 && quadrant == 5) {
      return;
    }
    currentTyped+= allLetters[currentQuadrant].charAt(quadrant);
    phaseOne = false;
  }


}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}





//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
