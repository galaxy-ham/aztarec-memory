# Azta'rec's Memory Game

A lightweight World of Warcraft (Retail) addon that adds a small, movable
memory-game window to your UI. Fill 7 slots with raid-target-style icons
(Diamond, Circle, Square, X), then clear and try again.

## Features

- Movable, closable window — drag it anywhere, drag position isn't saved between sessions.
- 7 empty icon slots.
- 4 icon buttons (Diamond, Circle, Square, X) using the game's built-in raid target marker textures.
- Clicking an icon button fills the next open slot, left to right.
- An Undo button to remove the most recently placed icon.
- A Clear button to reset all 7 slots at once.

## Commands

| Command | Effect |
|---|---|
| `/mg` or `/memorygame` | Toggle the memory game window |
| `/mg clear` | Clear all 7 slots without opening the window |
| `/mg undo` | Remove the last icon placed without opening the window |

## Installation

1. Copy this folder into your WoW AddOns directory:
   `World of Warcraft/_retail_/Interface/AddOns/AztarecMemory`
   (the folder name must match the `.toc` file name, `AztarecMemory.toc`)
2. Restart WoW or reload your UI (`/reload`).
3. Make sure the addon is enabled on the character select AddOns list.

## Requirements

- World of Warcraft: Retail
