Hello everyone. As promised, here is the hotfix for this week. Next update will feature new content!

additions:
- added support for native Oculus Drivers

changes/fixes:
- fixed activatable items not getting counted to new items found during the run
- fixed a rare case of the player not getting teleported back up when falling in a pit/void
- fixed assassins mark spawning multiple times
- fixed pickup charge being wrong when loading a run
- fixed some item combinations killing the player when loading a run
- fixed a few issues with "Traverse X Dungeon without taking damage" achievements
- fixed minimap having wrong openings for wallspaces
- fixed game camera breaking when using LIV
- fixed pressurized capsule augment on Crossbow not working
- fixed some items/achievements not working with crossbow combo
- fixed shiny slimey and you break it you buy it achievement unlocking the same item
- fixed calcified pustule and hummingbird feather breaking the crossbow
- fixed glass cannon + engagement ring synergy
- fixed movement sometimes getting stuck on some controllers
- fixed portals blocking enemy projectiles
- crossbow bolt will now always explode after a few seconds when in air to avoid broken synergies
- companion wisps now deal correct damage to enemies
- reduced amount of charges needed for miner's mark
- changed color of Orb of focus to make it more distinct from glittering orb
- sprout of animate ivy now won't shrink sword when hitting non enemy objects (tables, crates, etc)
- dead weight spikes no longer damage the player
- player is now immune to noxious orb cloud
- calcified pustule no longer damages the player but deals less damage now
- reduced befouling sludge hit delay
- rock slimes will now only spawn spikes when they can see the player
- removed horizontal attacks of elder skeleton

modding additions:
- onEnteredNGPlus event added
- onSpawnInHomeBase event added

- exposed UnityEngine.UI.Button
- exposed UnityEngine.Sprite
- exposed ModLoader
- exposed RectTransform

- crossbowbolt now has delayUntilReturnToPlayer
