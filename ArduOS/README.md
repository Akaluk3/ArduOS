# ArduOS 🖥️

**ArduOS** è un mini sistema operativo testuale ispirato a Linux, progettato per funzionare su **Arduino Uno**.  
Offre una shell seriale con comandi simili a Linux e due interfacce utente: un terminale Python e un terminale grafico Processing.

---


 
## 🧠 Caratteristiche principali

- Shell seriale con comandi base come:
  - `/ls` — lista file e directory simulati
  - `/cat` — mostra contenuto di file simulati
  - `/mkdir` — crea directory virtuali
  - `/nano` — editor testuale base integrato (ESC per uscire)
  - `/clear` — pulisce lo schermo
  - `/uptime`, `/time`, `/date`, `/uname`, `/help` e altri
- Editor testuale semplice integrato nella shell (modalità nano)
- Terminale Python che simula una shell bash Linux collegandosi via seriale ad Arduino
- Terminale Processing che mostra un'interfaccia grafica seriale

---

## 📦 Requisiti

- **Hardware**: Arduino Uno o compatibile
- **Software**:
  - Arduino IDE (per caricare lo sketch)
  - Python 3.8+ (per il terminale seriale Python)
  - Processing 4+ (per la UI grafica)

---

## 📥 Installazione e uso

### 1. Caricare Arduino

Apri `arduino/arduos.ino` con Arduino IDE, compila e caricalo sulla tua scheda Arduino Uno.

### 2. Terminale Python

Dal terminale, entra nella cartella `terminale_python` e installa le dipendenze:

```bash
pip install -r requirements.txt
```

Avvia il terminale Python:

```bash
python arduino_bash_terminal.py
```

Questo emula un terminale Linux collegato ad ArduOS via seriale.

---

### 3. Terminale Processing (opzionale)

Apri Processing e carica lo sketch:

```
terminale_processing/ArduOSTerminal/ArduOSTerminal.pde
```

Avvia lo sketch per una UI grafica che comunica con Arduino via seriale.

---

## ⚙️ Comandi supportati

- `/help` — mostra la guida
- `/clear` — pulisce lo schermo
- `/echo <testo>` — ripete il testo
- `/time` — millisecondi da avvio Arduino
- `/about` — informazioni sul sistema
- `/ls` — lista file e directory
- `/cat <file>` — mostra contenuto file
- `/date` — data/ora simulata
- `/uname` — info sistema
- `/uptime` — tempo acceso in secondi
- `/nano` — editor testuale
- `/mkdir <nome>` — crea directory
- `/reboot` — riavvia il sistema

---

## 📚 Approfondimenti

ArduOS è un progetto didattico per esplorare la creazione di un sistema operativo minimale su hardware limitato come Arduino Uno, con funzionalità di shell e editor testuale.
siete liberi di modificare e un progetto open source 

---

## 📝 Licenza

MIT License — vedi il file `LICENSE` per dettagli.

---

## 👤 Autore
Akaluk3 
