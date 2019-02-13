#!/bin/bash

# Notification engine: pushover
# This tool allows the client to send notifications to a user/group using pushover.
# It's good for mobile devices and lets you send images as well if needed.  Great when
# You are monitoring just a few hosts and want to see when they do things.
#

# How to use:
# pushover.sh <config file> <message> <attachment>
# 	<config file>
# 	The config file contains the client key to use, and group you need to send to
#	Example:
#		user_key=abc1234
#		send_group=qwertyuiop12345
#	
#	Notes: 
#		- The 'group' key can be just a single user, but why not use a pushover group and
#       invite some friends?
#       - Pushover has a limit in image attachment to a couple megabytes, so be aware of that
#

# Get our config and options
config_file="$1"
message="$2"
attachment="$3"

# Sanity check
if [ -z "$1" ]; then
    echo "ERROR: no config file specified" 1>&2
    exit 1
fi

if [ -z "$2" ]; then
    echo "ERROR: no message specified" 1>&2
    exit 2
fi

# If we don't have an attachment, that's fine, they're not required.

# read in the config file, then check the variables
source "$config_file"

if [ -z "$user_key" ]; then
    echo "ERROR: user key not specified" 1>&2
    return 3
fi

if [ -z "$send_group" ]; then
    echo "ERROR: no group to send to" 1>&2
    return 4
fi

# If we have an attachment, prep the curl option for it.
if [ -n "$attachment" ]; then
	curl_options="-F attachment=@$attachment"
else
	curl_options=''
fi

# Send notification to C&C
curl -s --form-string "token=$user_key" --form-string "user=$send_group" --form-string "message=$message" $curl_options https://api.pushover.net/1/messages.json &> /dev/null
