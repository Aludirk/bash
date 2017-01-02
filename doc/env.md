# Module - Environment file reader.

Reader for key-value environment variables file.

* [load_env_file](#load_env_file)

## load_env_file

```
################################################################################
# Extract the key-value pairs in the given file as environment variables.
#
# Usage: load_env_file <file>
#
# Parameters:
#   file [in] The environment file.
#
# Returns:
#   ${LIB_BASH_ERROR_FILE_NOT_EXIST}
################################################################################
```

Example:
```
# config.env

TEST_STRING_A="ABC"
TEST_STRING_B="DEF"
TEST_NUMBER_A=10
TEST_NUMBER_B=5354
```
```bash
load_env_file "config.env"

echo "${TEST_STRING_A}"
echo "${TEST_STRING_B}"
echo ${TEST_NUMBER_A}
echo ${TEST_NUMBER_B}
###
# ABC
# DEF
# 10
# 5354
###
```
