#nBAM Scoreboard

This scoreboard is a modification / extension based on "Dx Scoreboard" by Flaker / Furdarius.

It has one additional column that displays a player's [nBAM](https://github.com/PotcFdk/nBAM) rank:

![nBAM_scoreboard screenshot](https://dl.dropboxusercontent.com/u/34110473/github/nbam_scoreboard/nbam_scoreboard.png)

List of changes:

- Modified config to add the column.
- Added file 'server/extension/Player.ext.lua' that connects the scoreboard to nBAM's group management.



Original Readme.md:

##Dx Scoreboard

OpenSource Dx Scoreboard for JC2-MP servers. 

Script allow instantly check information about online players.


[![dxScoreboard sreenshot](https://dl.dropboxusercontent.com/s/8pz9wlf87b3ljh7/scoreboard.png?dl=1&token_hash=AAGhrLoy5b5WqlmoTei4TvqrRCnq6wgJ-2RATr1v9fI00Q)](https://github.com/Furdarius/dxScoreboard)

[![dxScoreboard sreenshot](https://dl.dropboxusercontent.com/s/1xrgvbehlfgrzyh/scoreboard2.png?dl=1&token_hash=AAHFXtSEGw90n_dyzkweqzFQGW0KMXZQHJMw0qV5aauVSg)](https://github.com/Furdarius/dxScoreboard)

###Usage

Push "ALT" for show scoreboard.

Use "Mouse Scroll" for scroll players list.


###Features

* Minimalistic design
* Easily changed settings
* All parameters are changeable
* Easily add your own columns
* Changeable scroll settings


###FAQ
####How can i change collumns?
Open "shared/config.lua" and change "COLUMNS" array.

####How can i change activation button?
Open "shared/config.lua" and change "ACTIVATION_BUTTON" value.




#####UPDATE Dec 25, 2013:
* Fixed Load/Reload bug
* Synchronization optimized

#####UPDATE Dec 29, 2013:
* Fixed synchronization
* Added "Kills" and "Deaths" columns as default
* Updated columns width parameter
* Added config file
