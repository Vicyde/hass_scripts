#!/usr/bin/env bash

#
# 09-05-2026
#
function print_usage {
  echo "usage: $0 -a ACTION -e ENTITY_ID [-t TOKEN] [-u URL]"
  echo
  echo -e "-a ACTION    - A home-assistant action to perform"
  echo -e "-e ENTITY_ID - Entity to perform action on"
  echo -e "-s JSON      - Extra attributes to send, in JSON format"
  echo -e "-t TOKEN     - Home assistant API token"
  echo -e "-u URL       - URL to home assistant client"
  echo -e "-h           - Show this information"
  echo -e "-v           - Verbose mode"
  echo
  echo -e "A token and url can also be stored in ha_token.sh"
  exit 0
}

# Check if we have a token and url configured in ha_token.sh
if [ -f "ha_token.sh" ]; then
  source ha_token.sh
fi

while getopts "a:e:s:t:u:hv" opt; do
  case $opt in 
    a) ACTION="$OPTARG" ;;
    e) ENTITY_ID="$OPTARG" ;;
    s) ATTRIBUTES="$OPTARG" ;;
    t) TOKEN="$OPTARG" ;;
    u) URL="$OPTARG" ;;
    h) print_usage ;;
    v) VERBOSE_MODE=1 ;;
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

if [ -z "$ACTION" ]; then
  echo "No action given."
  echo
  print_usage
  exit 1
fi

if [ -z "$ENTITY_ID" ]; then
  echo "No entity specified."
  echo
  print_usage
  exit 1
fi

# Build JSON
JSON="{ \"entity_id\": \"$ENTITY_ID\"" 
if [ -n "$ATTRIBUTES" ]; then
  JSON+=",$ATTRIBUTES"
fi
JSON+="}"

if [ -n "$VERBOSE_MODE" ]; then
  echo "Performing $ACTION on $ENTITY_ID with the following JSON: "
  echo $JSON | jq
fi

curl -s -X POST "$URL/api/services/$ACTION" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d "$JSON" \

