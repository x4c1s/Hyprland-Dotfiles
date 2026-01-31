#!/bin/bash

if [ -z "$1" ]; then
  echo "[!] Provide a word"
  exit 1
fi

RESP=$(curl -s -q https://api.dictionaryapi.dev/api/v2/entries/en/$1 | jq -r '
  [.[0].meanings[]
    | select(.partOfSpeech=="noun")
    | .definitions[].definition][0:2]
  | to_entries
  | map("\(.key + 1). \(.value)")
  | join("\n")
' 2>/dev/null)

if [ -z "$RESP" ]; then
  notify-send -t 10000 -u normal -i accessories-dictionary "Meaning Not Found!"
else
  notify-send -t 10000 -u normal -i accessories-dictionary "$1" "$RESP"
fi

