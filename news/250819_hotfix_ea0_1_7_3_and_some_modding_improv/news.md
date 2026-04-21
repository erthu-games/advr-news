- added a high performance mode which should improve performance on slower devices in high NG+ situations or big multiplayer lobbies (removes unnecessary corpses, reduces impact particles amount, more to come in the future)
- fixed door pillars in the boss room sometimes not opening after defeating a boss
- fixed an world generation issue that breaks the generation when killing a boss too quickly while the generation algorithm is still running
- fixed multiplayer lobby breaking when the host player dies in a start room of a dungeon
- removed some stray pixels in the controller textures in the how to play screen
- fixed some issues with the noxious sewers boss
- noxious sewers boss now spawns less flys between phases
- noxious sewers boss now has a smoother flight path
- fixed "Hard Mode" text not appearing in the hard mode settings
- fixed vial of blue blood disabling other players health bar in subsequent runs
- fixed spectator cam hearts not showing again after being revived
- fixed some MSAA seam artifacts in some models
- sharpened eagle talon homing effect has been increased for the tome and wand
- tome and wand lightning incantation now also colors the colliding lightning sparks correctly
- fixed black spots on dungeon entrance model texture
- sprout of ivy on tome and wand has been changed to increase damage over distance, not over time, making it more reliable
- fixed some bottled lightning issues on tome and wand
- fixed unintentional sweep attacks occuring when equipping/unequipping tome and wand
- adjusted foam bat description
- fixed an out of bounds issue with a certain room in the bog POI
- fixed bee stinger giving incatation damage instead of spell damage
- the bog movement speed has been increased a bit
- fixed magic wand swing sound playing continously when rotating the player via snap or smooth turn
- fixed magic book sweep attack triggering when rotating quickly via smooth turn

## Modding Related:

A big rework of the ingame VR console:

 
- The console is now a floating window which can be moved around in world space instead of being on your hand
- Support for showing and filtering log messages
- Console commands are also now put into a history for easy access between testing sessions
- Added a keyboard and auto filtering support

more features for the flatscreen mode console:

- Support for showing and filtering log messages
- it is now possible to add keybinds for quicker debugging
- Commands history support

- it is now possible to add custom milestones via modding
- added canvas scaler to modding support
- custom rooms are now supported
- added a new debug setting test_room_dungeon, which lets you try out your rooms inside a normal dungeon generation
- test_room debug setting finally works again and lets you look at your room in isolation
