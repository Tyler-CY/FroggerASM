# Frogger!
Frogger is a 1981 arcade action game developed by Konami and manufactured by Sega. I recreated a simple version of Frogger using MIPS assembly language entirely while capturing the essence of the game.

The objective of the game is to control the frog to their homes by first crossing a road and then a river, in which obstacles try to stop the frog.

See the Instructions session for rules and learn how to play Frogger.

## Getting Started

### Dependencies
- Requires MacOS/Windows OS
- Requires MARS v4.5 (available at http://courses.missouristate.edu/kenvollmar/mars/download.htm)

### Installing
Download frogger.asm from https://github.com/TylerCYan/FroggerASM to your local machine.

### Executing Program
1. Open frogger.asm using MARS v4.5.
2. Set up display by clicking Tools > Bitmap display. Set unit height and width in pixels to 8, display width and height in pixels to 256, and base address for display to 0x10008000 ($gp)
3. Set up keyboard by clicking Tools > Keyboard and Display MMIO Simulator, and click "Connect to MIPS".
4. Click Run > Assemble.
5. Click Run > Go.

### Instructions
After executing the program, play the game by entering characters in the Keyboard area in Keyboard and Display MMIO Simulator window.

#### Controls
- Move Forward: w
- Move Backward: s
- Move Left: a
- Move Right: d
- Load Level 1: r
- Load Level 2: t
- Exit Game: esc

#### Objective
- Move the frog into the goal regions (marked as a bright purple box on the top of the screen)
- Avoid pink vehicles on the road, and avoid falling into the river by staying on the brown logs floating on the river.
- Everytime a collision happens, you lose a life. If you lose 3 lives, you lose the game.

## Help
If any unexpected behavior happened, such as the screen freezing or the frog moving out of bound, restart the game by pressing esc, and executing the program again.

## Known Bugs
In MARS v4.5, holding a key on the keyboard may cause MARS to freeze or crash. Avoid entering a character repeatedly until the frog has responded to your input.

## Author
C.Y. Yan


## Acknowledgements/References:
https://froggerclassic.appspot.com/ gave me some idea on what I should implement to capture the essence of Frogger.
