***************
fontpad2
***************

Minimum text editor for trying a font(.ttf) before installation.

This is a rewriten code of fontpad.rb_ for Ruby 2.x using Ruby/Tk and Fiddle,
instead of WxRuby and Win32API.

.. _ https://github.com/hashimoton/fontpad
===========
PLATFORMS
===========

Works on Windows 7

==============
REQUIREMENTS
==============

Ruby 2.x
RubyGems: Ruby/Tk, Fiddle, ttfunk

============
SETUP
============

Copy fontpad2.rb and icon.ico into your convenient directory.

I recommend you to create a shortcut with a link to::
  
  path/to/rubyw.exe path/to/fontpad2.rb

in your SendTo folder.

============
USAGE
============

::
  
  > ruby fontpad2.rb a_font_file.ttf


When with no font file, just displays a window.
Then click "Open" button to select a font file.

Once a font is opened,

* "+" button to increase font size
* "o" button to reset font size
* "-" button to decrease font size


===========
LICENSE
===========

Public Domain



.. EOF
