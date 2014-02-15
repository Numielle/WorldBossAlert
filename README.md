WorldBossAlert
==============

WorldBossAlert simplifies scouting for world bosses by checking the scout's combat log for crucial events, these are:

1. Melee attacks by mobs and comparing the attacker's name to a list of known world boss names (Azuregos, Kazzak and the Emerald Dragons). This will be referred to as "scouting".
2. Melee attacks and casts by enemy players. This will be referred to as "pvp". [Note: Also triggered in duels!]
3. Death, referred to as "death".

These features can be configured separately, the addon provides the following slash commands:

1. "/wbalert" as main command printing the current addon configuration (scouting/pvp/death on/off) aswell as a short usage guide.
	Example output:
  ```
	[WorldBossAlert]
	Usage: /wbalert {death | pvp | scout}
	- death: Toggle death notificatoin [OFF]
	- pvp: Toggle pvp combat notification. [OFF]
	- scout: Toggle boss scouting. [ON]
	```

2. "/wbalert death" toggles the notification of death events.
	Example output:```WorldBossAlert death notification turned OFF.```

3. "/wbalert pvp" toggles the notification of pvp events.
	Example output:	```	WorldBossAlert PvP notification turned OFF.	```
	
4. "/wbalert scout" toggles the notification of pvp events.
	Example output:	```	WorldBossAlert scouting turned ON.		```

In this scenario, there won't be any notifications in case the scout gets attacked by enemy players or upon death. It will however inform about attacks by a world boss.

If one of the tracked events occurr, the addon will post about it in the guild chat, e.g.:

1. scouting: "AZUREGOS IS UP!!"
2. pvp: "PvP attack by Numielle. [Badlands @ 3.9, 47.8]"
3. death: "Scout Raperofsoulz has died. [Badlands @ 3.8, 48.2]"


The default configuration has all three features turned off. Changes of the configuration are saved when you relog, so you only have to configure it once per scout. 

To avoid spam during actual attempts this addon will NEVER notify if the scout is in raid. This is a safety measure for people using their main chars to scout. Please make sure you NEVER use a scout in a raid group!

Please report any bugs to Numielle @ Emerald Dream with information how to reproduce said bugs. I'm not going to respond to reports a la "it doesn't work". 
