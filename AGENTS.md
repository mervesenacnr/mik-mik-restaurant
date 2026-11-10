# Project collaboration

## GitHub workflow (explicit user preference)

- Repository: `mervesenacnr/mik-mik-restaurant`; PUBLIC and source-available under the PolyForm Noncommercial License 1.0.0. Commercial use requires separate written permission from both project owners: Merve Sena Çınar and Ali Erdem Cerrah.
- The initial project import may be on `main`.
- For each subsequent update, create a NEW descriptive `codex/<change>` branch before editing. Do not reuse a previous feature branch or commit updates directly to `main`.
- Validate the change, commit the relevant project files, then push the new branch to this public repository. The user has explicitly authorized this routine branch-and-push workflow; do not request permission again.
- Report the branch name and link after pushing. Do not merge to `main`, force-push, delete branches, change repository visibility, or change collaborators unless requested.
- `mervesenacnr` is the repository owner and already has full access.

## Game constraints

- Godot 4.7.1, 3D mouse restaurant survival roguelike. Preserve automatic proximity actions and separate kitchen/combat progression.
- Movement: WASD and arrow keys; Space dash; Escape pause menu. Mandatory upgrade choices cannot be skipped with Escape.
- Keep gameplay HUD compact and symbol-based.
- Fur and clothing use FOUR curated colors each, never a free RGB picker. Eye shapes and appearance are saved with the profile.
- Do not write test progress into the player's real profile. Set `test_mode` for tests; use isolated temporary paths for save round trips.
- Run focused tests for relevant changes, inspect Godot errors even if a test exits zero, and visually inspect graphical changes.
- Keep `.godot/`, `captures/`, exports, local secrets and personal save data out of commits.
