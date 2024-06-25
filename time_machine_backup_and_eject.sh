#!/bin/bash
set -e

# Run `diskutil list` to find your Time Machine disk name
TIME_MACHINE_EXTERNAL_DISK_NAME="TimeMachine"

# -----------------------------------------------
# Make sure Time Machine is not currently running
# -----------------------------------------------

is_running=$(tmutil status | grep Running | grep -oE '[0-9]+')

if [[ $is_running -ne '0' ]]; then
  echo "Time Machine backup currently running..."
  exit 0
fi

# -----------------------------------------------
# If a backup was not yet done today, launch it and exit
# -----------------------------------------------

last_backup_date=$(tmutil latestbackup | xargs basename | grep -oE '^\d{4}-\d{2}-\d{2}')
today=$(date '+%Y-%m-%d')
if [[ $last_backup_date != $today ]]; then
  echo "Latest backup is not from today, launching a new backup now."
  tmutil startbackup
  exit 0
fi
echo "A backup was already done today."

# -----------------------------------------------
# Unmount and eject the external disk
# -----------------------------------------------

echo "Ejecting disk..."
echo "Identifying $TIME_MACHINE_EXTERNAL_DISK_NAME disk..."
disk=$(/usr/sbin/diskutil info "$TIME_MACHINE_EXTERNAL_DISK_NAME" | grep "Device Node" | grep -oE '/dev/disk[a-z0-9]+')
if [ -z $disk ]; then
  echo "$TIME_MACHINE_EXTERNAL_DISK_NAME disk not found."
  exit 1
fi
echo "Unmounting ${disk}..."
/usr/sbin/diskutil unmount $disk
sleep 5
echo "Ejecting ${disk}..."
/usr/sbin/diskutil eject $disk

echo "Done."
