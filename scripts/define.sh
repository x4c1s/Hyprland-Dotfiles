#!/bin/bash

if [ -z "$1" ]; then
  echo "[!] Provide a word"
  exit 1
fi

trans :en "$1"
