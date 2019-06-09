void svgClean(float w, float h) {  //removes automatically generated rectangle from SVG file
  String[] svg = loadStrings("../" + outputFilename + ".svg"); //loads svg file that has just been generated as a string[]
  svg[6] = "  >";
  svg[7] = "";
  svg[8] = "";
  if (mode == 1) {
    svg[9] = "<g style=\"stroke-linecap:round; stroke-width:0.01;\" transform=\"translate(" + (w*dpi/2) + "," + (h*dpi/2) + ")\"";
  } else {
    svg[9] = "<g style=\"stroke-linecap:round; stroke-width:0.01;\" transform=\"translate(" + "0" + "," + "0" + ")\"";
  }
  saveStrings(outputFilename+ ".svg", svg); //save the altered svg file
}

void estimateLength() {  //calculates maximum audio length at current settings
  float maxDuration = floor((60.0 * (grooveDiameter - minDiam) / (2 * (grooveWidth + kerf)/dpi * rpm)) - (2*float(leader)));  //max duration in seconds at current settings
  println("maximum length @ current settings: " + floor(maxDuration/60.0) + "min " + floor(maxDuration%60) + "sec");
}

void printSettings(int selection) {  //(phonograph" or empty) generate text file or vector text to be included in SVG or just a text file of settings
  if (selection == 1) {
    pg.pushMatrix();
    pg.translate(15, -18);

    pg.textFont(font);
    pg.textSize(6);
    pg.fill(0, 0, 255);
    pg.text(fileName, 0, 0);
    pg.textFont(smallfont);
    pg.textSize(4);
    pg.text("duration: " + floor(file.duration()/60) + "m" + floor(file.duration()%60) + "s", 0, 5);
    pg.text("rpm: " + float(floor(rpm*1000.0))/1000.0, 0, 10);
    if (limit) {
      pg.text("sample rate: " + outputSampleRate + " (current selection limits quality)", 0, 15);
    } else { 
      pg.text("sample rate: " + outputSampleRate, 0, 15);
    }
    String[] tempFreq = loadStrings("ftemp.txt");
    pg.text("lowpass filter cutoff: " + tempFreq[0] + " >> " + tempFreq[1], 0, 20);
    pg.text("laser settings (speed/power/freq): " + laserSettings, 0, 25);
    pg.text("groove deflection max: " + grooveWidth/dpi + "in", 0, 30);
    pg.text("approx. bit depth: " + log(grooveWidth*outputDPI/dpi) / log(2), 0, 35);
    pg.text("kerf: " + kerf/dpi + "in", 0, 40);
    pg.text("diameter: " + size[0], 0, 45);
    pg.text("leader/runout: " + leader + "s", 0, 50);
    pg.noFill();
    pg.popMatrix();
    String[] settings = {"filter cutoff: " + freq[0] + ">>" + freq[1], "groove deflection max: " + grooveWidth/dpi + "in", "approx. bit depth: " + log(grooveWidth*outputDPI/dpi) / log(2), "kerf: " + kerf/dpi + "in", "diameter: " + size[0], "leader/runout: " + leader + "s"};
    saveStrings("settings.txt", settings); //export temporary file of selected settings
  } else if (mode == 2) {
    String[] settings = {"filter cutoff: " + freq[0], "deflection max: " + grooveWidth/dpi + "in", "≈ bit depth: " + log(grooveWidth*outputDPI/dpi) / log(2), "kerf: " + kerf/dpi + "in", "size: " + size[0] + "X" + size[1]};
    saveStrings("settings.txt", settings); //export temporary file of selected settings
  } else { //this one needs to change for variable area and density XXXX
    String[] settings = {"filter cutoff: " + freq[0], "deflection max: " + grooveWidth/dpi + "in", "≈ bit depth: " + log(grooveWidth*outputDPI/dpi) / log(2), "kerf: " + kerf/dpi + "in", "size: " + size[0] + "X" + size[1]};
    saveStrings("settings.txt", settings); //export temporary file of selected settings
  }
}
