# ZARMAT

![ZARMAT](./docs/zarmat.png)

Hey there! Welcome to **ZARMAT** (Zig + Shach-Mat, i.e. Chess in Hebrew), the Real Time Chess Auto Battler where you get to buy chess pieces and place them on the board in real-time. The best part? They do all the heavy lifting for you! So, can you think fast enough to outsmart your opponents?

## About the Project

This is my game dev project where I'm diving into the world of game development, specifically focusing on OpenGL and game architecture.

## Constraints

To keep things manageable and ensure we actually finish this project, here are the constraints I'm working with:

- **No Audio**: Keeping it simple and focused.
- **OpenGL**: Gotta love those graphics! (no vulkan yet)
- **Vs AI Bot**: Challenge yourself against a clever AI.
- **Desktop Only**: For now, we're keeping it on desktop platforms.
- **2D Flat Pixel**: Embracing that retro vibe! (3D will be for another time)
- **No Animation**: We're going for a straightforward approach.

## Challenges

Here are the challenges I'm tackling along the way:

- **Camera Management**:
  - One camera for the board and another for the UI.
- **Scenes Management**:
  - Main Menu
    - Game Tick Speed settings.
  - Game Scene.
- **Game Loop**:
  - A consistent 2 seconds per tick to keep the action flowing.
- **Logic**:
  - Board piece movement mechanics.
  - Shop mechanics for buying and selling pieces.
- **Code Architecture**:
  - Structuring the code that make sense for all the pieces.
- **Input Handling**:
  - Drag & Drop functionality.
  - Select & Click interactions.
  - Keyboard Shortcuts for quick actions.
  - Highlighting pieces/rows/cols for better visibility.
- **Build System**:
  - Using zgui only for debug builds to streamline the process.

## Assets

The Chess Assets come from [WildLifeStudios](https://wildlifestudios.itch.io/chess-set-pixel-art)
