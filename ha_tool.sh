#!/usr/bin/env bash

print_usage() {
    echo -e "Usage: $0"
    echo -e "-a ACTION - Perform specified ACTION"
    echo -e "-e ID     - Show or command entity with ID"
    echo -e "-s JSON   - Extra attribute to send, in JSON format"
    echo -e "-t TOKEN  - Home assitant API-token"
    echo -e "-u URL    - Home assistant client url"
    echo -e "-n        - No formatting"

    exit 0
}

get_state() {
    local POST_URL
    local EID=$1

    if [ -z "$EID" ]; then
        POST_URL="$URL/api/states"
        echo $(curl -s POST "$POST_URL" -H "Authorization: Bearer $TOKEN")
    else
        local OUTPUT=""
        for ENTITY in $EID; do
            POST_URL="$URL/api/states/$ENTITY"
            OUTPUT+=$(curl -s POST "$POST_URL" -H "Authorization: Bearer $TOKEN")
        done
        echo $OUTPUT
    fi
}

send_command() {
    local ACTION="$1"
    local EID="$2"
    local ATTRIBUTES="$3"
    local JSON

    if [ -z "$ACTION" ]; then
        echo "No action specified"
        return 1
    fi

    if [ -z "$EID" ]; then
        echo "No entity ID specified"
        return 1
    fi

    for ENTITY in $ENTITY_ID; do
        JSON="{ \"entity_id\": \"$ENTITY\""
        if [ -n "$ATTRIBUTES" ]; then
            JSON+=",$ATTRIBUTES"
            fi
        JSON+="}"

        curl -s -X POST "$URL/api/services/$ACTION" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$JSON"
    done
}

# Check if we have a token file and import it
if [ -f "ha_token.sh" ]; then
    source ha_token.sh
fi

while getopts "a:e:ns:t:u:" opt; do
    case $opt in
        a) ACTION=$OPTARG ;;
        e) ENTITY_ID=$OPTARG ;;
        n) NO_FORMATTING="y" ;;
        s) ATTRIBUTES=$OPTARG ;;
        t) TOKEN=$OPTARG ;;
        u) URL=$OPTARG ;;
    esac
done

# Parse command line arguments
if [ -z "$URL" ]; then
    echo "Please specify your home assistant URL."
    exit 1
fi

if [ -z "$TOKEN" ]; then
    echo "Please specify your home assistant API-token"
    exit 1
fi

if [ -z "$ACTION" ]; then
    OUTPUT=$(get_state "$ENTITY_ID")
else
    OUTPUT=$(send_command "$ACTION" "$ENTITY_ID" "$ATTRIBUTES")
fi

if [ -n "$NO_FORMATTING" ] || [ -n "$ACTION" ]; then
    echo $OUTPUT
else
    echo $OUTPUT | jq
fi
