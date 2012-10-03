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
- Cygwin (for windows): http://www.cygwin.com/
- Adobe Alchemy toolkit: http://labs.adobe.com/technologies/alchemy/
- Follow the getting started document for Adobe Alchemy to configure cygwin to use the alchemy compiler: http://labs.adobe.com/wiki/index.php/Alchemy:Documentation:Getting_Started
- To make sure you are using the correct compiler, run the command "which gcc" in cygwin. Should output /cygdrive/c/path_to_your_alchemy_toolkit/alchemy-cygwin-v0.5a/achacks/gcc

Compiling the swc
==================
- open cygwin.
- Set alc-on to use the alchemy compiler
- change directory to your RecastAS3\recast_alchemy directory
- run the command: make
- swc is outputed to recast_alchemy/recast.swc