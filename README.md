This is the start of a simple presentation program for [C64OS](https://c64os.com). 

It started off as a port of the C64 native presentation program https://github.com/gnacu/presenter.
By now it has new file format that enables more features.

The file format is a very simple petscii format that can be created and edited with standard C64 text editors like Novatext.

# File format
Presentation files are sequence files that are required to have the '.prs' file extension.

The bulk of a presentation file consists of standard petsii text. In addition to this a set of commands can be used that are always prefixed with an '!' (to have an ! in the output just use !! in the slide content).

The following commands are supported:
* __!s__: Start of a new slide. This command pauses the presentation and when 'Next' is triggered, will clear the screen and start any new content from the top-left of the screen.
* __!p__: Pause the current slide. This command pauses the presentation and when 'Next' is triggered, will continue any new content at the paused position.
* __!cxx__: Changes the text color. It requires a two digit decimal number, between 0 and 15, immediately after the command.
* __!bxx__: Changes the background color. It requires a two digit decimal number, between 0 and 15, immediately after the command. This command is mostly useful right after a __!S__ or __!P__ command. In the latter scenario it allows for changing background color after each pause, note that the full screen background is changed.
* __!lxxyy__: Changes the ouput location. This command requires a two digit decimal numbers, the first for the new X coordinate (or column) the second for the new Y coordinate (or row). Note that as the screen has a resolution of 40x25 characters these values have to be between 0-39 and 0-24 respectively.
* __!hxxyy__: _(will be available in the next version)_ Changes the output 'home'. This command is very similar to the __!lxxyy__ command. However, it also 'remembers' the x-coordinate for any new lines following its use. This is very useful for adding 'blocks' of content to a slide, when combined with the __!p__ can be used creatively for 'builds' or 'animations' of 'blocks' of content anywhere in the slide while keeping the content 'around' it constant.
* __!i'\<path\>'__: _(will be available in a later version)_ Loads an image, specified with \<path\> to the graphics screen (can be toggled with CMD-F). Note that the path needs to be enclosed by single quotes.
* __!m\<cmd\>__: _(will be available in a later version)_ Adds SID music support to presentations. Note that there because of memory limits, SID files have to be relatively small to work inside a presentation. The __!m__ needs to be followed by a sub-command (\<cmd\>):
  *  __!ml'\<path\>'__: Loads a SID file, specified with \<path\>. Note that the path needs to be enclosed by single quotes.
  *  __!ms__: Returns the 'play head' to the start of the SID file.
  *  __!mp__: Toggles pause/play on the currently loaded SID file.
* __!e__: Ends the presentation.

