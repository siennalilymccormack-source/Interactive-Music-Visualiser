import processing.sound.*;

SoundFile song;                   // the loaded music file
Amplitude amp;                    // measures overall loudness (0.0 to 1.0)
FFT fft;                         // splits the sound into frequency bands
int bands = 64;
float[] spectrum = new float[bands];
float[] smoothed = new float[bands];      
float smoothAmp = 0;

void setup() {
  size(800, 600);
  colorMode(HSB, 360, 100, 100, 100);                     // hue, saturation, brightness, alpha
  song = new SoundFile(this, "song3.mp3");               // Adding the song file into code
  song.loop();                                          // start playing and repeat
  amp = new Amplitude(this);                    
  amp.input(song);                                      // tell the analysers which sound to listen to
  fft = new FFT(this, bands);
  fft.input(song);
}

float hueShift = 0;

void draw() {
  // Semi-transparent background makes motion leave soft trails (what I want to be seen)
  background(0);
  float level = amp.analyze();       // overall loudness
  smoothAmp = lerp(smoothAmp, level, 0.15);       //(lerp = smooth transition)
  fft.analyze(spectrum);
  for (int i = 0; i < bands; i++) {                  
    smoothed[i] = lerp(smoothed[i], spectrum[i], 0.2);
  }
  
    float sensitivity = map(mouseY, 0, height, 1400, 200);   // mouse up = more reaction
  float mouseHue = map(mouseX, 0, width, 0, 360);         // mouse left/right = colour
  hueShift += 0.3;                                         // colours slowly rotate

  translate(width/2, height/2);
  float baseRadius = 90 + smoothAmp * 300;

  strokeWeight(4);
  for (int i = 0; i < bands; i++) {
    float angle = map(i, 0, bands, 0, TWO_PI);         // spread around the circle
    float len = smoothed[i] * sensitivity;                // louder band = longer bar  
    len = constrain(len, 2, 220);                          // keep it on screen
    stroke((mouseHue + hueShift + i * 4) % 360, 80, 100);                 
    line(cos(angle) * baseRadius, sin(angle) * baseRadius,
         cos(angle) * (baseRadius + len), sin(angle) * (baseRadius + len));
  }

  noStroke();
  fill((mouseHue + hueShift) % 360, 60, 100);                                
  ellipse(0, 0, baseRadius * 1.2, baseRadius * 1.2);         
}

void mousePressed() {                      // When circle is pressed, the song pauses
  if (song.isPlaying()) {
    song.pause();
  } else {
    song.play();
  }
}
