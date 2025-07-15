# TODO

## Constraints

To keep things manageable and ensure we actually finish this project, here are the constraints I'm working with:

- **Simple Audio**: Keeping it simple and focused use sokol_audio.
- **Everything Sokol**: only one dep. no steamworks, fmod, etc...
- **Vs AI Bot**: Challenge yourself against a clever AI. i.e. single player
- **Desktop Only**: For now, we're keeping it on desktop platforms. i don't want to start working with swift template for ios.
- **2D Iso Pixel Art**: Challege enough to work with isometric but not 3D yet.
- **Animation**: Some procedual animation for piece movement, and maybe some animation for spawning or particles.
- **Shader** - learn to make nice vibez.

## Tasks

- [x] have a hello triangle sokol app running in zig.
- [ ] draw isometric block for chess board and one simple tower
- [ ] simple 2-scene loop:
  - main menu -> play -> game -> escape/(ui) -> exit -> main menu -> quit -> process end
- [ ] render a 8x8 iso grid with block
  - [ ] make the grid chess like pattern
- [ ] place a piece on the board and figure out coords system for moving
- [ ] create simple ui with fonts
  - [ ] main menu icon -> modal
  - [ ] shop icons
  - [ ] time ticker
  - [ ] options modal
    - [ ] time mod x1 x2 x3
- [ ] input system
  - [ ] for drag/drop click buy/place
  - [ ] same but with kbd shortcuts
- [ ] game loop with ticks, each tick piece move
