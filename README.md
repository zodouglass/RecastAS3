RecastAS3
=========

AS3 Recast/Detour library

AS3 Alchemy wrapper library for Recast Navigation Pathfinding ( https://code.google.com/p/recastnavigation/ )

TODO
======
- Create an actionscript wrapper class for the exposed swc methods (for autocomplete and compiler error checking)
- Expose more recast navigation methods
- Create a 3D example
- Create documentation!
- clean up makfile :X
- sync with latest version of recast navigation from SVN
- clean up 2d demo

Directories
============
- as3_demo_2d 		- simple 2d example (project file included for FlashDevelop)
- recast_alchemy 		- alchemy wrapper classes to compile C++ code to swc. Also includes latest swc build.
- recast_alchemy/demo - Modified files from the recastnavigation/RecastDemo project (removing debug drawing code)
- recastnavigation 	- C++ source code from recastnavigation project (https://code.google.com/p/recastnavigation/). Using revision 343 (June 02, 2012)

Requirements
============
- Compile with Adobe Crossbridge (formely Alchemy): https://github.com/adobe-flash/crossbridge
- Read the readme after installation

Compiling the swc
==================
- open cygwin from Crossbridge
- change directory to your RecastAS3\recast_alchemy directory
- run the command: make all FLASCC=/cygdrive/c/sdk/Crossbridge_1.0.1/sdk/ FLEX=/cygdrive/c/sdk/flex_sdk_4.6.0.23201B_air_3.2/
	(changing the locations as necessary)
- swc is outputed to recast_alchemy/recast.swc