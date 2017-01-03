# General library for Bash shell script (0.5.1)

A collection of handy functions for the shell script writing, it aims for Bash 3+.

* [Prerequisite](#prerequisite)
* [Modules](#modules)
* [Configuration](#configuration)
  * [Debug mode](#debug-mode)
  * [Error message colors](#error-message-colors)
  * [Information message color](#information-message-color)
  * [Question message color](#question-message-color)
* [Error codes](#error-codes)
* [Version History](#version-history)

## Prerequisite

Some features are based on [Perl5](https://www.perl.org) to implement (use for [PCRE](http://www.pcre.org/)).

## Modules

All modules are tested in macOS and linux.

Module | Description
----- | -----
[Command](doc/command.md) | Command/Function utility.
[Environment File](doc/env.md) | Environment file reader.
[Message](doc/message.md) | Show color message in shell.
[String](doc/string.md) | String manipulation.

## Configuration

The following environment variables can be used to configure the behaviour of the library.

### Debug mode

Set environment variable `LIB_BASH_DEBUG` to true to show error message in `stderr` when function get error.

### Error message colors

Set environment variable `LIB_BASH_ERROR_FG` and `LIB_BASH_ERROR_BG` to change the foreground and background color respectively of error message, default is white and red, see [ANSI escape code#Colors](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors).

### Information message color

Set environment variable `LIB_BASH_INFO_COLOR` to change the color of infomration message, default is green, see [ANSI escape code#Colors](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors).

### Question message color

Set environment variable `LIB_BASH_QUESTION_COLOR` to change the color of question message, default is cyan, see [ANSI escape code#Colors](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors).

## Error codes

All functions may return the following error codes.

Code | Error
----- | -----
3 | Invalid parameters.
4 | Invalid options.
5 | No outputs.
6 | File does not exist.

## Version History

### 0.1.0

* Add `get_option` to simulate the built-in function `getopt`.
