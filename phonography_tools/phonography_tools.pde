void setup() { //<>//

  font = createFont("Helvetica-6.vlw", 6);  //load fonts to output settings in final file
  smallfont = createFont("Helvetica-4.vlw", 4);

  size(0, 0); //will change with GUI

  if (mode == 1) {  //if phonograph mode is selected, keep circular dimensions
    size[1] = size[0];
  }

  if (recordFilter) {  //low pass filter to comply with nyquist theorem, given lower sample rate
    minim = new Minim(this);  //make new minim instance
    timeFile = new SoundFile(this, fileName);  //input file for soundlibrary (for time and samplerate etc)
    inputSampleRate = timeFile.sampleRate();  //get input file sample rate
    inputFrames = timeFile.frames();  //get number of samples in input file
    inputLengthMillis = int(timeFile.duration() * 1000);  //get length of input file in milliseconds
    playbackFile = new Sampler(fileName, 1, minim);  //input file for wav or aiff load/play
    out = minim.getLineOut( Minim.MONO );  // get output stream to be recorded for filtering
    recorder = minim.createRecorder(out, "data/temp.wav");  //create recorder instance which will save a temporary file for filtered audio
    TickRate rateControl = new TickRate(1.f);  //control playback rate to avoid errors
    playbackFile.patch(rateControl).patch(out); //patch filtered audio to output stream for recording

    if (mode == 1) {  //cutoff frequency of lowpass filter will be dynamic if making a phonograph due to lower resolution at smaller diameter (based on kerf)
      maxFilterFreq = 2 * ((rpm/60.0) * PI * (grooveDiameter - 2.0*(((grooveWidth + kerf)/dpi) * float(leader) * rpm / 60.0)))/(2.0 * kerf / dpi);   //max frequency at largest diameter
      minFilterFreq = 2 * ((rpm/60.0) * PI * (grooveDiameter - 2.0*(((grooveWidth + kerf)/dpi) * (timeFile.duration() + float(leader)) * rpm / 60.0)))/(2.0 * kerf / dpi); //max frequency at smallest diameter

      if (outputSampleRate /2 <= maxFilterFreq && limit) {  //if user-selected sample rate unnecessarily limits sample rate
        limit = true;
        maxFilterFreq = outputSampleRate / 2.0;
      } else {
        limit = false;
      }
      if ((grooveDiameter - 2.0*(((grooveWidth + kerf)/dpi) * (timeFile.duration() + 2*float(leader)) * rpm / 60.0)) < minDiam) {  //alert if the audio is too long at the current settings 
        println("too long");
        print("inner radius: ");
        print(grooveDiameter - 2.0*(((grooveWidth + kerf)/dpi) * (timeFile.duration() + 2*float(leader)) * rpm / 60.0));
        print(" > ");
        println(minDiam);
        exit();
      }
    } else { //if not phonograph, set filter frequency based on user-input sample rate for nyquist theorem compliance
      maxFilterFreq = outputSampleRate / 2.0;
    }

    freq[0] = str(maxFilterFreq); //highest cutoff for low pass filter
    freq[1] = str(minFilterFreq); //lowest cutoff for low pass filter (for dynamic filter for phonograph option)
    saveStrings("ftemp.txt", freq); //export temporary file of filter settings 

    lowFS = new LowPassFS(maxFilterFreq, inputSampleRate);  // set cutoff frequency of lowpass filter (will remain static unless phonograph option is selected)
    out.addEffect(lowFS);  //add low pass filter to output audio stream for recording and encoding
  } else {  //if audio has already been filtered
    file = new SoundFile(this, "data/temp.wav"); //import filtered audio file
    inputSampleRate = file.sampleRate(); //get sample rate of filtered audio file
    downSample(); //downsample imported audio to match samplerate ... variable ... automate?
    if (normalize) {
      normalizeAudio(); //amplifies audio to full dynamic range w/o clipping
    }
    switch(mode) {
    case 1: 
      phonographSVG("interrupted");  //"continuous" or "interrupted" (must be interrupted for use with Adobe Illustrator)
      break;
    case 2: 
      linearWaveForm();  //saves an SVG file of a linear waveform
      break;
      //case 3: 
      //  variableArea();  //saves an image file of variable area audio (similar to some optical sound for film projection)
      //  break;
      //case 4: 
      //  variableDensity();  //saves an image file of variable density audio (similar to some optical sound for film projection)
      //  break;
    case 5: 
      saveTextFile();  //saves PCM audio to a text file
      break;
    }
  }
}

void draw() {
  if (mode == 1) {
    estimateLength(); //alerts user of maximum audio length given current settings if phonograph option is selected
  }
  if (recordFilter) {  //checks if audio has not yet been filtered
    filterInput();  //applies a low pass filter to input audio to comply with nyquist theorem (dynamic cutoff frequency if phonograph, static for other modes
  }
}

void phonographSVG(String type) { //phonograph

  pg = createGraphics(int(size[0] * dpi), int(size[1] * dpi), SVG, outputFilename + ".svg"); //create the canvas for creating the vector(s)
  pg.noSmooth(); //eliminate automatic pixel smoothing
  pg.beginDraw(); //start generating the svg
  pg.background(255); //set background to white
  pg.stroke(0); //BLACK STROKE FOR CUT STRENGTH
  pg.strokeWeight(hairline); //hairline (for epilog machines, .01pt) to match laser cutter settings (if your cutter wants a different stroke, enter it here).
  pg.noFill(); //set fill to zero
  pg.translate(pg.width/2, pg.height/2); //move coordinate origin to the center of the screen/document
  pg.ellipse(0, 0, size[0] * dpi, size[0] * dpi); //outer cut line
  pg.ellipse(0, 0, .29 * dpi, .29 * dpi); // inner cut for spindle hole (≈9/32")
  pg.stroke(0, 0, 255); //RED STROKE FOR ENGRAVE STRENGTH
  leader(leader); //generate silent buffers at both ends of track

  pg.beginShape();

  for (int i = 0; i < outputFrameArray.length; i++) { //generate spiral groove based on number of samples in the imported audio

    float spiralX = grooveDiameter / 2.0 * dpi; //set outer radius of overall groove area
    float spiralY = grooveDiameter / 2.0 * dpi;

    spiralX -= i / float(outputFrameArray.length) * (grooveWidth + kerf) * (float(outputFrameArray.length) / outputSampleRate * rpm / 60.0); // set overall change of spiral radius
    spiralY -= i / float(outputFrameArray.length) * (grooveWidth + kerf) * (float(outputFrameArray.length) / outputSampleRate * rpm / 60.0);

    if (leader != 0 && i > outputFrameArray.length - (leader * int(outputSampleRate))) { //make spiral runout have double the normal groove width
      spiralX -= ((leader * int(outputSampleRate) - (outputFrameArray.length - 1 - i)) / outputSampleRate) * (rpm / 60.0) * runoutGroove;
      spiralY -= ((leader * int(outputSampleRate) - (outputFrameArray.length - 1 - i)) / outputSampleRate) * (rpm / 60.0) * runoutGroove;
    }

    spiralX += outputFrameArray[i] * grooveWidth / 2; // use audio data to alter spiral radius
    spiralY += outputFrameArray[i] * grooveWidth / 2;

    spiralX *= sin(float(i) * 2.0 * PI * ((float(outputFrameArray.length) / outputSampleRate * rpm / 60.0)) / float(outputFrameArray.length)); // draw the groove
    spiralY *= cos(float(i) * 2.0 * PI * ((float(outputFrameArray.length) / outputSampleRate * rpm / 60.0)) / float(outputFrameArray.length));

    if (i == outputFrameArray.length - (leader * int(outputSampleRate))) {
      if (2.0 * pow(pow(spiralX, 2) + pow(spiralY, 2), .5) < 5) {
        println("too long");
        exit();
      }
    }
    pg.vertex(spiralX, spiralY); //draw the vertices for the path(s) of the radial groove

    if (type == "interrupted") {
      if (i % 30000 == 29999 && i != outputFrameArray.length - 1) { //end old path and start a new one to avoid illustrator limitations
        pg.endShape();
        pg.beginShape();
        pg.vertex(spiralX, spiralY);  //begin the shape at the same point that the previous shape ended
      }
    }

    if (i >= outputFrameArray.length - 1) {
      pg.endShape(); //end the shape if all values of outputFrameArray have been used
      if (leader != 0) { //create runout locked groove to catch stylus after playing the track
        pg.ellipse(0, 0, 2.0 * pow(pow(spiralX, 2) + pow(spiralY, 2), .5), 2.0 * pow(pow(spiralX, 2) + pow(spiralY, 2), .5));
      }
    }
  }
  printSettings(mode);
  pg.dispose();
  pg.endDraw();
  svgClean(size[0], size[1]); //removes automatically generated rectangle from file
  println("saved");
}

void saveTextFile() {
  textOutput = new String[outputFrameArray.length];
  for (int i = 0; i < outputFrameArray.length; i++) {
    textOutput[i] = str(outputFrameArray[i]);
  }
  saveStrings("output.txt", textOutput);
  println("saved");
}

//void variableArea(){ //add curveVertex?
//  pg = createGraphics(outputFrameArray.length, int(bitDepth), SVG, "test.svg");
//  pg.noSmooth();
//  pg.beginDraw();
//  pg.background(0);
//  pg.noStroke();
//  pg.fill(255);
//pg.beginShape(); 
//  for (int i = 0; i < outputFrameArray.length; i++){
//    pg.vertex(i, (bitDepth - map(outputFrameArray[i], -1, 1, 0, bitDepth))/2);
//  }
//   for (int i = outputFrameArray.length-1; i >= 0; i--){
//    pg.vertex(i, (bitDepth - map(outputFrameArray[i], -1, 1, 0, bitDepth))/2 + map(outputFrameArray[i], -1, 1, 0, bitDepth)); 
//  }
//  pg.endShape();
//  pg.dispose();
//  pg.endDraw();
//}

//void variableDensity(){
//  //best possible resolution is 8-bit due to 0-255 density
//  pg = createGraphics(outputFrameArray.length, int(bitDepth), SVG, "test.svg");
//  pg.noSmooth();
//  pg.beginDraw();
//  pg.background(255);
//  pg.strokeWeight(1);
//  pg.noFill();
//  for (int i = 0; i < outputFrameArray.length; i++){
//    pg.stroke(map(outputFrameArray[i],-1,1,0,255));
//    pg.beginShape();
//    pg.vertex(i, 0);
//    pg.vertex(i, pg.height);
//    pg.endShape();
//  }
//  pg.dispose();
//  pg.endDraw();
//}

void linearWaveForm() { //limit to size entered in userInputs? XXXX
  //pg = createGraphics(outputFrameArray.length, int(size[1]*dpi), SVG, "test.svg");
  pg = createGraphics(int(size[0]*dpi), int(size[1]*dpi), SVG, "test.svg");
  pg.noSmooth();
  pg.beginDraw();
  pg.background(255);
  pg.stroke(0);
  pg.strokeWeight(hairline);
  pg.noFill();
  pg.beginShape();
  pg.vertex(0, size[1]*dpi);
  for (int i = 0; i < outputFrameArray.length; i++) {
    pg.vertex((float(i)/float(outputFrameArray.length)) * size[0] * dpi, pg.height/2 + outputFrameArray[i]*grooveWidth);
    if (i == outputFrameArray.length - 1) {
      pg.vertex((float(i)/float(outputFrameArray.length)) * size[0] * dpi, size[1] * dpi);
    }
  }
  pg.vertex(0, size[1]*dpi);
  pg.endShape();
  printSettings(mode);
  pg.dispose();
  pg.endDraw();
  svgClean(size[0], size[1]); //removes automatically generated rectangle from file
  println("saved");
}
