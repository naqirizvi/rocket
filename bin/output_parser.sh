#!/bin/bash

parse_output() {
  case $1 in
    "extension_activate")
      if [[ $2 == *"No such extension"* ]]; then
        echo "No such extension exist"
        exit 1
      else
        echo "Extension activated"
        exit 0
      fi
      ;;
    "extension_deactivate")
      if [[ $2 == *"No such extension"* ]]; then
        echo "No such extension exist"
        exit 1
      else
        echo "Extension Deactivated"
        exit 0
      fi
      ;;

    "version")
      echo '0.0.1';
    ;;

    *)
      echo "Invalid input"
      exit 1
      ;;
  esac
}

parse_output "$1" "$2"
