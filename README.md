## MIPS Assembly GOMOKU Game (15x15)

A two-player **Gomoku** (also known as **Caro** or **Five in a Row**) game implemented entirely in **MIPS Assembly**. This project features a 15x15 grid, interactive coordinate-based input, win-condition detection, and file output capabilities.

## Introduction
This project was developed to demonstrate low-level programming concepts using the MIPS instruction set. Players take turns entering coordinates on a large board. The game monitors every move to check for a winner based on traditional Gomoku rules (5 consecutive symbols).

## Game Logic & Features

### 1. Board Representation
* **Dynamic Memory:** The 15x15 board is allocated dynamically in the heap using `syscall 9`.
* **Mapping:** Although the game is 2D, the board is stored as a 1D array of 225 bytes. Coordinates $(x, y)$ are mapped using the formula: `index = (x * 15) + y`.

### 2. Move Validation & Parsing
* **String Processing:** The program reads input as a string (e.g., `"12,5"`) and manually parses the characters to extract integer X and Y coordinates.
* **Error Handling:** Invalid inputs (out of bounds, non-numeric characters, or already occupied cells) trigger an error message and prompt the player to re-enter their move.

### 3. Win Condition Algorithm
After every move, the program executes a `check_win` subroutine that scans four axes:
* **Horizontal:** Checks for 5 consecutive symbols in the current row.
* **Vertical:** Checks for 5 consecutive symbols in the current column.
* **Diagonal (Top-Left to Bottom-Right):** Iterates through the major diagonal.
* **Anti-Diagonal (Top-Right to Bottom-Left):** Iterates through the minor diagonal.

### 4. File Persistence
Upon game completion (Win or Tie), the program:
* Opens `result.txt` using `syscall 13`.
* Exports the final state of the board.
* Appends the final result (e.g., "Player 1 wins").

## How to Run

### Prerequisites
To run this program, you need a MIPS emulator. We recommend:
* **MARS (MIPS Assembler and Runtime Simulator)**
* **QtSpim**

### Execution Steps
1. **Open MARS/QtSpim.**
2. **Load the file:** File -> Open -> `your_filename.asm`.
3. **Assemble:** Click the "Wrench and Hammer" icon (or press `F3`).
4. **Run:** Click the "Play" icon (or press `F5`).

### How to Play
* The game will display a grid of dots (`.`).
* Players will be prompted to enter coordinates in the format: `x,y`.
* **Example:** `7,7` (places a symbol in the center of the board).
* Coordinates range from **0 to 14**.

## 🛠 Technical Details
* **Registers Used:** * `$s0`: Board base address.
    * `$s3`: Move counter (to detect ties).
    * `$s4`: Current player ID.
* **System Calls:** Uses `syscall 4` (print string), `syscall 8` (read string), `syscall 9` (sbrk/memory allocation), and `syscall 13-16` (file I/O).

**Author:** 
Nguyen Hoang Anh - Ho Chi Minh city University of Technology
