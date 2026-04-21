Hey everyone. This is the 4th development update. This devlog will mainly focus on the big code cleanup and rework we are currently working on.

## The Rework

Ancient Dungeon has been in development since around May 2018, which means a lot of the systems that are used have aged pretty poorly. Furthermore, the game contains a lot of legacy code and outdated systems which need to be refactored. That's why we are currently working on our second update, which is simply called "Codebase Cleanup".

Here is a small list of things that we are going to change/update:

- Use OpenXR as the new standard and remove VRTK from the project
- Update the project from Unity 2019.3 to 2020.3
- Improve and rework several parts of the project which are poorly optimized
- Improve the workflow of several modding related actions, such as AssetBundle loading, Room Modding, etc.
- Expand the modding capabilities
- Improve modding documentation
- Introduce a reworked stat system which makes item synergies behave more consistent, and also fixes a lot of issues with stackable upgrades and potions
- Make the world generation more consistent (currently the world can look different even if the same seed is used)
- Add Localization support
- Add some QoL features like Steam Workshop support, UI Pointers on both hands, and a stabbing mechanic for swords
- Rework/Rebalance some items which are currently having issues

This rework will probably take a few weeks for us to complete. Especially reimplementing all of the VR interactions in OpenXR may take some time. But it is necessary in order to support new HMDs in the future more easily and to add new content to the game in a more streamlined manner.

What will the players get from this? Most of this work is behind-the-scenes work, which means players won't even notice the difference. But there are still some things that people may notice:

- Less microstutters
- More consistent physics and climbing interactions
- Fewer issues with grabbing items/equipment

## Future Content

The Codebase Cleanup will most likely not introduce any new content. New content will come in the update after it. We are planning on adding new floors to the game which will be an alternative to the currently existing ones. For example, the alternate floor of the "Overgrown Gatehouse" will be called "The Buried Gardens". These alternate floors will be roughly the same difficulty wise, but feature new gameplay elements and a few new enemies. Our goal is to have an alternate floor for every floor currently in the game (except Beast's Cradle). 

Also, the Beast's Cradle won't be the final floor of the game. The true end boss and true final floor has not been revealed yet and will come in a future update. Stay tuned for that!

We are also looking into supporting Daily Runs with a daily Leaderboard and scoring system, so players can compete against each other every day.

We are also currently working on designing a few new gameplay elements such as new traps, different merchant shops and more. More info on that in future devlogs!

Thank you everyone for playing the game and giving feedback! We really appreciate it.
