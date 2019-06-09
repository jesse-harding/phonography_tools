void filterInput() {
  recorder.beginRecord();  //begin recording filtered audio
  if (recorder.isRecording() && !hasStarted) {  //check to see if recording has begun and playback file has not yet been triggered to play
    playbackFile.trigger();  //begin playback of input audio file
    println("started");  //alert that filtering and recording has begun
    startMillis = millis();  //note time that recording has begun
    hasStarted = true;  //boolean so that file playback is only triggered once
  }
  if (recorder.isRecording() && hasStarted && !hasSaved && mode == 1) {  //check if phonograph option is selected, audio is being recorded, and playback has started
    lowFS.setFreq(maxFilterFreq - ((maxFilterFreq-minFilterFreq) * (float(millis()) - float(startMillis)) / float(inputLengthMillis)));  //dynamically modify freq of filter to match limitations as the spiral radius decreases
    println(int(100 * (millis() - startMillis) / inputLengthMillis) + "%"); //print percentage filter/recording complete
  }
  if (millis() > startMillis + inputLengthMillis && !hasSaved) { //check if audio has played for its full duration and has not yet saved
    recorder.endRecord(); //end recording of output stream
    recorder.save();  //save recorded audio
    println("recorded");  //alert that audio has been saved
    hasSaved = true;  //note that audio has been saved
    recordFilter = false;  //now that input audio has been saved as a temporary file, we will import that filtered file and not filter again
    setup();  //due to the fact that the audio filtering must take place in the draw loop, we now recall the setup() function to do the remaining audio manipulation and graphic export
  }
}


void downSample() {

  inputFrameArray = new float[file.frames()]; //make array to hold samples from input file
  file.read(0, inputFrameArray, 0, file.frames()); // load input file into array
  outputFrameArray = new float[int(floor((outputSampleRate/float(inputSampleRate))*file.frames()))]; // make array to hold samples for output file
  for (int i = 0; i < outputFrameArray.length; i++) {

    //i cant tell which one is better quality ... needs testing

    //rounded downsample
    outputFrameArray[i] = inputFrameArray[round(map(i, 0, outputFrameArray.length, 0, inputFrameArray.length))]; //cant tell which is better

    //interpolated downsample
    //float lerpDownSample = map(i, 0, outputFrameArray.length, 0, inputFrameArray.length); 
    //outputFrameArray[i] = (inputFrameArray[floor(lerpDownSample)] * (lerpDownSample % 1)) + (inputFrameArray[ceil(lerpDownSample)]  * (1 - (lerpDownSample % 1)));
  }
}

void normalizeAudio() { //set the sample with the highest amplitude to 1 or -1 and map all smaller sample to the same scale
  normalize = true;
  for (int i = 0; i < outputFrameArray.length; i++) {
    if (abs(outputFrameArray[i]) > maxFrame) {
      maxFrame = abs(outputFrameArray[i]);
    }
  }
  for (int i = 0; i < outputFrameArray.length; i++) {
    outputFrameArray[i] = outputFrameArray[i] / abs(maxFrame);
  }
}

void leader(int duration) {
  leader = duration;
  float tempArray[] = new float[outputFrameArray.length + (duration * int(outputSampleRate) * 2)];
  for (int e = 0; e < tempArray.length; e++) {
    tempArray[e] = 0;
  }
  for (int i = 0; i < outputFrameArray.length; i++) {
    tempArray[i + duration * int(outputSampleRate)] = outputFrameArray[i];
  }
  outputFrameArray = (float[]) expand(outputFrameArray, tempArray.length);
  arrayCopy(tempArray, outputFrameArray);
}
