# Mik Mik - Lunch Rush (Godot Edition)
A playable, single-player, top-down 3D restaurant-management and swarm-survival roguelike prototype built with Godot 4.7.1 and GDScript. Play as a mouse chef, serve customers, and survive waves of cats, dogs, and other enemies. Restaurant tasks and weapons operate automatically while you manage movement, positioning, and upgrades.

**Project owners:** Merve Sena Çınar & Ali Erdem Cerrah
**Other implementation:** Mik Mik - Three.js Edition

## Getting started
Run Oyna.command on macOS, or open project.godot in Godot and press F5. From the main menu, select Mutfağı aç (Open the Kitchen).
- WASD / arrow keys: Move.
- Space: Dash, with damage protection during the dash.
- Esc: Open or close the pause menu. Mandatory upgrade choices cannot be skipped.
- Mouse: Select kitchen or combat upgrade cards.
- Top-right buttons: Break and sound controls.

## Mouse characters, customization, and persistent progression
The main menu has three tabs: Fareler & stil (Mice & Style), Başlangıç statları (Starting Stats), and Başarımlar (Achievements). All playable characters are mice. Fur and outfit colors can be selected from four coordinated palettes each, with instant updates in the 3D preview. Four eye shapes are available: round, sharp, sleepy, and oval. Color, eye shape, character, clothing, and difficulty selections are saved. Older RGB profile values are mapped to the nearest palette color.

| Character | Starting trait | Unlock condition |
| --- | --- | --- |
| Mik | Balanced starting attributes | Available by default |
| Zıp | 15% faster; +1 plate capacity | Complete 10 total servings |
| Tok | +24 health; +15% weapon damage; 8% slower | Defeat 75 total enemies |
| Nane | +25% cooking speed; +20% cleaning speed | Complete 50 total servings |

The Chef outfit is unlocked by default. Traveler unlocks after 10 servings, Guardian after 75 defeated enemies, and Royal after the first victory. Outfits are cosmetic and do not modify character bonuses. Six achievements display their criteria, progress, and rewards in the menu. New achievements trigger a brief in-game notification and persist across runs.

**Persistent tips:** Earn 1 tip per serving, 1 per 10 defeated enemies, and 30 for a victory, plus 20 for reaching shift four for the first time and 50 for the first victory on Hard. This persistent currency is separate from run-specific gold and the two XP pools. Five training categories—health (+8), movement (+3%), weapon damage (+5%), cooking (+5%), and cleaning (+5%)—each have five tiers costing 10/20/30/40/50 tips. Training bonuses apply to future runs without occupying equipment slots. Tiers of the same training stack and multiply with the character's bonus.
Difficulty	Enemy health	Damage	Speed	Extra enemies per wave	Unlock condition
Lunch	×1	×1	×1	0	Available by default
Rush Hour	×1.35	×1.25	×1.15	2	Available by default
Nightmare	×1.8	×1.6	×1.3	4	First victory

The profile is stored at user://mik_profile.cfg, separate from the older high-gold record. A modified profile is saved at least once every three seconds, as well as at the end of a run, on restart, and on normal window closure. Abrupt process termination may result in the loss of up to three seconds of recent progress. New features do not erase the older score record. Achievements are local; there is no Steam or other platform integration.

## Large map and camera
The restaurant courtyard measures 64 × 52 units, with ten tables and a kitchen pavilion. Tables are at least eight units apart. The camera retains the earlier 23.5 orthographic size and viewing angle, follows the character smoothly, and does not zoom out to show the entire map at once.

Circular customer portraits, direction arrows, food/action icons, and patience rings appear near the screen edges. Tables use symbols-an order pad, oven, plate, cutlery, and sponge-instead of text. The top-left HUD contains six kitchen slots, six combat slots, and separate XP bars; hovering over an item displays its description.

Map upgrades can be combined in a single run: a boulevard that removes central dividers, a speed lane between the kitchen and courtyard, and mouse tunnels connecting the outer wings.

## Automated restaurant workflow
1. Approach a table and pause briefly to take the order automatically.
2. The kitchen cooks the food automatically. Approach the counter to collect ready dishes on your tray.
3. Approach the corresponding table to serve the dish in a short arc; the customer begins eating.
4. Once the meal is finished, earn gold, kitchen XP, and 4 health. Approach the dirty table to clean it.
Cheeseburgers, vegetable pizzas, pumpkin soup, and cheese platters have distinct 3D models. The same dish appears in the kitchen, on the tray, and at the table. Food emits steam and portions visibly shrink as customers eat; customers have hand-to-mouth and chewing animations. Selecting an upgrade card triggers a short mouse hop, glowing rings, and spark effects.
Surrounding enemy swarms
Enemies spawn off-camera from eight sectors surrounding the player, instead of entering individually through two gates. Each run begins with eight seconds of preparation time, and enemies take additional time to approach. Waves contain 4–9 animals, with shorter intervals as shifts progress. Up to 96 regular enemies and a final boss can be active.

| Shift | Enemy wave |
| --- | --- |
| 1 | Stray cats |
| 2 | Cats and stray dogs |
| 3 | Black cats and club-wielding humans |
| 4 | Armored bulldogs and club-wielding humans |
| 5 | Foxes and larger groups of humans |
| 6 | Mixed alpha swarm and a giant bulldog boss named Kazan Kıran |


Enemies navigate around furniture and spread apart as they approach. A red ring telegraphs an incoming attack after a brief wind-up. Dodge it by moving or dashing. The player receives a short invulnerability period after taking damage.

## Separate XP pools and upgrade choices
**Kitchen XP (green):** Earned by completing meals. Standard servings grant 2 XP and student servings grant 3 XP. This pool offers character service traits, restaurant, customer, and pathway upgrade cards.

**Combat XP (purple):** Earned only by defeating monsters. Regular animals grant 4 XP, bulldogs 8 XP, and the boss 30 XP. This pool offers weapon and combat cards only. Monster kills do not grant gold or kitchen XP.

Each pool has its own level, threshold, and HUD progress bar. Simultaneous level-ups are queued with their originating pool. While an upgrade choice is open, the world simulation, customer patience, camera, animations, and combat pause. At the first combat level-up, all three choices introduce a new weapon: knives, pans, or peppers.

## Automatic weapons
- **Soda:** Starting weapon; fires toward the nearest target in range.
- **Chef knives:** Automatically thrown knives that pierce multiple enemies; higher levels increase knife count and damage.
- **Spinning pans:** Orbit the chef and deal contact damage; additional levels add more pans.
- **Hot pepper:** Leaves damaging, slowing clouds along the player's movement path.
- **Combat support:** Soda pressure, fire rate, weapon range, overall damage, and a defense bell triggered by restaurant service.
There are 25 upgrade cards in total: 17 kitchen/service cards and 8 combat cards. The starting soda weapon uses one combat slot. When empty slots exist, new items are offered; once slots are filled, upgrades for existing items are offered instead. Equipment can reach level IV; customer and pathway unlocks have one level each.

Foam Master IV unlocks the Dishwashing Fairy; Balance Master IV unlocks the Serving Conveyor. An evolution card is offered only once per run and will not reappear if declined. Choosing it replaces the corresponding base item in its slot. The Dishwashing Fairy remotely cleans a table every seven seconds, and the Serving Conveyor collects ready plates from a distance. Before these evolutions, players must approach the kitchen or dirty tables themselves.

The mouse displays an order pad when taking orders and a sponge when cleaning, with corresponding hand movements. Other animations include collecting and serving plates, walking, eating, and gaining power. Human enemies telegraph attacks by raising their clubs.

## Run completion and save data
Six shifts become progressively harder. Win by completing the final shift and defeating Kazan Kıran. A run ends in defeat if the chef's health or the restaurant's reputation reaches zero. Levels and weapons reset at the beginning of each new run. The highest gold score is stored in user://mik_mik.cfg; gold is a run score in this version and is not spent as XP.

## Source code and tests
- scripts/game.gd: World, camera, service flow, UI, and dual-XP progression.
- scripts/monster_system.gd: Enemy models, swarms, navigation, and weapons.
- scripts/order_indicators.gd: Off-screen order and patience indicators.
- scripts/food_visual.gd and scripts/power_effect.gd: Food presentation and animations.
No external package or model downloads are required. The large ground surface uses MultiMesh, and swarm separation uses spatial cells.

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --smoke-test
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/features_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/swarm_test.gd
```

The smoke test checks WASD movement, dash, collision, and the service workflow over real physics frames. Other tests cover food and animations, access to the larger map, camera tracking at a fixed distance, multi-directional off-camera spawns, enemy variations, XP separation, knife/pan/pepper hits, order indicators, and a 30-second swarm simulation. Tests do not alter player save data.

tests/swarm_preview.gd runs a visual/stress-test scene in the actual Godot renderer, exporting animation frames to captures/swarm/ and game/card screenshots to captures/. Weapons and customers are pre-positioned in this preview for visual inspection.

**Development status:** This is a playable prototype; long-term gameplay balancing is still in progress.

## Performance profiling
Wave models are now spawned across several frames rather than all at once. Static face/body details are merged into cached geometry, while moving limbs remain independent. tests/runtime_profile.gd measures frame times during active combat and the customer service loop in the actual renderer.

In an example run on an Apple M2, draw calls decreased from 1,598 to 1,207, and peak simulation time during spawning dropped from 7.17 ms to 3.68 ms. Enemy counts vary between randomized runs, so these figures are not controlled FPS guarantees. An isolated long frame of approximately 118 ms was still observed; this does not imply all stutters have been eliminated.

tests/loadout_test.gd checks slot limits, evolution prerequisites, one-time offers, level caps, human waves/attacks, and interaction animations.

tests/profile_test.gd covers persistent tips, purchase prices and limits, achievement unlocks, save/load, color/outfit choices, menu controls, four characters, upgraded health limits, difficulty effects, and one-time victory rewards. tests/profile_preview.gd generates actual Godot screenshots of the new menus; test progress is not written to the player profile.

## Visual design
Mouse characters feature layered eyes, brows, teeth, whiskers, cheeks, nose highlights, stitching, and buttons. Zıp has a slim frame, tall shoes, courier cap, and crossbody bag. Tok is broad-bodied with shoulder pads, gloves, and a belt. Nane carries a leaf-patterned headpiece, herb bag, and bottles. Mik wears a double-breasted chef coat and utensil holster. Cosmetic outfit choices are layered onto each character's base appearance.

Tables include runners, trim rings, napkins, cutlery, spice jars, and embroidered cushions; kitchen details include shelves, jars, stacks of plates, oven bricks, and pot handles. Planters feature flowers and leaf veins. Food details include toasted buns, sesame seeds, lettuce, pizza crust and mushrooms, soup garnish, and grapes/crackers. Enemy faces, collars, armor, and clothing have also been refined.

Static decorations and edible portions use merged geometry, while visibility and animations of individual portions remain independent. Faces, outfit details, planters, and table decorations use cached combined geometry. Customer face geometry is prepared before a run begins, avoiding first-use merging work when new customers arrive.

tests/style_test.gd verifies Esc pause/resume, key repeat behavior, four-color palettes, eye shapes, character appearance, and consumption of detailed food models.

## Project ownership and licensing
**Project owners:** Merve Sena Çınar & Ali Erdem Cerrah
**Copyright:** © 2026 Merve Sena Çınar and Ali Erdem Cerrah.

This repository is public and source-available under the PolyForm Noncommercial License 1.0.0, not an unrestricted or OSI-approved open-source license. Commercial use requires separate written permission from both copyright holders. Third-party materials remain subject to their respective licenses and ownership rights.

For the separate browser-based implementation of the same game, visit the Three.js edition.
