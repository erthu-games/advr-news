Hey everyone. We're glad to announce that the next update <b>"OpenXR and Insight Rework"</b> is live on the public experimental branch, which is available to everyone. To access the experimental branch, you need to do the following:

Right click "Ancient Dungeon VR" in your library, press "Properties" and then under "Betas" you can select the "experimental" branch.

<i>NOTE: All progress that you do on the experimental version of the game will not transfer to your normal save file, so you can easily switch between the game versions without fear of breaking your original save file. </i>

If you play the experimental version, please report any issues you encounter either on our discord server in the #experimental-testing channel, or in the steam forums (we have created a new subforum specifically for experimental versions)

For the next few weeks we are going to monitor feedback and will fix the remaining issues and then we will release it officially. After that, work on the next content update will begin!

Current known issues:

- Teleport mode is not yet working
- Wall clipping is possible with climbing objects
- Grabbing objects sometimes bugs out
- Some sealed souls delves do not work yet

Thank you for playing and have fun!

### Full changelog:

<b>additions:</b>

- the Insight system has been reworked! Players now also collect additional Insight for spending money in shops, killing enemies, and completing floors. Hard mode also now gives a multiplier on collected additional insight. Collecting Journal Pages, Milestones and Items now gives more Insight than before. The amount of Insight depends on the difficulty of the milestone or the item tier.
- a rework of the Insight Board, which now has more Insight upgrades in different categories. To ensure a smooth transition to the new system, all your bought Insight upgrades will get refunded on update.
- PCVR now has point light shadow support and graphics settings (more settings to come in the future)
- picking up a mark pickup will drop an already equipped mark on the ground instead of voiding it
- 2 new Insight upgrades
- several items now have extra sound effects when they activate (Deafening Bell, Dented Gold Chime, Discarded Door Chime, Gaping Totem, Glowing Orange Spot, Needle of Oroborous, Packrat Mandible, Pit Friend, Silver Spoon, Swollen Dragon Lung, Tarnished Silver Chime, Tress of Silken Hair)

<b>changes/fixes:</b>

- updated the Project to Unity 2021.3
- With the change to OpenXR a lot of interaction issues have been fixed because the whole movement, climbing and interaction system has been rewritten from scratch!
- increased render resolution on Quest 2, which should result in a much sharper picture
- lots of physics improvements: movement or weapon stutter should not occur anymore
- hard mode now spawns more enemies
- optimized several parts of the world generation algorithm to reduce the amount of lag spikes
- doors will not pop up anymore during generation when entering a next floor, the floor is already generated one the player gets there
- improved performance should result in a smoother framerate (especially on Quest)
- seeds are now completely consistent in the world generator
- - this includes podest rewards, slot machine outcomes, enemy drops, shop selection and more
- - be aware, that depending on your progress in the game, the same seed still may look different. For example, players that have secret rooms unlocked will have a different dungeon layout than players that don't have them unlocked yet
- improved the hold angle settings system
- cracked mirror now reduces your luck a lot more in exchange for better stats
- myopic lens has been reworked
- befouling sludge now has a chance to deal crit damage
- enabling and disabling the ingame console without running a command will no longer block achievements for the run
- grinning totem now gives luck based on the amount of coins and keys that have been reduced
- Experimental versions now have a big warning in the main menu
- fixed glittering orb and some items not working in hard mode
- You can now change the UI pointer hand by using the trigger on whatever hand you want to use while the pointer is active
- fixed gaping totem not showing damage increase in stats when having coins
- fixed damage inconsistencies with NG+++
- reworked abacus bead
- fixed some items / progresses not having the correct behavior in NG+ and beyond
- fixed vial of blue blood + ruptured dog eye + glass cannon killing the player
- lobster bib now takes into account which type of food you are eating
- fixed shopkeeper boss hitboxes
- fixed challenge runs having hard difficulty when it was selected in the run preparation screen
- increased the length of the player sword and dagger by one voxel (to offset the more realistic holding angle)
- increased bullet slime spit distance
- fixed hedges and potentially some other objects not getting cleaned up when the floor is completed
- some pickups now have a chance of appearing multiple times, and their effects will now stack: Aberrant Blade, Bargain Signed in Blood, Black Box, Blood Pudding, Discarded Door Chime, Dueling Gloves, Lobster Bib, Punctured Breastplate
- better handling of pickups stacking their effects
- some visual improvements for the ingame console
- reworked the potion system which should fix most of the potion related bugs that have been reported
- fixed an issue in NG+++, which did not kill the player when DONT_SCALE_NEWGAME damage was applied (for example Packrat Mandible does this type of damage)
- reworked business senseless insight upgrade (now always gives an item but only 1)
- Calcified Pustule now deals a small amount of extra damage instead of dealing less damage

<b>modding additions:</b>

- It is now possible to create custom weapons via modding (this feature is not fully developed yet, more improvements are coming in future updates)
- It is now possible to create overrides of items (the new weapon system already uses this to give items weapon specific changes)
- A mod settings menu!

<b>modding changes:</b>

- GetEnemiesInRadius and GetLivingInRadius have been changed to take a Vector3 instead of a Transform
- New Stat system
- renamed BlockChance to EvasionChance, renamed ShopPriceMultiplier to ShopDiscount (ShopDiscount now works the other way around compared to ShopPriceMultiplier)
- renamed SwordDamage to PrimaryDamage, renamed KnifeDamage to SecondaryDamage
- renamed SwordCritChance to PrimaryCritChance, renamed KnifeCritChance to SecondaryCritChance
- removed IncreaseEvasionByRule, because it is now automatically calculated via the Stat System
- droptable.AddToDroptable now also has hardmodeProbability as a parameter
- reworked the potion/orb system to take care of a lot of things automatically, like keeping track how often the player has been affected, which enemies have been affected and vignette effects.
- ChangeRandomPlayerStatsSlightlyUnique and ChangeRandomPlayerStatsSlightly now take a key value as their first parameter because of the new stat system
- UpdateWeaponColors does no longer need an array of strings of which weapons need to be colored. Instead there now is UpdateWeaponColorsPrimary, UpdateWeaponColorsSecondary, UpdateWeaponColorsAll, UpdateWeaponColorsMelee, UpdateWeaponColorsRanged
- - SetTrailColor and SetTrailEmission have the same behavior now
- Exposed many new Types
- renamed AmountPickupFoundDuringIn to PickupFoundInRun
- renamed AmountTotalPickupsFoundDuringRun to TotalPickupsFoundInRun
