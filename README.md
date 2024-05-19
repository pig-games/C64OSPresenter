This is the start of a simple presentation program for [C64OS](https://c64os.com). 

It started off as a port of the C64 native presentation program https://github.com/gnacu/presenter.
By now it has new file format that enables more features.

The file format is a very simple petscii format that can be created and edited with standard C64 text editors like Novatext.

# File format
Presentation files are sequence files that are required to have the '.prs' file extension.

The bulk of a presentation file consists of standard petsii text. In addition to this a set of commands can be used that are always prefixed with an '!'.

The following commands are supported:
* __!S__: Start of a new slide. This command pauses the presentation and when 'Next' is triggered, will clear the screen and start any new content from the top-left of the screen.
* __!P__: Pause the current slide. This command pauses the presentation and when 'Next' is triggered, will continue any new content at the paused position.
* __!Cxx__: Changes the text color. It requires a two digit decimal number, between 0 and 15, immediately after the command.
* __!Bxx__: Changes the background color. It requires a two digit decimal number, between 0 and 15, immediately after the command. This command is mostly useful right after a __!S__ or __!P__ command. In the latter scenario it allows for changing background color after each pause, note that the full screen background is changed.
* __!Lxxyy__: Changes the ouput location. This command requires a two digit decimal numbers, the first for the new X coordinate (or column) the second for the new Y coordinate (or row). Note that as the screen has a resolution of 40x25 characters these values have to be between 0-39 and 0-24 respectively.
* __!Hxxyy__: _(will be available in the next version)_ Changes the output 'home'. This command is very similar to the __!Lxxyy__ command. However, it also 'remembers' the x-coordinate for any new lines following its use. This is very useful for adding 'blocks' of content to a slide, when combined with the __!P__ can be used creatively for 'builds' or 'animations' of 'blocks' of content anywhere in the slide while keeping the content 'around' it constant.
* __!I'\<path\>'__: _(will be available in the later version)_ Loads an image, specified with <path> to the graphics screen (can be toggled with CMD-F). Note that the path needs to be enclosed by single quotes.
* __!S\<cmd\>__: _(will be available in the later version)_ Add SID music support to slides. Note that there because of memory limits, SID files have to be relatively small to work inside a presentation. The __!S__ needs to be followed by a sub-command:
  *  __!SL'\<path\>'__: Loads a SID file. Note that the path needs to be enclosed by single quotes.
  *  __!SS__: Returns the 'play head' to the start of the SID file.
  *  __!SP__: Toggles pause/play on the currently loaded SID file.
* __!E__: Ends the presentation.

