#!/bin/sh
echo "Finding $1..."

if which $1 >/dev/null 2>&1; then
  echo "$1 found."
else
  echo "$1 not found."
fi
