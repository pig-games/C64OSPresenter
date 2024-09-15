This is the start of a simple presentation program for [C64OS](https://c64os.com). 

It started off as a port of the C64 native presentation program https://github.com/gnacu/presenter.
By now it has new file format that enables more features.

The file format is a very simple petscii format that can be created and edited with standard C64 text editors like Novatext.

# File format
Presentation files are sequence files that are required to have the '.prs' file extension.
The bulk of a presentation file consists of standard petsii text.

## Comment section

At the start of a presentation it is allowed to include a text segment that provides comments about the presentation. This can be any text of any lenght. This segment is closed by the first __!s__\<CR\> command. This must be the first command of each presentation file.

## Fields
The presenter app supports 'fields' that can be used to add short (max 40 character) reusable text fragments that can be added anywhere in the content of a slide with the __!Fff__ command described in the chapter [[#Slides]].

There are three types of fields:
1. User defined fields
2. Dynamic fields

User defined fields have to be explicitely specified in using the __!Dff__ command. 
The values of dynamic fields are automatically generated by the presenter app when they are encountered in a slide.

### User defined fields
These fields can be defined by the creator of the presentation. This is done by using the __!dff__ command (typically immediately after a __!S__ command). The 'names' can be at most two characters long. A total of 64 fields can be defined. Fields can contain any command except **!dff** (it is not possible to recursively define fields and all field definitions live in a single global namespace).
It *is* possible to nest the usage of fields inside of fields. Currently the maximum depth is 8 levels of nesting.
If a field is defined that was already defined earlier in the flow of the presentation (including before stepping back a few slides), it will simply be overwritten. So if you want to make sure you control the value of a field in a specific slide you have to make sure you set it at the start of the slide itself and not rely on it having been set in a previous slide.

The following fields are 'standard' by convention: 
* __TI__: Title, this field is used to contain the title of the presentation
* __ST__: Section title, this field is used to contain the title of a section of slides. 
* __AU__: Author, this is field is used to contain the name of the author of the presentation
* __CD__: Creation Date, this field is used to contain the creation date of the presentation

One way to allow for one more field is by using either the __TI__ or __ST__ field for both the title of the presentation and the title of a section of slides (if both titles are not used at the same time anywhere).
### Dynamic fields (will be available in later version)
These fields are always available and don't need any definition. Do note that these are really regular fields and are set automatically at specific points during the use of the Presenter. This means that they can be overwritten like any other field, so if you don't want this make sure you don't but it also allows you to reclaim the field names if you don't need the 'automatic' values

The following dynamic (automatic) fields are defined:
- **PV**: Presenter (application) Version, set at the start of the presentation. 
- __PD__: Presentation date, which is the current date when the presentation is started.
* **PN**: Presentation file name at the time of loading the presentation.
- **SN**: Number of the current slide starting at 1, increased when progressing to the next slide, decreased when returning to the previous slide.

## Slides
The bulk of a slide's content consists of standard petsii text. In addition to this a set of commands can be used that are always prefixed with an '!' (to have an ! in the output just use !! in the slide content).

The following commands are supported:
* __!s__\<CR\>: Start of a new slide/section. This command pauses the presentation, and when 'Next' is triggered, will clear the screen and start any new content from the top-left of the screen. Note that this command needs to end with a CR (carriage return).
* **!p**\<CR\>: Pause the current slide. This command pauses the presentation and when 'Next' is triggered, will continue any new content at the paused position.
* **!c**xx: Changes the text color. It requires a two digit decimal number, between 0 and 15, immediately after the command.
* **!b**xx: Changes the background color. It requires a two digit decimal number, between 0 and 15, immediately after the command. This command is mostly useful right after a __!s__ or __!p__ command. In the latter scenario it allows for changing background color after each pause, note that the full screen background is changed.
* **!l**xxyy: Changes the ouput location. This command requires a two digit decimal numbers, the first for the new X coordinate (or column) the second for the new Y coordinate (or row). Note that as the screen has a resolution of 40x25 characters these values have to be between 0-39 and 0-24 respectively.
* **!w**xxyy: Changes the output 'window'. This command is very similar to the **!l**xxyy command. However, it also 'remembers' the x-coordinate for any new lines following its use. This is very useful for adding 'windows' or 'blocks' of content to a slide, when combined with the __!p__ can be used creatively for 'builds' or 'animations' of 'blocks' of content anywhere in the slide while keeping the content 'around' it constant.
* **!i**xx: Set the output 'indent' to possition xx. This command requires a two digit decimal number, between 0, 38 (the new start column). This command is similar to the **!h**xxyy command but it only sets the indent for new lines in the output. It can also be used there for to reset the indent after a **!h**xxyy to zero.
* **!d**ff\<value\>**!e**: Defines a value for a template field specified by a two character 'name' (ff). This command is typically used directly after a __!s__ command to define (new) field values that can be used in the slide/section following that command. Note that the definition of a field needs to end with an **!e** command.
* **!f**ff: Is replaced by the value of the template field specified by the two character 'name' (ff). These fields are described in chapter [[#Header]] (above).
* **!mi**\<cmd\>\<CR\>: _(will be available in a later version)_ Adds image media support to presentations.  Note that this command needs to end with a CR (carriage return). The __!mi__ needs to be followed (before the CR) by a sub-command (\<cmd\>):
  * **!mil**\<path\>: Loads a image file, specified with \<path\>, to the graphics screen. 
  * **!mi**s: Show the currently loaded image (if available).
  * **!mi**h: Hide the currently loaded image and therefore show the current slide again.
* **!ms**\<cmd\>\<CR\>: _(will be available in a later version)_ Adds SID music support to presentations. Note that there because of memory limits, SID files have to be relatively small to work inside a presentation. Note that this command has no visual impact on the slide. Note that this command needs to end with a CR (carriage return). The __!ms__ needs to be followed (before the CR) by a sub-command (\<cmd\>):
  *  **!ms**l\<path\>: Loads a SID file, specified with \<path\>. 
  *  **!ms**sxx: Sets the playhead to the start of a numbered soung, using xx = 0 this returns the 'play head' to the start of the SID file.
  *  **!ms**pss?: Starts playing the currently loaded SID file. It can optionally specify a maximum number of seconds to play the song.
  *  **!ms**e: Stops playing the currently playing SID file.
* __!e__: Ends a field definition or the complete presentation.