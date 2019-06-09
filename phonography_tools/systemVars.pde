//works! next version will etch settings into middle of record
//next tasks:
//add something to make it ready to print on letter size media for variableDensity and variableArea
//GUI
//live recording function

//libraries needed
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import processing.sound.*;
import processing.svg.*;

Minim minim; //start minim for lowpass filtering

PFont font;
PFont smallfont;


//for filtering
SoundFile timeFile;  //sound library class to establish input length, samplerate, etc
//SoundFile analysisFile; //import of filtered audio for editing/vectorization
Sampler playbackFile;  //for wav or aiff load/play
LowPassFS lowFS;  //declare low pass filter
AudioRecorder recorder;  // for live input
boolean recorded;  //for recording live input (needed to end recording)
boolean hasStarted = false;  //initialization for beginning save filtered playback
boolean hasSaved = false; //initialization for determining if file is ready to save
boolean hasLoaded = false; //initialization for loading soundFile for analysis
int startMillis;  // start time of filtered playback
AudioOutput out;  // for playing back
FilePlayer player;  // playback of filtered audio
int inputFrames; //number of frames in input file
int inputLengthMillis; //length of input file in milliseconds
float maxFilterFreq; //the highest cutoff frequency for the lowpass filter (based on user input or size of phonograph record to be cut)
float minFilterFreq; //the lowest cutoff frequency for the lowpass filter (based on the length & quality of the file which determine the smallest spiral radius of the phonograph groove)

SoundFile file; //create instance of SoundFile class to import filtered audio

// variables needed for calculations (no need to modify)
PGraphics pg; //declaring the PGraphics object for output
int inputSampleRate; //declaring the variable for the sample rate of the file to be loaded (remove?)
float[] inputFrameArray; //array holding values for each sample of the inputted audio
float[] outputFrameArray; //array holding values for each sample of the outputted audio
float maxFrame = 0; // initializing the variable to find the most extreme part of the waveform
String textOutput[]; //initialize array for textfile output option
float dpi = 72.0; //dpi output for processing svg save
String[] freq = new String[2];
