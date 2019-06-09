//special thanks to Amanda Ghassaei  http://www.amandaghassaei.com/projects/laser_cut_record/ for the inspiration to build this!!!!
//note, this code may cause crashing on less powerful laser cutters (such as epilog mini)


int mode = 1;
//modes:
//1 >> phonograph
//2 >> linear waveform
//3 >> variable area
//4 >> variable density
//5 >> PCM text

//output file name (will go into processing sketch folder)
String outputFilename = "test";

float size[] = {6, 6};  //width & height of output file (diameter for phonograph)
float minDiam = 6;  //set minimum inner diameter for phonograph record (if record player has autostop function this will probably be 5 inches at minimum)


boolean recordFilter = true;  //apply low pass filter to input audio file?

boolean normalize = true; // normalize audio?

String fileName = "voice.wav";
//String fileName = "InventioninC-major20s.wav";
//String fileName = "excerpt.wav";  //input audio filename (place file in your data folder)
//String fileName = "groove.mp3";
//String fileName = "plantasia20s.aiff"
//String fileName = "Channel_Chasing.mp3";
//String fileName = "Bruce-Nauman_14-Left-or-Standing-_-Standing-or-Left-Standing.mp3";

boolean limit = false; //  allow the following setting to limit sample rate beyond the physical constraints of laser cutter for phonograph record (not advised)
float outputSampleRate = 4410;    //sample rate of output file
//lowering sample rate results in lower quality but smaller file size and faster cutting
//works best as factor of original samplerate (listed below for 44.1 kHz)
//1  x  44100
//2  ×  22050
//3  ×  14700
//4  ×  11025
//5  ×  8820
//6  ×  7350
//7  ×  6300
//9  ×  4900
//10  ×  4410
//12  ×  3675         
//14  ×  3150         
//15  ×  2940         
//18  ×  2450         
//20  ×  2205         
//21  ×  2100         
//25  ×  1764         
//28  ×  1575         
//30  ×  1470         
//35  ×  1260         
//36  ×  1225         
//42  ×  1050

String laserSettings = "20s10p100f";
//laser settings will differ between machines, materials, and the time that you can spend cutting
//ideally, you want the lowest power and speed you can muster (9s4p100f is a good place to start, but 20s10p100f can work if time is limited)
//to test, resize calibration.ai (included) and use color mapping (in laser cutter software) to test various power, speed, and frequency settings (remove inner rings if cutting very small)
//use known good settings for the cut lines (black stroke) can can cut through your material completely

//set this variable to the stroke weight that your laser cutter uses for vector cutting
float hairline = .01;

//lasercutter/printer variables
float kerf = .008 * dpi; // width of laser beam burn (in inches) [ideally between .005 & .008 for 600 dpi laser cutter] (15s/5p, 10s,2p)
float outputDPI = 600; //dpi of lasercutter/printer

//add another variable here to control bitdepth/duration limits
float grooveWidth = .035 * dpi; //initialize variable for groove width (in inches) changes bit depth and recording length maximum for phonograph(.02-.035 is a good starting range)
float runoutGroove = grooveWidth * 2; //set runout groove spiral spacing to twice that of the regular groove

float grooveDiameter = size[0] - 0.125; //greatest diameter of groove (move to systemvars?)
//float rpm = 100.0/3.0; //playback rpm
float rpm = 33; //playback rpm
int leader = 1; //leader & runout length (in seconds)
