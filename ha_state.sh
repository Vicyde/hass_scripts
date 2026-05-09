#!/usr/bin/env bash
#
# 09-05-2026
#
print_usage() {
  echo -e "usage: $0 [-i ID] [n] [h] [e] [l]"
  echo -e ""
  echo -e "-e ID - Show states of entity with id ID"
  echo -e "-h    - Show this information"
  echo -e "-l    - List entities only"
  echo -e "-t    - Home assistant API token"
  echo -e "-u    - Home assistant client URL"
  echo -e "-n    - Remove formatting from the output"
  exit 0
}

# Check if we have a token and url configured in ha_token.sh
if [ -f "ha_token.sh" ]; then
  source ha_token.sh
fi


while getopts "e:hlt:u:n" opt; do
  case $opt in
    e) ENTITY_ID=$OPTARG ;;
    n) NO_FORMAT=1 ;;
    l) LIST_ENTITIES=1 ;;
    t) TOKEN="$OPTARG" ;;
    u) URL="$OPTARG" ;;
    h) print_usage ;;
  esac
done

if [ -z "$URL" ]; then
  echo "Please specify your home assistant URL"
  exit 1
fi

if [ -z "$TOKEN" ]; then
  echo "Please specify your home assistant API token"
  exit 1
fi

if [ -z "$ENTITY_ID" ] || [ -n "$LIST_ENTITIES" ]; then
  POST_URL="$URL/api/states"
else
  POST_URL="$URL/api/states/$ENTITY_ID"
fi

STATES=$(curl -s POST "$POST_URL" -H "Authorization: Bearer $TOKEN")

if [ -n "$LIST_ENTITIES" ]; then
  echo $STATES | jq -r '.[].entity_id' | sort
  exit 0
fi

if [ -z "$NO_FORMAT" ]; then
  echo $STATES | jq
else
  echo $STATES
fi


