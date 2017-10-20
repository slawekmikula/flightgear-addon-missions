# About

Flightgear missions addon. Written in NASAL. Adds ability to perform mutliple missions/tasks.

# Running

- extract zip (if downloaded as a zip) to a given location. For example let's
  say we have /myfolder/addons/mission with contents of the mission addon.
- run flightgear with --addon directive. WARNING this is not "additional settings"
  window in the launcher ! you have to modify windows shortcut or linux startup
  script for example to looks like this (in linux):

Code:
```
    ./fgbin/bin/fgfs --fg-root=./fgdata --launcher \
    --prop:/sim/fg-home=/myfolder/flightgear/fghome \
    --addon="/myfolder/addons/mission"
```

# Running

- after FG startup there is new main menu available "Missions"
- there is mission browser, which provides GUI selector for various missions
- read carefully mission description, because it sometimes have information about
  startup airport
- you can start the mission from the mission selector's GUI
- when running mission, you can stop it by selecting Missions->Stop mission menu
  entry

# History

- 0.1 - initial release as an FG addon

# Authors

- Marius_A - concept, coding

# Links
- FlightGear wiki: [Wiki](http://wiki.flightgear.org/Missions)
- FlightGear forum: [Forum](https://forum.flightgear.org/viewtopic.php?f=79&t=31057)

# License

GNU General public license version 3