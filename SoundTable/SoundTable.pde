import ddf.minim.*;
import ddf.minim.ugens.*;

int lastPosX = 0;
int lastPosY = 0;

PFont mainFont;
PFont smallFont;

Minim minim;
AudioOutput[] out = new AudioOutput[5];
Oscil[] wave = new Oscil[5];
Wavetable[] waveType = new Wavetable[5];

int[] drawPosX = new int[500];
int[] drawPosY = new int[500];
int drawPoints = 0;

int drawSize = 50;

PImage tableTop;


int drawColor = 0;

boolean playingSound = true;
boolean playingMode = true;

boolean isDrawing = false;
int drawingShape = 0;
int shapeProg = 0;
int drawStartX = 0;
int drawStartY = 0;
int drawNextX = 0;
int drawNextY = 0;

int[] scanHit = new int[5];
int[] scanHits = new int[5];
int[] scanLast = new int[5];

int widthAdj = 125;

boolean[] sliding = new boolean[2];
int[] sliderPos = new int[2];
int sliderWidth = 20;

float scanPos = 0;
float scanSpeed = 3;

void setup(){
  
  sliderPos[0] = 875;
  sliderPos[1] = 800-sliderWidth/2;
  
  scanSpeed = (sliderPos[0]-(750+sliderWidth/2))/10;
  widthAdj = floor((sliderPos[1]-(750+sliderWidth/2))/10);
  
  size(1000,750);
  tableTop = createImage(998, 498, ARGB);
  for(int i = 0; i < tableTop.pixels.length; i++){
    tableTop.pixels[i] = color(0); 
  }
  
  mainFont = loadFont("ArialNarrow-42.vlw");
  smallFont = loadFont("ArialNarrow-16.vlw");
  
  minim = new Minim(this);
  
  waveType[0] = Waves.SINE;
  waveType[1] = Waves.TRIANGLE;
  waveType[2] = Waves.SAW;
  waveType[3] = Waves.SQUARE;
  waveType[4] = Waves.QUARTERPULSE;
  
  for(int i = 0; i < 5; i++){
    out[i] = minim.getLineOut();
    wave[i] = new Oscil( 0, 0f, waveType[i] );
    wave[i].patch( out[i] );
  }
  
  //orangeMinim = new Minim(this);
  //out[1] = minim.getLineOut();
  //wave[1] = new Oscil( 440, 0.5f, Waves.TRIANGLE );
  //wave[1].patch( out[1] );
}

void draw(){
  //background(0);
  
  
  
  image(tableTop,1,1);
  
  stroke(0);
  noFill();
  line(0,499,1000,499);
  
  stroke(255);
  if(drawingShape == 3){
    ellipse(mouseX,mouseY,drawSize*2,drawSize*2);
  }
  if(drawingShape == 4){
    rect(mouseX,mouseY,drawSize*2,drawSize*2);
  }
  
  int tempSlider = -1;
  if(sliding[0]){tempSlider=0;}
  if(sliding[1]){tempSlider=1;}

  if(tempSlider >= 0){
    sliderPos[tempSlider] = mouseX;
    if(sliderPos[tempSlider] < 750+sliderWidth/2){
      sliderPos[tempSlider] = 750+sliderWidth/2;
    }
    if(sliderPos[tempSlider] > 1000-sliderWidth/2){
      sliderPos[tempSlider] = 1000-sliderWidth/2;
    }
    
    if(tempSlider==0){
      scanSpeed = (sliderPos[0]-(750+sliderWidth/2))/10;//(250-sliderWidth)*25;
    }
    if(tempSlider==1){
      widthAdj = floor((sliderPos[1]-(750+sliderWidth/2))/10)+1;//(250-sliderWidth)*25+1);
    }
  }


  if(playingSound){

    scanPos += scanSpeed;
  
    if(scanPos >= 998){
      scanPos = 0;
    }
    
    for(int i = 0; i < 5; i++){
      scanHit[i] = 0;
      scanHits[i] = 0;
      scanLast[i] = 0;
      for(int j = 0; j < 498; j++){
        
        if(tableTop.pixels[floor(scanPos) + j*998] == setColor(i)){
          if(scanHit[i] == 0){
            scanHit[i] = j;
          }
          scanLast[i] = j;
          scanHits[i]++;
        }
      }
      
      if(widthAdj > 1){
        scanHits[i] *= widthAdj;
      }
      
      if(scanHits[i] > 498){scanHits[i] = 498;}
  
      if(scanHit[i] == 0 && scanLast[i] == 0){
        scanHit[i] = 498;
        scanLast[i] = 498;
      }
  
      float amp = 0;
      float freq = 0;
      
      if(playingMode){
        amp = map( scanHits[i], 0, 498, 0, 1 );
        freq = map( 500-(scanHit[i]+scanLast[i])/2, 0, 500, 110, 880 );
      } else {
        amp = map( 500-(scanHit[i]+scanLast[i])/2, 0, 500, 0, 1 );
        freq = map( 500-scanHits[i], 0, 498, 110, 880 );
      }
      
      wave[i].setAmplitude( amp );
      wave[i].setFrequency( freq );
  
    }
  
  
  
  
  }

  stroke(255);
  strokeWeight(5);
  line(scanPos,0,scanPos,500);
  strokeWeight(1);

  noStroke();
  rectMode(CENTER);
  ellipseMode(CENTER);
  
  if(isDrawing){
    fill(setColor(drawColor));
    switch(drawingShape){
      case 0:
        rect((drawStartX+mouseX)/2, (drawStartY+mouseY)/2, abs(drawStartX-mouseX), abs(drawStartY-mouseY));
        break;
      case 1:
        ellipse(drawStartX, drawStartY, abs(drawStartX-mouseX)*2, abs(drawStartY-mouseY)*2);
        break;
      case 2:
        noFill();
        strokeWeight(3);
        stroke(setColor(drawColor));
        
        beginShape();
        for(int i = 0; i < drawPoints; i++){
          vertex(drawPosX[i],drawPosY[i]);
        }
        vertex(mouseX,mouseY);
        endShape();
        
        strokeWeight(1);
        noStroke();
        break;
      case 3:
        drawOnScreen();
        break;
      case 4:
        eraseScreen();
        break;
    }
  }

  fill(setColor(0));
  rect(375,525,750,50);

  fill(setColor(1));
  rect(375,575,750,50);

  fill(setColor(2));
  rect(375,625,750,50);

  fill(setColor(3));
  rect(375,675,750,50);

  fill(setColor(4));
  rect(375,725,750,50);

  fill(0);
  rect(875,625,250,250);

  fill(120);
  noStroke();
  for(int i = 0; i < 2; i++){
    
    rect(sliderPos[i],625+50*i,sliderWidth,50);  
  }
  fill(255);

  stroke(255);

  line(0,0,1000,0);
  line(0,0,0,750);
  line(1000-1,0,1000-1,750);
  line(0,750-1,1000,750-1);

  line(0,500,1000,500);
  line(0,550,1000,550);
  line(0,600,1000,600);
  line(0,650,1000,650);
  line(0,700,1000,700);

  line(250,500,250,750);
  line(750,500,750,750);

  line(800,700,800,750);
  line(850,700,850,750);
  line(900,700,900,750);
  line(950,700,950,750);
  
  noFill();
  stroke(100,100,255);
  
  rect(775+50*drawingShape,725-.5,50,50-1);
  
  rect(125,525+50*drawColor,250,50);
  
  if(drawColor == 4){
    line(0,749,250,749);
  }
  
  if(drawingShape == 4){
    line(999,725,999,750);
  }
  
  //rectangle(775+50*drawingShape,725,50,50);
  
  stroke(255);
  strokeWeight(3);
  
  rect(775,725,25,25);

  ellipse(825,725,25,25);
  
  //triangle(862.5,737.5,875,712.5,887.5, 737.5);
  
  line(862.5,762.5-50,875,762.5-50);
  line(875,762.5-50,887.5,775-50);
  line(887.5,775-50,887.5,787.5-50);
  line(887.5,787.5-50,862.5,781.25-50);
  line(862.5,781.25-50,862.5,762.5-50);
  
  //ellipse(915.625,725,18.75,18.75);
  //ellipse(934.375,725,18.75,18.75);
  arc(915.625, 725, 18.75,18.75, .13, PI-.1, OPEN);
  arc(934.375, 725, 18.75,18.75, PI+.13, PI*2-.1, OPEN);
  
  noStroke();
  fill(255);
  ellipse(943.75,725,3,3);
  ellipse(925,725,3,3);
  ellipse(906.25,725,3,3);
  noFill();
  stroke(255);
  
  textAlign(CENTER,CENTER);
  
  fill(255);
  textFont(smallFont);
  text("Erase",975,725);
  
  textFont(mainFont);
  
  
  
  text("Sine",125,525);
  text("Triangle",125,575);
  text("Saw",125,625);
  text("Square",125,675);
  text("Quarter Pulse",125,725);
  
  if(playingSound){
    text("Stop",875,525);
  } else {
    text("Start",875,525);
  }
  
  if(playingMode){
    text("Height Mode",875,575);
  } else {
    text("Length Mode",875,575);
  }
  
  text("Speed - "+round(scanSpeed),875,625);
  text("Boost - "+(widthAdj-1),875,675);
  
  stroke(255);
  
  strokeWeight(1);
  
  /*
  rect(375,525,750,50);

  fill(255,128,0);
  rect(375,575,750,50);

  fill(255,255,0);
  rect(375,625,750,50);

  fill(0,255,0);
  rect(375,675,750,50);

  fill(0,0,255);
  rect(375,725,750,50);

  fill(0);
  rect(875,625,250,250);
  */
  
  for(int j = 0; j < 5; j++){
    for(int i = 251; i < min(out[j].bufferSize() - 1,750); i++){
      line( i, 525+50*j  - out[j].left.get(i)*25,  i+1, 525+50*j  - out[j].left.get(i+1)*25);
    }
  }
  
  lastPosX = mouseX;
  lastPosY = mouseY;
  
 }

void mousePressed(){
  int clickedPart = -1;
  if(mouseY<=500){
    clickedPart = 0;
  } else {
    clickedPart = floor((mouseY-500)/ 50)+1;
    if(mouseX>750){
      clickedPart += 5;
      if(clickedPart == 10){
        if(floor((mouseX-750)/50)<=4){
          drawingShape = floor((mouseX-750)/50);
        }
        
      }
    }
  }
  
  if(clickedPart > 0 && clickedPart < 6){
    drawColor = clickedPart-1;
  }
  
  switch(clickedPart){
    case 0:
      if(isDrawing){
        if(drawingShape == 2){
          if(abs(mouseX-drawPosX[0])<15 && abs(mouseY-drawPosY[0])<15){
            endShapes();
          } else {
            drawPosX[drawPoints] = mouseX;
            drawPosY[drawPoints] = mouseY;
            drawPoints++;
          }
        }
      } else {
        isDrawing = true;
        drawStartX = mouseX;
        drawStartY = mouseY;
        if(drawingShape == 2){
          drawPosX[drawPoints] = mouseX;
          drawPosY[drawPoints] = mouseY;
          drawPoints++;
        }
      }
      
      break;
    case 6:
      if(playingSound){
        playingSound = false;
        for(int i = 0; i < 5; i++){
          wave[i].setAmplitude( 0 );
          wave[i].setFrequency( 0 );
        }
      } else {
        playingSound = true;
        /*
        for(int i = 0; i < 5; i++){
          
          float amp;
          float freq;
          
          if(playingMode){
            amp = map( scanHits[i], 0, 498, 0, 1 );
            freq = map( 500-(scanHit[i]+scanLast[i])/2, 0, 500, 110, 880 );
          } else {
            amp = map( 500-(scanHit[i]+scanLast[i])/2, 0, 500, 0, 1 );
            freq = map( scanHits[i], 0, 498, 110, 880 );
          }
          
          
          wave[i].setAmplitude( amp );
          wave[i].setFrequency( freq );
        }
        */
      }
      break;
    case 7:
      if(playingMode){
        playingMode = false;
      } else {
        playingMode = true;
      }
      break;
    case 8:
      sliding[0] = true;
      break;
    case 9:
      sliding[1] = true;
      break;
  }
  
  
  
  
  
  
}


void mouseReleased(){
  sliding[0] = false;
  sliding[1] = false;
  if(isDrawing && drawingShape < 2){
    endShapes();
  }
  if(drawingShape == 3 || drawingShape == 4){
    isDrawing = false;
  }
}



color setColor(int tempColor){
  color myReturn = color(255);
  switch(tempColor){
    case 0:
      myReturn = color(255,0,0);
      break;
    case 1:
      myReturn = color(255,128,0);
      break;
    case 2:
      myReturn = color(200,200,0);
      break;
    case 3:
      myReturn = color(0,255,0);
      break;
    case 4:
      myReturn = color(0,0,255);
      break;
  }
  return(myReturn);
}


boolean endShapes(){
  image(tableTop,1,1);
  noStroke();
  fill(setColor(drawColor));
  switch(drawingShape){
    case 0:
      rect((drawStartX+mouseX)/2, (drawStartY+mouseY)/2, abs(drawStartX-mouseX), abs(drawStartY-mouseY));
      break;
    case 1:
      ellipse(drawStartX, drawStartY, abs(drawStartX-mouseX)*2, abs(drawStartY-mouseY)*2);
      break;
    case 2:
      
      beginShape();
      for(int i = 0; i < drawPoints; i++){
        vertex(drawPosX[i],drawPosY[i]);
      }
      vertex(mouseX,mouseY);
      endShape(CLOSE);
      drawPoints = 0;
      
      break;
  }
  
  stroke(255);
  noFill();
  line(0,0,1000,0);
  line(0,0,0,499);
  line(1000-1,0,1000-1,750);
  line(0,750-1,1000,750-1);
  tableTop = get(1,1,998,498);
  strokeWeight(5);
  line(scanPos,0,scanPos,500);
  strokeWeight(1);
  isDrawing = false;
  
  return true;
}

boolean clearScreen(){
  image(tableTop,1,1);
  noStroke();
  fill(0);
  
  rect(500, 250, 998, 498);
  
  stroke(255);
  noFill();
  line(0,0,1000,0);
  line(0,0,0,750);
  line(1000-1,0,1000-1,750);
  line(0,750-1,1000,750-1);
  tableTop = get(1,1,998,498);
  strokeWeight(5);
  line(scanPos,0,scanPos,500);
  strokeWeight(1);
  
  return true;
}

boolean eraseScreen(){
  image(tableTop,1,1);
  noStroke();
  fill(0);
  
  rect(mouseX, mouseY, drawSize*2, drawSize*2);
  
  stroke(255);
  noFill();  
  line(0,0,1000,0);
  line(0,0,0,750);
  line(1000-1,0,1000-1,750);
  line(0,750-1,1000,750-1);
  
  tableTop = get(1,1,998,498);
  rect(mouseX,mouseY,drawSize*2,drawSize*2);
  strokeWeight(5);
  line(scanPos,0,scanPos,500);
  strokeWeight(1);
  
  return true;
}

boolean drawOnScreen(){
  image(tableTop,1,1);
  noStroke();
  fill(setColor(drawColor));
  
  //ellipse(mouseX, mouseY, drawSize*2, drawSize*2);
  
  stroke(setColor(drawColor));
  strokeWeight(drawSize*2);
  
  line(lastPosX,lastPosY,mouseX,mouseY);
  
  strokeWeight(1);
  
  stroke(255);
  noFill();  
  line(0,0,1000,0);
  line(0,0,0,750);
  line(1000-1,0,1000-1,750);
  line(0,750-1,1000,750-1);
  
  tableTop = get(1,1,998,498);
  ellipse(mouseX,mouseY,drawSize*2,drawSize*2);
  strokeWeight(5);
  line(scanPos,0,scanPos,500);
  strokeWeight(1);
  
  return true;
}

void mouseWheel(MouseEvent event) {
  drawSize += event.getCount();
  if (drawSize <= 0)
  {
    drawSize = 0;
  }
}

void keyPressed(){
  if(key == 'c' || key == 'C'){
    clearScreen();
  }
}
