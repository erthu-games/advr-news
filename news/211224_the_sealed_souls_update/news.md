![](df105ee20c7a42aebab4bfe9560d5d27bb73f117.jpg)

Ancient Dungeon Content Update #1: The Sealed Souls is now available on AppLab and Steam! This is our first big content update and we hope you enjoy the new content over the holidays! Merry Christmas everyone and thank you for the huge support!

## Changelog

additions:
- 8 Challenge runs: Find the Seer in the homebase to enter the memories of fallen adventurers (The Seer only appears after a few conditions have been met)
- a new semi-boss
- 11 new milestones
- 15 new items
- 3 new orbs
- crossbow weapon combo is now also affected by color changing upgrades and colors the crossbow accordingly
- many new pickups now also color your weapons, making them more unique: warthog underbelly, tarnished silver chime, sprout of ivy, shard of a broken shield, ruptured dog eye, punctured breastplate, glass cannon, fungal growth, forge embers, dead weight, chain of spider silk, calcified pustule, bottled lightning, blunted knucklebone, blood pudding, befouling sludge, bamboo firecracker, aberrant blade
- Luck Stat which determines the chance to win at slot machines, item effect trigger probability and more
- the hunter now leaves a sign behind when entering NG+ to warn players of the risk they are going to take

changes/fixes:
- fixed flying skulls not being affected by damage areas
- fixed lucky horseshoe and crude treasure map sometimes causing exceptions
- fixed elder skeleton still shooting horizontal beams
- empty belly achievement now works with a saved run
- the crossbow bolt now gets stuck in enemies when hitting them instead of hovering in the air
- the crossbow bolt now returns in 3 seconds if the bolt didn't hit any enemies upon being shot
- fixed crit chance going over 100%
- fixed bamboo firecracker and calcified pustule not dealing critical hit damage
- needle of oroborous now only checks the first collision for an enemy if damage should be dealt to player or not
- fixed an issue in NG+++ with inconsistent player health
- Sacrifice statues decrease luck slightly upon being broken
- The doom shroom should no longer fire projectiles while in the air
- Orb of focus no longer has the insane speed glitch
- Hopefully fixed the 'Black Friday' milestone that would not work in certain cases
- Heart Container sacrifice statues now drop better loot than before

modding additions:
- improved error handling for easier debugging
- new events: OnSlotMachineGamble, OnVoidClearerDestroyed, OnProgressBought, OnVersionUpgrade, onPreBossFoodSpawn, onPreDungeonGenerated
- onEntityDeath now also contains the source object that killed it
- The StringToObjectMapper now returns a null/nil value when unable to find a mapping
- Exposed several new classes/structs, such as: UnityEngine.Light, EnemyBaseReference, WorldMapUI, ButtonWorldmapFloor, UnityEngine.RaycastHit, UnityEngine.LineRenderer, UnityEngine.TrailRenderer
- 'onPlayerHit' now has the source, attack type and hit position given as parameters if needed
- The 'HelperMethods' class now has 2 methods named 'IsValidWithLuck' which can be used to create a chance based on the new luck stat
- 'LivingBase' now has 2 new methods to deal damage with crit chances named 'DoHitWithPlayerCriticalChance' and 'DoHitWithCriticalChance'
- Items can now be placed inside a wrist slot by force if not already filled with the method 'PlaceObjectInSlot' in the 'Slot' class
- 'onPreObjectSpawned' now has the position and rotation as new additional parameters
- There are now functions to on runtime add listeners to the pre and post object spawn events: 'base.AddPreObjectSpawnListenersRuntimeByStrings', 'base.AddPostObjectSpawnListenersRuntimeByStrings', 'base.AddPreObjectSpawnListenersRuntimeByObjects', 'base.AddPostObjectSpawnListenersRuntimeByObjects'
