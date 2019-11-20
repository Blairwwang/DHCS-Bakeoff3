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
final int DPIofYourDeviceScreen = 277; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
int firstRowKeyWidth;
int secondRowKeyWidth;
int thirdRowKeyWidth;
int keyHeight;
PImage watch;
PFont Menlo;
PFont Arial;

String[] firstRowKeys = new String[] {"q", "w", "e", "r", "t", "y", "u", "i", "o", "p"};
String[] secondRowKeys = new String[] {"a", "s", "d", "f", "g", "h", "j", "k", "l"};
String[] thirdRowKeys = new String[] {"z", "x", "c", "v", "b", "n", "m", "<-"};
float rowMargin = 0;

boolean firstClick = false;
float spaceKeyX;
float spaceKeyY; 
float spaceKeyHeight;
float spaceKeyWidth;
float thirdRowXOffset;
float thirdRowKeyStartX;
float thirdRowKeyY;
float secondRowXOffset;
float secondRowKeyStartX;
float secondRowKeyY; 
float firstRowXOffset;
float firstRowKeyStartX;
float firstRowKeyY;
float keyTextYOffset;

void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(PORTRAIT); //can also be PORTRAIT - sets orientation on android device
  size(720, 1280); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  Arial = createFont("Arial", 20, false);
  Menlo = createFont("Menlo", 15, false);
  textFont(Menlo); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  
  firstRowKeyWidth = (int)sizeOfInputArea / 10;
  secondRowKeyWidth = (int)sizeOfInputArea / 9;
  thirdRowKeyWidth = (int)sizeOfInputArea / 8;
  keyHeight = firstRowKeyWidth * 12 / 5;
  
  spaceKeyX = width / 2 - sizeOfInputArea / 2;
  spaceKeyY = height / 2 + sizeOfInputArea / 2 - keyHeight / 2;
  spaceKeyHeight = keyHeight / 2;
  spaceKeyWidth = sizeOfInputArea;
  thirdRowXOffset = (sizeOfInputArea - thirdRowKeys.length * thirdRowKeyWidth) / 2;
  thirdRowKeyStartX = width / 2 - sizeOfInputArea / 2 + thirdRowXOffset;
  thirdRowKeyY = height / 2 + sizeOfInputArea / 2  - (keyHeight + rowMargin) * 1 - spaceKeyHeight;
  secondRowXOffset = (sizeOfInputArea - secondRowKeys.length * secondRowKeyWidth) / 2;
  secondRowKeyStartX = width / 2 - sizeOfInputArea / 2 + secondRowXOffset;
  secondRowKeyY = height / 2 + sizeOfInputArea / 2  - (keyHeight + rowMargin) * 2 - spaceKeyHeight;
  firstRowXOffset = (sizeOfInputArea - firstRowKeys.length * firstRowKeyWidth) / 2;
  firstRowKeyStartX = width / 2 - sizeOfInputArea / 2 + firstRowXOffset;
  firstRowKeyY = height / 2 + sizeOfInputArea / 2  - (keyHeight + rowMargin) * 3 - spaceKeyHeight;
  keyTextYOffset = 5;
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  textFont(Arial);
  drawKeyboard();
  
  if (mousePressed) {
    String key = "";
    key = keyForClickPos();
    textFont(Arial);
    drawLetter(key); 
    expandLetter(key);
  }
  
  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    textFont(Menlo);
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f);
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    text("Raw WPM: " + wpm, width / 2, 100);
    text("Freebie errors: " + freebieErrors, width / 2, 120);
    text("Penalty: " + penalty, width / 2, 140);
    text("WPM w/ penalty: " + (wpm-penalty), width / 2, 160); //yes, minus, becuase higher WPM is better
    text("Finished", width / 2, 80);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", width / 2, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & firstClick)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    textFont(Menlo);
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 5, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 6, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 5, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(width/2 - 100, height/2 + 150, 200, 200); //draw next button
    fill(255);
    textAlign(CENTER);
    text("NEXT > ", width/2, height/2 + 250); //draw next label
    //my draw code
    //fill(255, 0, 0); //red button
    //rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    //fill(0, 255, 0); //green button
    //rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    textAlign(CENTER);
    fill(200);
    //text("" + currentLetter, width/2, height/2-sizeOfInputArea/4); //draw current letter
  }
  
  if (mousePressed) {
    String key = "";
    key = keyForClickPos();
    textFont(Arial);
    drawLetter(key); 
    expandLetter(key);
  }
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}
  
//my terrible implementation you can entirely replace
void mouseReleased()
{
  firstClick = true;
  String key = keyForClickPos();
  switch (key) {
    case "_":
      currentTyped += " ";
      break;
    case "<-":
      if (currentTyped.length() > 0) currentTyped = currentTyped.substring(0, currentTyped.length()-1);
      break;
    case "":
      break;
    default:
      currentTyped += key;
      break;
  }
  
  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(width/2 - 100, height/2 + 150, 200, 200)) //check if click is in next button
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

void drawLetter(String key) {
  fill(255);
  if (!key.equals("")) {
    text(key, width / 2, firstRowKeyY - 15);
  }
  
}

int contains(String[] row, String key)
{
  for (int i = 0; i < row.length; i++) {
    if (key.equals(row[i])){
       return i; 
    }
  }
  return -1;
}

void expandLetter(String key) {
  int ind;
  stroke(0);
  fill(255);
  if (key.equals("_")) {
    //draw space bar
    rect(spaceKeyX, spaceKeyY - 10, spaceKeyWidth, keyHeight / 2 + 10);
    fill(0);
    text("_", spaceKeyX + spaceKeyWidth / 2, spaceKeyY + keyHeight / 4 + keyTextYOffset);
  }
  
  if ((ind = contains(firstRowKeys, key)) > -1){
    drawExpandedKey(firstRowKeys, firstRowKeyWidth, firstRowKeyY, ind);
  }
  else if ((ind = contains(secondRowKeys, key)) > -1){
    drawExpandedKey(secondRowKeys, secondRowKeyWidth, secondRowKeyY, ind);
  }
  else if ((ind = contains(thirdRowKeys, key)) > -1) {
    drawExpandedKey(thirdRowKeys, thirdRowKeyWidth, thirdRowKeyY, ind);
  }
}

void resetLetters() {
  firstRowKeyWidth = (int)sizeOfInputArea / 10;
  secondRowKeyWidth = (int)sizeOfInputArea / 9;
  thirdRowKeyWidth = (int)sizeOfInputArea / 8;
  keyHeight = firstRowKeyWidth * 12 / 5;
  
  spaceKeyX = width / 2 - sizeOfInputArea / 2;
  spaceKeyY = height / 2 + sizeOfInputArea / 2 - keyHeight / 2;
  spaceKeyHeight = keyHeight / 2;
  spaceKeyWidth = sizeOfInputArea;
  thirdRowXOffset = (sizeOfInputArea - thirdRowKeys.length * thirdRowKeyWidth) / 2;
  thirdRowKeyStartX = width / 2 - sizeOfInputArea / 2 + thirdRowXOffset;
  thirdRowKeyY = height / 2 + sizeOfInputArea / 2  - (keyHeight + rowMargin) * 1 - spaceKeyHeight;
  secondRowXOffset = (sizeOfInputArea - secondRowKeys.length * secondRowKeyWidth) / 2;
  secondRowKeyStartX = width / 2 - sizeOfInputArea / 2 + secondRowXOffset;
  secondRowKeyY = height / 2 + sizeOfInputArea / 2  - (keyHeight + rowMargin) * 2 - spaceKeyHeight;
  firstRowXOffset = (sizeOfInputArea - firstRowKeys.length * firstRowKeyWidth) / 2;
  firstRowKeyStartX = width / 2 - sizeOfInputArea / 2 + firstRowXOffset;
  firstRowKeyY = height / 2 + sizeOfInputArea / 2  - (keyHeight + rowMargin) * 3 - spaceKeyHeight;
  keyTextYOffset = 5; 
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
  //draw space bar
  rect(spaceKeyX, spaceKeyY, spaceKeyWidth, keyHeight / 2);
  fill(0);
  text("_", spaceKeyX + spaceKeyWidth / 2, spaceKeyY + keyHeight / 4 + keyTextYOffset);
  
  //draw three rows of letters
  drawKeysForRow(firstRowKeys, firstRowKeyWidth, firstRowKeyY);
  drawKeysForRow(secondRowKeys, secondRowKeyWidth, secondRowKeyY);
  drawKeysForRow(thirdRowKeys, thirdRowKeyWidth, thirdRowKeyY);
  
  
  //draw top display area
  fill(80);
  rect(width / 2 - sizeOfInputArea / 2, height / 2 - sizeOfInputArea / 2, sizeOfInputArea, firstRowKeyY - (height / 2 - sizeOfInputArea / 2));
  
  noStroke();
}

String keyForClickPos() {
  String key = "";
  float startX = width / 2 - sizeOfInputArea / 2;
  
  //first row "q" and "p" edge area
  
  //"q" edge area
  if (didMouseClick(startX, firstRowKeyY, firstRowXOffset + 1, keyHeight)) {
    key = firstRowKeys[0];
  }
  
  //"p" edge area
  else if (didMouseClick(firstRowKeyStartX + firstRowKeys.length * firstRowKeyWidth, firstRowKeyY + 1, firstRowXOffset, keyHeight)) {
    key = firstRowKeys[firstRowKeys.length - 1];
  }
  
  //first row regular area
  else if (didMouseClick(firstRowKeyStartX, firstRowKeyY, firstRowKeys.length * firstRowKeyWidth, keyHeight)) {
    int keyNum = int(mouseX - firstRowKeyStartX) / firstRowKeyWidth;
    if (keyNum >= 0 && keyNum < firstRowKeys.length) {
      key = firstRowKeys[keyNum];
    }
  }
  
  //second row "a" and "l" edge area
  
  //"a" edge area
  else if (didMouseClick(startX, secondRowKeyY, secondRowXOffset + 1, keyHeight)) {
    key = secondRowKeys[0];
  }
  
  //"l" edge area
  else if (didMouseClick(secondRowKeyStartX + secondRowKeys.length * secondRowKeyWidth - 1, secondRowKeyY, secondRowXOffset, keyHeight)) {
    key = secondRowKeys[secondRowKeys.length - 1];
  }
  
  //second row regular area
  else if (didMouseClick(secondRowKeyStartX, secondRowKeyY, secondRowKeys.length * secondRowKeyWidth, keyHeight)) {
    int keyNum = int(mouseX - secondRowKeyStartX) / secondRowKeyWidth;
    if (keyNum >= 0 && keyNum < secondRowKeys.length) {
      key = secondRowKeys[keyNum];
    }
  }
  
  //third row "z" and "<-" edge area
  
  //"z" edge area
  else if (didMouseClick(startX, thirdRowKeyY, thirdRowXOffset + 1, keyHeight)) {
    key = thirdRowKeys[0];
  }
  
  //"l" edge area
  else if (didMouseClick(thirdRowKeyStartX + thirdRowKeys.length * thirdRowKeyWidth, thirdRowKeyY, thirdRowXOffset + 1, keyHeight)) {
    key = thirdRowKeys[thirdRowKeys.length - 1];
  }
  
  //third row regular area
  else if (didMouseClick(thirdRowKeyStartX, thirdRowKeyY, thirdRowKeys.length * thirdRowKeyWidth, keyHeight)) {
    int keyNum = int(mouseX - thirdRowKeyStartX) / thirdRowKeyWidth;
    if (keyNum >= 0 && keyNum < thirdRowKeys.length) {
      key = thirdRowKeys[keyNum];
    }
  }
  
  else if (didMouseClick(spaceKeyX, spaceKeyY, sizeOfInputArea, keyHeight / 2)) {
    key = "_";
  } 
  
  return key;
}

void drawKeysForRow(String[] keys, float keyWidth, float rowKeyY) {
  int numOfKeys = keys.length;
  float rowXOffset = (sizeOfInputArea - numOfKeys * keyWidth) / 2;
  float rowKeyStartX = width / 2 - sizeOfInputArea / 2 + rowXOffset;
  for (int i = 0; i < numOfKeys; i++) {
    if (i == 0) {
      float rowKeyX = width / 2 - sizeOfInputArea / 2;
      fill(230);
      rect(rowKeyX, rowKeyY, keyWidth + rowXOffset, keyHeight);
      fill(0);
      text(keys[i], rowKeyX + (keyWidth + rowXOffset) / 2, rowKeyY + keyHeight / 2 + keyTextYOffset);
    }
    else if (i == numOfKeys - 1) {
      float rowKeyX = rowKeyStartX + i * keyWidth;
      fill(230);
      rect(rowKeyX, rowKeyY, keyWidth + rowXOffset, keyHeight);
      fill(0);
      text(keys[i], rowKeyX + (keyWidth + rowXOffset) / 2, rowKeyY + keyHeight / 2 + keyTextYOffset);
    }
    else {
      float rowKeyX = rowKeyStartX + i * keyWidth;
      fill(230);
      rect(rowKeyX, rowKeyY, keyWidth, keyHeight);
      fill(0);
      text(keys[i], rowKeyX + keyWidth / 2, rowKeyY + keyHeight / 2 + keyTextYOffset);
    }
    
  }
}

void drawExpandedKey(String[] keys, float keyWidth, float rowKeyY, int i)
{
  int numOfKeys = keys.length;
  float rowXOffset = (sizeOfInputArea - numOfKeys * keyWidth) / 2;
  float rowKeyStartX = width / 2 - sizeOfInputArea / 2 + rowXOffset;
  if (i == 0) {
    float rowKeyX = width / 2 - sizeOfInputArea / 2;
    fill(255);
    rect(rowKeyX, rowKeyY - 5, keyWidth + rowXOffset + 10, keyHeight + 10);
    fill(0);
    text(keys[i], rowKeyX + (keyWidth + rowXOffset) / 2, rowKeyY + keyHeight / 2 + keyTextYOffset);
  }
  else if (i == numOfKeys - 1) {
    float rowKeyX = rowKeyStartX + i * keyWidth;
    fill(255);
    rect(rowKeyX - 10, rowKeyY - 5, keyWidth + rowXOffset + 10, keyHeight + 10);
    fill(0);
    text(keys[i], rowKeyX + (keyWidth + rowXOffset) / 2, rowKeyY + keyHeight / 2 + keyTextYOffset);
  }
  else {
    float rowKeyX = rowKeyStartX + i * keyWidth;
    fill(255);
    rect(rowKeyX - 5, rowKeyY - 5, keyWidth + 10, keyHeight + 10);
    fill(0);
    text(keys[i], rowKeyX + keyWidth / 2, rowKeyY + keyHeight / 2 + keyTextYOffset);
  }
    
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
