Hey everyone. This update fixes a lot of the reported issues over the last few weeks. Stay tuned for the next dev log next week where we talk about the next upcoming updates! (last weeks devlog was skipped because it was during the holidays). 

changes/fixes:
- The Alchemist challenge run now doesn't spawn orbs any more that were excluded
- NG+ 2 now correctly applies damage to the player when hit
- NG+ now doesn't override damage from items and mods any more that change the outcome of the damage
- Food no longer disappears in NG+ 2 and higher in your wrist slots upon reloading a save game
- In NG+ 3 and higher your health bar now properly gets disabled upon reloading a save game
- The Gambler challenge run no longer gives out flyers all the time in certain runs
- The "Caretaker" milestone now resets the 'being hit' state upon entering NG+
- The Item Compendium and Insight Shop now update when milestones are unlocked in the hub that give insight or/and an item
- Fixed "Third card monte" showing stat change popup upon reloading a save when you picked up the item
- The crossbow color no longer disappears when using snap turn 
- fixed ghost NPCs getting killed with assassins mark
- fixed a bug where killing the ghost in the ghost fight with assassins mark softlocking the fight
- controllers now vibrate when parrying a ghost sword
- "Third Card Monte" can no longer remove heart containers
- When using snap turn you now get snapped to the closest angle after talking with NPCs or during the ghost fight to prevent offset issues
- fixed potential synergy issues with calcified pustule
- fixed ghost npcs not getting cleaned up when entering the next floor
- fixed falling out of the map when getting too close to collapsed walls
- fixed threshing blade not affecting ceiling plants in the mine

modding additions:
- exposed new classes "Chest", "Lock", "AIBossBook", "WorldGeneratorEvolved.BuildingBlock"
- added some missing objects to StringToObjectMapper
