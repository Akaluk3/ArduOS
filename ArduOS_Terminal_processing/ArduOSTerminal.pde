// Importa la libreria per la comunicazione seriale
import processing.serial.*;

// Dichiarazione delle variabili globali
Serial myPort;
String input = "";
String[] outputLog = new String[20];
String[] ports;

// Stato dell'applicazione e della connessione
boolean terminalReady = false;
boolean bootComplete = false;
boolean portSelectionMode = true; // Inizia in modalità di selezione della porta
String connectionStatus = "Inizializzazione...";
long invioButtonPressTime = 0;
long emptyInputErrorTimer = 0;

// Variabili per l'animazione di avvio del codice utente
String bootMessage = "Avvio di ArduOS...";
int bootIndex = 0;
int bootSpeed = 5;

// Variabile per la modalità fullscreen
boolean isFullScreen = false;

/**
 * Funzione di setup, chiamata una sola volta all'inizio.
 */
void setup() {
  size(800, 600); // Dimensioni della finestra aumentate per una migliore visualizzazione
  surface.setTitle("ArduOS Terminal");

  // Ottiene la lista delle porte seriali disponibili e la salva
  ports = Serial.list();

  // Inizializza il log di output per evitare errori NullPointerException
  for (int i = 0; i < outputLog.length; i++) {
    outputLog[i] = "";
  }

  // Se non ci sono porte disponibili, mostra un messaggio di errore e non avvia il terminale
  if (ports.length == 0) {
    connectionStatus = "Nessuna porta seriale trovata.";
    portSelectionMode = false;
    bootComplete = true;
    terminalReady = false;
    println("Nessuna porta seriale trovata. Riavvia con Arduino collegato.");
  }
}

/**
 * Funzione draw, chiamata a ogni frame.
 */
void draw() {
  background(30);
  fill(255);

  // Se siamo in modalità di selezione della porta, la disegna e si ferma qui
  if (portSelectionMode) {
    drawPortSelector();
    return;
  }

  // Animazione di avvio (dalla versione del codice utente)
  if (!bootComplete) {
    if (frameCount % bootSpeed == 0 && bootIndex < bootMessage.length()) {
      bootIndex++;
    }
    textSize(16);
    text(bootMessage.substring(0, bootIndex), 20, height / 2);

    if (bootIndex >= bootMessage.length()) {
      bootComplete = true;
      if (myPort != null) {
        terminalReady = true;
        log("ArduOS UI - Pronto");
      } else {
        log("ArduOS UI - Non connesso. Riavvia per riprovare.");
      }
    }
    return;
  }

  // Terminale attivo
  textSize(20);
  textAlign(LEFT, TOP);
  text("ArduOS Terminal UI", 20, 30);
  
  // Log di output
  textSize(14);
  int logAreaHeight = height - 120; // Altezza disponibile per il log
  int lineSpacing = 20; // Spaziatura tra le righe
  int maxLinesToShow = logAreaHeight / lineSpacing;
  int startLogIndex = outputLog.length > maxLinesToShow ? outputLog.length - maxLinesToShow : 0;
  for (int i = 0; i < maxLinesToShow; i++) {
    int logIndex = startLogIndex + i;
    if (logIndex < outputLog.length && outputLog[logIndex] != null) {
      text(outputLog[logIndex], 20, 60 + i * lineSpacing);
    }
  }

  // Box di input
  fill(200);
  rect(20, height - 60, width - 150, 30);
  fill(0);
  textSize(16);
  text(input, 25, height - 42);

  // Pulsante Invio
  boolean isMouseOver = mouseX > width - 100 && mouseX < width - 40 &&
                        mouseY > height - 60 && mouseY < height - 30;
  color buttonColor = (isMouseOver ? color(100, 255, 100) : color(0, 255, 0));
  fill(buttonColor);
  noStroke();
  rect(width - 100, height - 60, 60, 30, 5);
  fill(0);
  textAlign(CENTER, CENTER);
  text("INVIO", width - 70, height - 42);

  // Pulsante Fullscreen
  drawFullScreenButton();
}

/**
 * Disegna il pulsante per la modalità a schermo intero.
 */
void drawFullScreenButton() {
  int buttonX = width - 50;
  int buttonY = 10;
  int buttonSize = 25;

  boolean isMouseOver = mouseX > buttonX && mouseX < buttonX + buttonSize &&
                        mouseY > buttonY && mouseY < buttonY + buttonSize;
  
  fill(isMouseOver ? 100 : 70);
  noStroke();
  rect(buttonX, buttonY, buttonSize, buttonSize, 5);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(12);
  text(isFullScreen ? "OFF" : "ON", buttonX + buttonSize / 2, buttonY + buttonSize / 2);
}

/**
 * Funzione per disegnare l'interfaccia di selezione della porta seriale.
 */
void drawPortSelector() {
  background(30);
  textAlign(CENTER, TOP);
  fill(255);
  textSize(24);
  text("Seleziona la porta seriale per ArduOS", width / 2, 40);

  int startY = 100;
  int buttonHeight = 40;
  int buttonWidth = 300;
  int margin = 15;

  for (int i = 0; i < ports.length; i++) {
    int buttonX = (width - buttonWidth) / 2;
    int buttonY = startY + i * (buttonHeight + margin);
    
    // Controlla se il mouse è sopra il pulsante
    boolean isMouseOver = mouseX > buttonX && mouseX < buttonX + buttonWidth &&
                          mouseY > buttonY && mouseY < buttonY + buttonHeight;

    fill(isMouseOver ? 100 : 70); // Colore diverso al passaggio del mouse
    rect(buttonX, buttonY, buttonWidth, buttonHeight, 5);
    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    text(ports[i], buttonX + buttonWidth / 2, buttonY + buttonHeight / 2);
  }
}

/**
 * Funzione per gestire i click del mouse.
 */
void mousePressed() {
  // Se siamo in modalità di selezione porta, gestisce la selezione
  if (portSelectionMode) {
    int startY = 100;
    int buttonHeight = 40;
    int buttonWidth = 300;
    int margin = 15;
    for (int i = 0; i < ports.length; i++) {
      int buttonX = (width - buttonWidth) / 2;
      int buttonY = startY + i * (buttonHeight + margin);
      if (mouseX > buttonX && mouseX < buttonX + buttonWidth &&
          mouseY > buttonY && mouseY < buttonY + buttonHeight) {
        connectToPort(i);
        break; // Esce dal ciclo dopo aver trovato un click valido
      }
    }
  } else {
    // Altrimenti, esegue la logica di invio input o fullscreen se il terminale è pronto
    if (terminalReady) {
      // Click su pulsante Invio
      if (mouseX > width - 100 && mouseX < width - 40 &&
          mouseY > height - 60 && mouseY < height - 30) {
        if (mouseButton == LEFT) {
          if (myPort != null && input.length() > 0) {
            myPort.write(input + "\n");
          }
          log(">> " + input);
          input = "";
        }
      }
      
      // Click su pulsante Fullscreen
      int buttonX = width - 50;
      int buttonY = 10;
      int buttonSize = 25;
      if (mouseX > buttonX && mouseX < buttonX + buttonSize &&
          mouseY > buttonY && mouseY < buttonY + buttonSize) {
        isFullScreen = !isFullScreen;
        if (isFullScreen) {
          fullScreen(); // Chiamata corretta senza argomenti
        } else {
          size(800, 600);
        }
      }
    }
  }
}

/**
 * Tenta di connettersi a una porta specifica.
 */
void connectToPort(int portIndex) {
  try {
    myPort = new Serial(this, ports[portIndex], 9600);
    myPort.bufferUntil('\n');
    connectionStatus = "Connesso a " + ports[portIndex];
    portSelectionMode = false;
    bootComplete = false;
    bootIndex = 0;
    log("Connessione riuscita. Avvio del terminale...");
  } catch (Exception e) {
    println("Errore di connessione a " + ports[portIndex] + ": " + e.getMessage());
    connectionStatus = "Errore di connessione a " + ports[portIndex];
    log(connectionStatus);
    portSelectionMode = true; // Ritorna alla selezione in caso di errore
  }
}

// keyTyped gestisce correttamente caratteri e backspace
void keyTyped() {
  if (!terminalReady) return;

  if (key == '\n' || key == '\r') {
    if (myPort != null && input.length() > 0) {
      myPort.write(input + "\n");
    }
    log(">> " + input);
    input = "";
  } else if (key == BACKSPACE) {
    if (input.length() > 0) {
      input = input.substring(0, input.length() - 1);
    }
  } else if (key >= 32 && key <= 126) { // caratteri stampabili
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
