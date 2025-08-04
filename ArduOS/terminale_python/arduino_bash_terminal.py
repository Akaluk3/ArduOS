import serial
import threading
import time
import sys
import readline
from colorama import init, Fore, Style

init(autoreset=True)

PORT = "COM3"  # Cambia con la porta del tuo Arduino
BAUD = 9600

ser = serial.Serial(PORT, BAUD, timeout=1)

log_lines = []
history = []
user = "arduino"
host = "ArduOS"
cwd = "~"

nano_mode = False
nano_buffer = []

def log(text, color=Fore.WHITE):
    log_lines.append(color + text)
    if len(log_lines) > 20:
        log_lines.pop(0)
    refresh_screen()

def refresh_screen():
    print("\033c", end="")  # Clear screen

    for line in log_lines:
        print(line)

    if nano_mode:
        print(Fore.CYAN + "\n[ Modalità nano attiva - ESC per uscire ]")
        print('\n'.join(nano_buffer))
    else:
        print(Fore.GREEN + f"{user}@{host}:{cwd}$ ", end="", flush=True)

def read_serial():
    global nano_mode, nano_buffer

    while True:
        try:
            if ser.in_waiting > 0:
                data = ser.readline().decode(errors='ignore').strip()
                if nano_mode:
                    if data == "[Uscito da nano]":
                        nano_mode = False
                        log(data, Fore.CYAN)
                        refresh_screen()
                    else:
                        nano_buffer.append(data)
                else:
                    log(data, Fore.WHITE)
        except Exception as e:
            log(f"Errore lettura seriale: {e}", Fore.RED)

def main():
    global nano_mode, nano_buffer

    threading.Thread(target=read_serial, daemon=True).start()

    refresh_screen()

    while True:
        try:
            if not nano_mode:
                user_input = input()
                history.append(user_input)

                if user_input == "/clear":
                    log_lines.clear()
                    refresh_screen()
                    continue

                if user_input == "/nano":
                    nano_mode = True
                    nano_buffer = []
                    ser.write(b"/nano\n")
                    log(Fore.CYAN + "[Entrato in modalità nano]", Fore.CYAN)
                    continue

                ser.write((user_input + "\n").encode())
                log(Fore.YELLOW + f">> {user_input}", Fore.YELLOW)

            else:
                nano_line = input()
                if nano_line.strip().lower() == "esc":
                    ser.write(bytes([27]))  # ESC
                else:
                    ser.write((nano_line + "\n").encode())

        except KeyboardInterrupt:
            print("\nUscita...")
            break

if __name__ == "__main__":
    try:
        main()
    except serial.SerialException:
        print("Errore: porta seriale non trovata o già in uso.")
        sys.exit(1)
