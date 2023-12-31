#!/bin/bash

PORT_API_URL="https://api.getport.io/v1"

check_port_credentials() {
    clientId=$1
    clientSecret=$2
    echo "Checking Port credentials!"
    echo ""
    if [[ -z "${clientId}" ]] || [[ -z "${clientSecret}" ]]
    then
        echo "PORT_CLIENT_ID or PORT_CLIENT_SECRET variables are not defined"
        exit 1
    fi

    response_code=$(curl -w "%{http_code}" -s -o /dev/null -X POST "${PORT_API_URL}/auth/access_token" \
        --header 'Content-Type: application/json' \
        --data-raw "{\"clientId\": \"${clientId}\", \"clientSecret\": \"${clientSecret}\"}")

    if [[ ${response_code} != "200" ]]; then
        echo "PORT_CLIENT_ID or PORT_CLIENT_SECRET are invalid, could not authenticate with Port API."
        exit 1
    fi

    echo "Port credentials are valid!"
    echo ""
}

upsert_port_entity() {
    clientId=$1
    clientSecret=$2
    blueprint=$3
    entity=$4

    accessToken=$(curl -s -X POST "${PORT_API_URL}/auth/access_token" \
        --header 'Content-Type: application/json' \
        --data-raw "{\"clientId\": \"${clientId}\", \"clientSecret\": \"${clientSecret}\"}" | jq -r ".accessToken")

    response_code=$(curl -w "%{http_code}" -s -o /dev/null -X POST "${PORT_API_URL}/blueprints/${blueprint}/entities?upsert=true&merge=true" \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer ${accessToken}" \
        --data-raw "${entity}")

    if [[ ${response_code} != "201" ]]; then
        echo "Upsert entity: '${entity}', to blueprint: '${blueprint}' failed, status code: ${response_code}"
        return 1
    fi

    echo "Upsert entity: '${entity}' to blueprint: '${blueprint}' succeeded"
    return 0
}

# Accepts list of strings and ensures each string is a valid command
check_commands () {
    for cmd in "$@"; do
        if ! command -v "${cmd}" &> /dev/null
        then
            echo "${cmd} could not be found"
            exit 1
        else
            echo "${cmd} command found!"
        fi
    done
    echo "All needed commands found"
}

save_endpoint_to_file() {
  endpoint=$1
  filename=$2
  response=$(curl -s -w "%{http_code}" "$endpoint" -o "$filename")

  if [[ "${response}" -ne 200 ]]; then
    echo "Error: Failed to get file ${endpoint}, status code: $response"
    rm "$filename" 2>/dev/null
    return 1
  fi

  echo "HTTP request succeeded, response saved to $filename"
  return 0
}

cloudformation_tail() {
  local stack="$1"
  local lastEvent
  local lastEventId
  local stackStatus

  stackStatus=$(aws cloudformation describe-stacks --stack-name "$stack" | jq -c -r .Stacks[0].StackStatus)

  until \
	[ "$stackStatus" = "CREATE_COMPLETE" ] \
	|| [ "$stackStatus" = "CREATE_FAILED" ] \
	|| [ "$stackStatus" = "DELETE_COMPLETE" ] \
	|| [ "$stackStatus" = "DELETE_FAILED" ] \
	|| [ "$stackStatus" = "ROLLBACK_COMPLETE" ] \
	|| [ "$stackStatus" = "ROLLBACK_FAILED" ] \
	|| [ "$stackStatus" = "UPDATE_COMPLETE" ] \
	|| [ "$stackStatus" = "UPDATE_ROLLBACK_COMPLETE" ] \
	|| [ "$stackStatus" = "UPDATE_ROLLBACK_FAILED" ]; do

	lastEvent=$(aws cloudformation describe-stack-events --stack "$stack" --query 'StackEvents[].{ EventId: EventId, LogicalResourceId:LogicalResourceId, ResourceType:ResourceType, ResourceStatus:ResourceStatus, Timestamp: Timestamp }' --max-items 1 | jq .[0])
	eventId=$(echo "$lastEvent" | jq -r .EventId)
	if [ "$eventId" != "$lastEventId" ]
	then
		lastEventId=$eventId
		echo "$lastEvent" | jq -r '.Timestamp + "\t-\t" + .ResourceType + "\t-\t" + .LogicalResourceId + "\t-\t" + .ResourceStatus'
	fi
	sleep 3
	stackStatus=$(aws cloudformation describe-stacks --stack-name "$stack" | jq -c -r .Stacks[0].StackStatus)
  done

  echo "Stack Status: $stackStatus"
}

trigger_continue_prompt() {
    read -p "Do you want to continue? (y/n) " answer
    if [[ "$answer" == [yY] ]]; then
        echo "Continuing..."
    else
        echo "Exiting..."
        exit 0
    fi
}

check_path_or_url() {
    if [[ -f $1 ]]; then
        echo "local"
    elif [[ $1 =~ ^https?:// ]]; then
        echo "url"
    else
        echo "none"
    fi
}

post_port_blueprint() {
    clientId=$1
    clientSecret=$2
    blueprint=$3

    blueprint_id=$(echo ${blueprint} | jq -r .identifier)

    accessToken=$(curl -s -X POST "${PORT_API_URL}/auth/access_token" \
        --header 'Content-Type: application/json' \
        --data-raw "{\"clientId\": \"${clientId}\", \"clientSecret\": \"${clientSecret}\"}" | jq -r ".accessToken")

    response_code=$(curl -w "%{http_code}" -s -o /dev/null -X POST "${PORT_API_URL}/blueprints" \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer ${accessToken}" \
        --data-raw "${blueprint}")

    if [[ ${response_code} == "409" ]]; then
        echo "Blueprint \"${blueprint_id}\" already exists! Continuing..."
        return 0
    elif [[ ${response_code} != "201" && ${response_code} != "200" ]]; then
        echo "Create blueprint: \"${blueprint_id}\" failed, status code: ${response_code}"
        return 1
    fi

    echo "Create blueprint: \"${blueprint_id}\" succeeded"
    return 0
}