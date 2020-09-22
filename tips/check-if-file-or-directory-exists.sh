#!/bin/sh
echo "Finding $1..."

if [ -e $1 ]; then
  echo "$1 found."
else
  echo "$1 not found."
fi

#check if it does not exist

#if [ ! -e $1 ]; then
#  echo "$1 found."
#else
#  echo "$1 not found."
#fi
