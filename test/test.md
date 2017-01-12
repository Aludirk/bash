# Testing Guideline

For every function in the Bash library, the following key points should be tested.

## Special Characters

The following special characters should be tested:

* `"`
* `\`
* `$`
* `@`
* `\n`
* trailing `\n`
* `''` (empty string, if it is a valid input)

## Function Success

The return code `0` should be checked, and make sure no output message on success case except the function intents to show output.

## Function Errors

Every error code from the function should be confirmed.
