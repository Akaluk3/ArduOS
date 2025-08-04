#include <Arduino.h>

String userInput = "";
String nanoBuffer = "";
bool nanoMode = false;

#define MAX_DIRS 5
String directories[MAX_DIRS];
int dirCount = 0;

void setup() {
  Serial.begin(9600);
  delay(200);
  bootanimation();
  delay(500);
  kernel();
  delay(200);
  startOS();
}

void loop() {
  handleMessages();
}

void kernel() {
  Serial.println("Kernel initialized");
}

void startOS() {
  Serial.println("ArduOS started successfully");
  menuCLS();
  menu();
}

void bootanimation() {
  const char* loadingSteps[] = {
    "Verifica kernel...",
    "Avvio Init...",
    "Caricamento driver...",
    "Inizializzazione OS...",
    "Verifica integrità file system...",
    "Avvio UI.exe...",
    "ArduOS avviato"
  };

  for (int i = 0; i < 7; i++) {
    Serial.print("|");
    for (int j = 0; j <= i; j++) Serial.print("=");
    for (int j = i + 1; j < 16; j++) Serial.print(" ");
    Serial.println("|");

    Serial.print("[*] ");
    Serial.println(loadingSteps[i]);
    delay(300 + random(100, 400));
  }

  delay(600);
}

void menuCLS() {
  for (int i = 0; i < 22; i++) Serial.print("\n");
}

void menu() {
  Serial.println("|_________________________________|");
  Serial.println("|==| Terminale ArduOS (linux)  |==|");
  Serial.println("|==|==========================|==|");
  Serial.println("|==| Scrivi un comando (/help) |==|");
  Serial.println("|_________________________________|");
}

void simulateLS() {
  Serial.println("file1.txt  file2.log  readme.md");
  if (dirCount > 0) {
    Serial.print("Directories: ");
    for (int i = 0; i < dirCount; i++) {
      Serial.print(directories[i]);
      if (i < dirCount - 1) Serial.print(", ");
    }
    Serial.println();
  }
}

void simulateCAT(String filename) {
  if (filename == "file1.txt") {
    Serial.println("Contenuto di file1.txt:");
    Serial.println("Ciao da ArduOS!");
  } else if (filename == "file2.log") {
    Serial.println("Log recente:");
    Serial.println("[12:00] Sistema avviato");
  } else if (filename == "readme.md") {
    Serial.println("# Readme ArduOS");
    Serial.println("Sistema operativo minimal per Arduino.");
  } else {
    Serial.println("cat: file non trovato");
  }
}

void handleMessages() {
  if (Serial.available() > 0) {
    char c = Serial.read();

    if (nanoMode) {
      if (c == 27) {
        nanoMode = false;
        Serial.println("\n[Uscito da nano]");
        menu();
        userInput = "";
      } else {
        nanoBuffer += c;
      }
      return;
    }

    if (c == '\n' || c == '\r') {
      userInput.trim();
      if (userInput.length() > 0) {
        if (userInput == "/help") {
          Serial.println("Comandi disponibili:");
          Serial.println("/help   - Mostra questa guida");
          Serial.println("/clear  - Pulisce lo schermo");
          Serial.println("/echo   - Ripete il testo");
          Serial.println("/time   - Millisecondi da avvio");
          Serial.println("/about  - Info sistema");
          Serial.println("/ls     - Lista file e cartelle");
          Serial.println("/cat    - Mostra contenuto file");
          Serial.println("/date   - Data/ora simulata");
          Serial.println("/uname  - Info OS");
          Serial.println("/uptime - Tempo acceso in secondi");
          Serial.println("/nano   - Editor testo (ESC per uscire)");
          Serial.println("/mkdir  - Crea directory");
          Serial.println("/reboot - Riavvia sistema");
        }
        else if (userInput == "/clear") {
          menuCLS();
          delay(200);
          menu();
        }
        else if (userInput.startsWith("/echo ")) {
          Serial.println(userInput.substring(6));
        }
        else if (userInput == "/time") {
          Serial.print("Millisecondi da avvio: ");
          Serial.println(millis());
        }
        else if (userInput == "/about") {
          Serial.println("ArduOS v1.0 - Mini OS demo");
          Serial.println("Creato con <3 da te");
          Serial.println("Arduino Uno specs:");
          Serial.println("  - Microcontrollore: ATmega328P");
          Serial.println("  - Memoria Flash: 32 KB");
          Serial.println("  - SRAM: 2 KB");
          Serial.println("  - EEPROM: 1 KB");
          Serial.println("  - Clock: 16 MHz");
        }
        else if (userInput == "/ls") {
          simulateLS();
        }
        else if (userInput.startsWith("/cat ")) {
          String filename = userInput.substring(5);
          simulateCAT(filename);
        }
        else if (userInput == "/date") {
          Serial.println("Data/Ora simulata: 27-05-2025 12:00");
        }
        else if (userInput == "/uname") {
          Serial.println("ArduOS v1.0 - Kernel Minimal");
        }
        else if (userInput == "/uptime") {
          Serial.print("Uptime (s): ");
          Serial.println(millis() / 1000);
        }
        else if (userInput == "/nano") {
          Serial.println("[Entrato in modalità nano]");
          Serial.println("Scrivi il testo, premi ESC per uscire e salvare.");
          nanoBuffer = "";
          nanoMode = true;
        }
        else if (userInput.startsWith("/mkdir ")) {
          String dirname = userInput.substring(7);
          if (dirCount < MAX_DIRS) {
            directories[dirCount++] = dirname;
            Serial.print("Cartella '");
            Serial.print(dirname);
            Serial.println("' creata.");
          } else {
            Serial.println("Errore: massimo numero di directory raggiunto.");
          }
        }
        else if (userInput == "/reboot") {
          Serial.println("Riavvio sistema...");
          delay(1000);
          asm volatile ("jmp 0");
        }
        else {
          Serial.println("Comando sconosciuto. Scrivi /help");
        }
      }
      userInput = "";
    }
    else {
      userInput += c;
    }
  }
}
