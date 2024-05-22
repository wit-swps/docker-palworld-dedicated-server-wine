#!/bin/bash
# shellcheck disable=SC1091

set -e

source /includes/colors.sh
source /includes/server.sh
source /includes/webhook.sh

function schedule_restart() {
    ew ">>> Automatic restart was triggered..."
    PLAYER_DETECTION_PID=$(<${GAME_ROOT}/PLAYER_DETECTION.PID)
    if [[ -n $WEBHOOK_ENABLED ]] && [[ $WEBHOOK_ENABLED == "true" ]]; then
        send_restart_planned_notification
    fi
	
	if [[ $RESTART_COUNTDOWN =~ ^[0-9]+$ ]]; then
		ei "> Restart countdown set to $RESTART_COUNTDOWN minutes"
		countdown=$RESTART_COUNTDOWN
	else
		ew ">> RESTART_COUNTDOWN value invalid, setting countdown to 15 minutes"
		countdown=15
	fi

    for ((counter=$countdown; counter>=1; counter--)); do
        if [[ -n $RCON_ENABLED ]] && [[ $RCON_ENABLED == "true" ]]; then

            if check_is_server_empty; then
                ew ">>> Server is empty, restarting now"
                if [[ -n $WEBHOOK_ENABLED ]] && [[ $WEBHOOK_ENABLED == "true" ]]; then
                    send_restart_now_notification
                fi
                break
            else 
                ew ">>> Server has still players"
            fi
			if [[ $RCON_QUIET_RESTART == false ]]; then
				time=$(date '+%H:%M:%S')
				rconcli "broadcast ${time}-AUTOMATIC-RESTART-IN-$counter-MINUTES"
		    fi
        fi
        if [[ -n $RESTART_DEBUG_OVERRIDE ]] && [[ $RESTART_DEBUG_OVERRIDE == "true" ]]; then
            sleep 1
        else
            sleep 60
        fi 
    done

    if [[ -n $RCON_ENABLED ]] && [[ $RCON_ENABLED == "true" ]]; then
        if [[ $RCON_QUIET_SAVE == false ]]; then
			rconcli 'broadcast Saving-world-before-restart...'
        fi
		rconcli 'save'
		if [[ $RCON_QUIET_SAVE == false ]]; then
			rconcli 'broadcast Saving-done'
        fi
		sleep 15
		kill -SIGTERM "${PLAYER_DETECTION_PID}"
		rconcli "Shutdown 10"

        if [[ -n $WEBHOOK_ENABLED ]] && [[ $WEBHOOK_ENABLED == "true" ]]; then
            send_stop_notification
        fi
    else
        ew ">>> Stopping server..."
        if [[ -n $WEBHOOK_ENABLED ]] && [[ $WEBHOOK_ENABLED == "true" ]]; then
            send_stop_notification
        fi
        kill -SIGTERM "$(pidof start.exe)"
        tail --pid="$(pidof start.exe)" -f 2>/dev/null
		kill -SIGTERM "${PLAYER_DETECTION_PID}"
		ew ">>> Server stopped gracefully"
        exit 143;
    fi
}

schedule_restart