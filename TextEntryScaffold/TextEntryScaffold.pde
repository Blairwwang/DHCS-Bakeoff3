import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

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
final int DPIofYourDeviceScreen = 240; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
int minKeyWidth = (int)sizeOfInputArea / 10;
int keyHeight = minKeyWidth * 16 / 5;
PImage watch;

String[] firstRowKeys = new String[] {"q", "w", "e", "r", "t", "y", "u", "i", "o", "p"};
String[] secondRowKeys = new String[] {"a", "s", "d", "f", "g", "h", "j", "k", "l"};
String[] thirdRowKeys = new String[] {"z", "x", "c", "v", "b", "n", "m", "<-"};
float rowMargin = 5;

//first row


//second row

//third row


//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(PORTRAIT); //can also be PORTRAIT - sets orientation on android device
  size(480, 854); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 20)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  
  drawKeyboard();
  
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
    rect(width/2, height/2 + 150, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", width/2, height/2 + 150); //draw next label

    //my draw code
    //fill(255, 0, 0); //red button
    //rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    //fill(0, 255, 0); //green button
    //rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    textAlign(CENTER);
    fill(200);
    //text("" + currentLetter, width/2, height/2-sizeOfInputArea/4); //draw current letter
  }
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

//my terrible implementation you can entirely replace
void mousePressed()
{
  float spaceKeyX = width / 2 - sizeOfInputArea / 2;
  float spaceKeyY = height / 2 + sizeOfInputArea / 2 - keyHeight;
  float thirdRowXOffset = (sizeOfInputArea - thirdRowKeys.length * minKeyWidth) / 2;
  float thirdRowKeyStartX = width / 2 - sizeOfInputArea / 2 + thirdRowXOffset;
  float thirdRowKeyY = height / 2 + sizeOfInputArea / 2  - keyHeight * 2 - rowMargin;
  float secondRowXOffset = (sizeOfInputArea - secondRowKeys.length * minKeyWidth) / 2;
  float secondRowKeyStartX = width / 2 - sizeOfInputArea / 2 + secondRowXOffset;
  float secondRowKeyY = height / 2 + sizeOfInputArea / 2  - keyHeight * 3 - rowMargin * 2;
  float firstRowXOffset = (sizeOfInputArea - firstRowKeys.length * minKeyWidth) / 2;
  float firstRowKeyStartX = width / 2 - sizeOfInputArea / 2 + firstRowXOffset;
  float firstRowKeyY = height / 2 + sizeOfInputArea / 2  - keyHeight * 4 - rowMargin * 3 - 50;
  print(firstRowKeyY - height/2+sizeOfInputArea/2);
  //click on first row
  if (didMouseClick(firstRowKeyStartX, firstRowKeyY, firstRowKeys.length * minKeyWidth, keyHeight)) {
    int keyNum = int(mouseX - firstRowKeyStartX) / minKeyWidth;
    if (keyNum >= 0 && keyNum < firstRowKeys.length) {
      currentTyped += firstRowKeys[keyNum];
    }
  }
  
  else if (didMouseClick(secondRowKeyStartX, secondRowKeyY, secondRowKeys.length * minKeyWidth, keyHeight)) {
    int keyNum = int(mouseX - secondRowKeyStartX) / minKeyWidth;
    if (keyNum >= 0 && keyNum < secondRowKeys.length) {
      currentTyped += secondRowKeys[keyNum];
    }
  }
  
  else if (didMouseClick(thirdRowKeyStartX, thirdRowKeyY, thirdRowKeys.length * minKeyWidth, keyHeight)) {
    int keyNum = int(mouseX - thirdRowKeyStartX) / minKeyWidth;
    if (keyNum >= 0 && keyNum < thirdRowKeys.length) {
      if (keyNum != thirdRowKeys.length - 1) {
        currentTyped += thirdRowKeys[keyNum];  
      }
      else if (currentTyped.length()>0){
        currentTyped = currentTyped.substring(0, currentTyped.length()-1);
      }
    }
  }
  
  else if (didMouseClick(spaceKeyX, spaceKeyY, sizeOfInputArea, keyHeight)) {
    currentTyped += " ";
  }
  
  //else if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, firstRowKeyY - height/2+sizeOfInputArea/2)) //check if click occured in letter area
  //{
  //  if (currentLetter=='_') //if underscore, consider that a space bar
  //    currentTyped+=" ";
  //  else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
  //    currentTyped = currentTyped.substring(0, currentTyped.length()-1);
  //  else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
  //    currentTyped+=currentLetter;
  //}

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(width/2, height/2 + 150, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
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

void drawKeyboard()
{
  stroke(0);
  fill(230);
  float keyTextYOffset = 5;
  //draw space bar
  float spaceKeyX = width / 2 - sizeOfInputArea / 2;
  float spaceKeyY = height / 2 + sizeOfInputArea / 2 - keyHeight;
  float spaceKeyWidth = sizeOfInputArea;
  rect(spaceKeyX, spaceKeyY, spaceKeyWidth, keyHeight);
  fill(0);
  text("_", spaceKeyX + spaceKeyWidth / 2, spaceKeyY + keyHeight / 2 + keyTextYOffset);
  
  //draw third row of keys
  int numOfThirdRowKeys = thirdRowKeys.length;
  float thirdRowXOffset = (sizeOfInputArea - numOfThirdRowKeys * minKeyWidth) / 2;
  float thirdRowKeyStartX = width / 2 - sizeOfInputArea / 2 + thirdRowXOffset;
  float thirdRowKeyY = height / 2 + sizeOfInputArea / 2  - keyHeight * 2 - rowMargin;
  for (int i = 0; i < numOfThirdRowKeys; i++) {
    float thirdRowKeyX = thirdRowKeyStartX + i * minKeyWidth;
    fill(230);
    rect(thirdRowKeyX, thirdRowKeyY, minKeyWidth, keyHeight);
    fill(0);
    text(thirdRowKeys[i], thirdRowKeyX + minKeyWidth / 2, thirdRowKeyY + keyHeight / 2 + keyTextYOffset);
  }
  
  //draw second row of keys
  int numOfSecondRowKeys = secondRowKeys.length;
  float secondRowXOffset = (sizeOfInputArea - numOfSecondRowKeys * minKeyWidth) / 2;
  float secondRowKeyStartX = width / 2 - sizeOfInputArea / 2 + secondRowXOffset;
  float secondRowKeyY = height / 2 + sizeOfInputArea / 2  - keyHeight * 3 - rowMargin * 2;
  for (int i = 0; i < numOfSecondRowKeys; i++) {
    float secondRowKeyX = secondRowKeyStartX + i * minKeyWidth;
    fill(230);
    rect(secondRowKeyX, secondRowKeyY, minKeyWidth, keyHeight);
    fill(0);
    text(secondRowKeys[i], secondRowKeyX + minKeyWidth / 2, secondRowKeyY + keyHeight / 2 + keyTextYOffset);
  }
  
  //draw first row of keys
  int numOfFirstRowKeys = firstRowKeys.length;
  float firstRowXOffset = (sizeOfInputArea - numOfFirstRowKeys * minKeyWidth) / 2;
  float firstRowKeyStartX = width / 2 - sizeOfInputArea / 2 + firstRowXOffset;
  float firstRowKeyY = height / 2 + sizeOfInputArea / 2  - keyHeight * 4 - rowMargin * 3 - 50;
  for (int i = 0; i < numOfFirstRowKeys; i++) {
    float firstRowKeyX = firstRowKeyStartX + i * minKeyWidth;
    fill(230);
    rect(firstRowKeyX, firstRowKeyY, minKeyWidth, keyHeight);
    fill(0);
    text(firstRowKeys[i], firstRowKeyX + minKeyWidth / 2, firstRowKeyY + keyHeight / 2 + keyTextYOffset);
  }
  
  noStroke();
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
