#!/usr/bin/env bash

entities=$(./ha_state.sh -l | grep "$1")

for entity in $entities; do
  state=$(./ha_state.sh -e $entity | jq -r ".$2")
  echo $entity $state
done

