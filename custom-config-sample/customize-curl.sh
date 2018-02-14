#!/bin/bash
#
# An exemple if for a PoC you need to use an insecure curl connection.
#

shopt -s expand_aliases

alias curl="$(which curl) --insecure"
