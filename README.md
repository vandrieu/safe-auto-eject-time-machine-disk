## The problem I had

I dock my MacBook (to external monitors and devices) every morning when I get to my office, and undock when I leave my office or when I go to a meeting in the middle of the day.
As a rather absent-minded guy, I often undock my MacBook without thinking my Time Machine external hard drive might be writing data.

I bricked my last Time Machine external disk because of this. ☠️

## The solution that suits me

As soon as the Time Machine external disk is plugged in, start a Time Machine backup (unless one was already done today in which case I skip it) and then eject the disk safely. ✅

This means when I undock my MacBook, even if I forget about my external disk, it probably ejected a long time ago, so the risk of damaging it is decreased a lot.

## Pseudo code

Every minute (using crontab), do:
1. Check if a Time Machine backup is currently running. If yes, do nothing and exit, else goto 2.
2. Check if the last Time Machine backup is older than today. If yes, start the backup (it's an async command) and exit, else, goto 3.
3. Unmount and eject the disk safely. The disk is powered off for the rest of the day.

## Installation

1. Get the script:

```
wget https://raw.githubusercontent.com/vandrieu/safe-auto-eject-time-machine-disk/main/time_machine_backup_and_eject.sh
```

2. Allow execution:

```
chmod +x time_machine_backup_and_eject.sh
```

3. Run `diskutil list` and look at the **`NAME`** column to find your disk name. It should **NOT** be the disk id such as `/dev/disk5`, it should be its full name (e.g. "TimeMachine" for me).

4. Change the `TIME_MACHINE_EXTERNAL_DISK_NAME` variable in the script to set your disk name.

4. Test the script:

```
./time_machine_backup_and_eject.sh
```

5. If the test worked (the script ejected the disk), then add it as a crontab job:

```
sudo crontab -e # (must use sudo else diskutil won't work)

* * * * *      /full/path/to/script/time_machine_backup_and_eject.sh >/dev/null 2>&1
```

## Caveats

This solution won't help you if your Time Machine external disk is almost always connected to your MacBook, because once the script ejects it, it will stay ejected as long as you don't plug it out and back in manually. Which means the backup will be less frequent, so they will run longer, so the risk you unplug your MacBook during a backup is high.

Also, even if the disk is ejected right after the backup is done, there is still a risk you decide to leave your office in the middle of the backup and damage the disk. That's why it's important to have it run at least once a day, so that the backup takes less time and the disk is running as little time as possible every day.

## Troubleshooting

**Error message:**
```
Failed to mount backup destination, error: Error Domain=com.apple.backupd.ErrorDomain Code=18 "Failed to mount destination." UserInfo={NSLocalizedDescription=Failed to mount destination.}
```
This means `tmutil latestbackup` couldn't run, which probably means your disk is unplugged/ejected. Plug it back in and test again.

---

**Error message:**
```
Could not find disk: <your disk name>
```
This means the disk name you set in the `TIME_MACHINE_EXTERNAL_DISK_NAME` variable is not right.

Try running this script to get a list of the available disk names:
```
header=$(diskutil list | grep "#:" | head -1)
name_pos=$(echo "$header" | awk '{print index($0, "NAME")}')
size_pos=$(echo "$header" | awk '{print index($0, "SIZE")}')
diskutil list | awk -v name_pos=$name_pos -v size_pos=$size_pos '
  /^[[:space:]]*[0-9]+:/ {
    name=substr($0, name_pos, size_pos - name_pos)
    gsub(/^ +| +$/, "", name)
    if (name != "" && name ~ /[a-zA-Z]/) {
      print name
    }
  }'
```
