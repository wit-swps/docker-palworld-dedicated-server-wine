# shellcheck disable=SC2148

function save_and_shutdown_server() {
    rconcli 'broadcast Server-shutdown-was-requested-init-saving'
    rconcli 'save'
    rconcli 'broadcast Done-saving-server-shuts-down-now'
}

function broadcast_automatic_restart() {
    time=$(date '+%H:%M:%S')

    for ((counter=1; counter<=15; counter++)); do
		if [[ $RCON_QUIET_RESTART == false ]]; then
			rconcli "broadcast ${time}-AUTOMATIC-RESTART-IN-$counter-MINUTES"
		fi
		sleep 1
    done
	if [[ $RCON_QUIET_RESTART == false ]]; then
		rconcli 'broadcast Saving-world-before-restart...'
	fi
    rconcli 'save'
    rconcli 'broadcast Saving-done'
    if [[ $RCON_QUIET_BACKUP == false ]]; then
		rconcli 'broadcast Creating-backup'
    fi
	rconcli "Shutdown 10"
}

function broadcast_backup_start() {
    time=$(date '+%H:%M:%S')

    if [[ $RCON_QUIET_SAVE == false ]]; then
		rconcli "broadcast ${time}-Saving-in-5-seconds"
    fi
    sleep 5
	if [[ $RCON_QUIET_SAVE == false ]]; then
		rconcli 'broadcast Saving-world...'
	fi
    rconcli 'save'
	if [[ $RCON_QUIET_SAVE == false ]]; then
		rconcli 'broadcast Saving-done'
	fi
	if [[ $RCON_QUIET_BACKUP == false ]]; then
		rconcli 'broadcast Creating-backup'
	fi
}

function broadcast_backup_success() {
	if [[ $RCON_QUIET_BACKUP == false ]]; then
		rconcli 'broadcast Backup-done'
	fi
}

function broadcast_backup_failed() {
    rconcli 'broadcast Backup-failed'
}

function broadcast_player_join() {
    time=$(date '+%H:%M:%S')
    rconcli "broadcast ${time}-$1-joined-the-server"
}

function broadcast_player_name_change() {
    time=$(date '+%H:%M:%S')
    rconcli "broadcast ${time}-$1-renamed-to-$2"
}

function broadcast_player_leave() {
    time=$(date '+%H:%M:%S')
    rconcli "broadcast ${time}-$1-left-the-server"
}

function check_is_server_empty() {
    num_players=$(rcon -c "$RCON_CONFIG_FILE" showplayers | tail -n +2 | wc -l)
    if [ "$num_players" -eq 0 ]; then
        return 0  # Server empty
    else
        return 1  # Server not empty
    fi
}