import processing.serial.*;

Serial myPort;
String input = "";
String[] outputLog = new String[20];

void setup() {
  size(600, 400);
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');
  outputLog[0] = "ArduOS UI - Ready";
}

void draw() {
  background(30);
  fill(255);
  textSize(16);
  text("ArduOS Terminal UI", 20, 30);
  textSize(12);
  for (int i = 0; i < outputLog.length; i++) {
    if (outputLog[i] != null) {
      text(outputLog[i], 20, 60 + i * 16);
    }
  }
  fill(255);
  rect(20, height - 40, width - 40, 25);
  fill(0);
  text(input, 25, height - 22);
}

void keyPressed() {
  if (key == ENTER) {
    myPort.println(input);
    log(">> " + input);
    input = "";
  } else if (key == BACKSPACE && input.length() > 0) {
    input = input.substring(0, input.length() - 1);
  } else if (key != CODED) {
    input += key;
  }
}

void serialEvent(Serial p) {
  String inData = p.readStringUntil('\n');
  if (inData != null) {
    log(inData.trim());
  }
}

void log(String msg) {
  for (int i = 0; i < outputLog.length - 1; i++) {
    outputLog[i] = outputLog[i + 1];
  }
  outputLog[outputLog.length - 1] = msg;
}
