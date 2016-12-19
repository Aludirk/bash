# General library for Bash shell script (0.1.0)

A collection of handy functions for the shell script writing, it aims for Bash 3+.

* [Modules](#modules)
* [Configuration](#configuration)
  * [Debug mode](#debug-mode)
  * [Error message colors](#error-message-colors)
* [Error codes](#error-codes)

## Modules

All modules are tested in macOS and linux.

Module | Description
----- | -----
[Command](doc/command.md) | Command/Function utility.

## Configuration

The following environment variables can be used to configure the behaviour of the library.

### Debug mode

Set environment variable `LIB_BASH_DEBUG` to true to show error message in `stderr` when function get error.

### Error message colors

Set environment variable `LIB_BASH_ERROR_FG` and `LIB_BASH_ERROR_BG` to change the foreground and background color respectively of error message, default is white and red, see [ANSI escape code#Colors](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors).

## Error codes

All functions may return the following error codes.

Code | Error
----- | -----
3 | Invalid parameters.
4 | Invalid options.
5 | No outputs.
