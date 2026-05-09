# HASS Scripts

A few scripts for controlling home assistant devices

It is suggested to create a file "ha_token.sh" with the following it it:

```
TOKEN="your home assistant token"
URL="your home assistant url"
```

## ha_state.sh
Get's current state information from an entity. Also able to list all entities.

To list all entities use

```
ha_state.sh -l
```

To get information on a specific entity, use

```
ha_state.sh -e light.bathroom
```

## ha_cmd.sh
Sends a command to an entity.

For example, to turn on a light use:

```
sh_cmd.sh -e light.bathroom -a homeassistant/toggle
```

## get_attribute.sh

Iterates over a list from filtered devices, and shows the specified attribute for all of them.

To see the state of all lights, use:

```
get_attribute.sh "^light" "state"
```

The first argument is passed to grep over the results from 'ha_state.sh -l'.
