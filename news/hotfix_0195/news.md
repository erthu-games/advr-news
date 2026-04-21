## <color=#DBD700>Hotfix ea0.1.9.5</color>

Hotfix ea0.1.9.5 has been released! This one fixes a ton of bugs that have been reported over the past month!

## New & Improved
- Cosmetics are now separated into categories
- Added nametags toggle button to the LIV tablet
- It is now possible to delete save slots

## Bug Fixes
- You now only pick up the relic that is shown in the hover info even if multiple relics overlap
- Fixed crossbow bolt unable to damage armor pieces
- Fixed an issue with NG+ world generator desyncs
- Fixed being able to enter the main menu after beast died causing softlocks
- Fixed jackpot crystal not spawning if max amount of crystals per run has been reached already
- Several speechbubble improvements
- Fixed relentless orchestrina wisp sometimes getting stuck forever
- Fixed regular wisps not teleporting to the player if too far away
- Fixed wisps getting stuck on ghost fights
- Fixed swinging axe damage not being counted as trap damage
- Fixed forgotten library shooting trap not being counted as trap damage
- Fixed some issues with vial of blue blood
- Mortality stat now has a default value with introspeccd
- Fixed curse of retribution save stack issues
- Fixed save state issues with: embroidered sleeve, curse of binding, chicken dinner, foam bat, halved worm, wolf fang
- Fixed a damage bug with burlap blindfold
- Fixed hit cooldown never resetting in subsequent run
- Fixed incorrect damage boost for proxies with shattered mirror
- Fixed vial of blue blood damaging the player visually when having fragranced letter
- Heartstring harp and fragranced letter now award money when vial of blue blood is active
- Fixed being able to open the main menu in the crystal prism fight
- Fixed elemental attack particles passing through ground tiles and pillars
- Fixed imbued ruby not correctly adjusting player health
- Fixed eating food prevents that hand from grabbing items for a few seconds
- Fixed Curse of leaden feet falling through the floor in arena mode in MP
- Fixed Tress of silken hair not awarding hearts in MP
- Fixed glowing crystal palette shader
- Fixed speechbubble not being able to show multiple choices
- Fixed coin reward quests not awarding coins on complete
- Fixed worn shovel changing weights of non unlocked relics
- Fixed attics anonymous not unlocking correctly
- Fixed 100% progress in game slot not being possible
- Fixed challenge ghost not being invincible which caused issues with the ghost fight with crossbow/tome
- Fixed multiple objects dealing damage to proxy players which could cause issues in high ping scenarios
- Adjusted and fixed weapon relic colors for crossbow and dagger
- Fixed magnetic coupler not working on skeleton chests
- Fixed 'blood rune' invalid function calls
- Fixed proxies not teleporting out of shop fight
- Fixed an issue with Ambient Occlusion not working in the latest build
- Fixed sealed room gates not being tall enough in forgotten library
- Fixed exploding bulbs sometimes not triggering their explosion in multiplayer

## Modding
- Minor version differences in mods in the mod menu will now be shown in yellow instead of red
- Fixed an issue with rpcs not correctly working with mods
- Removed error log from spawn object
- Exposed BulletHoming, ADVRNetworkAnimator, PlayerFog, UIBestiaryImage, BossInfo and BulletHomingCrystalPlant
- Removed WattlescriptHidden from GameHandler.initialized
- Added directory check for room creator to skip empty directories
- New modding events added: onPreMarkTriggered and onPostMarkTriggered
