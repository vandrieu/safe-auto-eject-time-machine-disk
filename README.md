# The problem I had

As a rather absent-minded guy, I often undock my MacBook (from its external monitors and external devices) without thinking my external hard drive might be on.

I killed my last Time Machine external disk because of this.

# The solution that suits me

The script in this repo does this:

If a Time Machine backup has already been done for today, then the disk is ejected/unmonted for the day.

# Pseudo code

Every minute (using crontab), do:
1. If a Time Machine backup is currently running, then do nothing and exit.
2. Else, if a Time Machine backup has not been done yet for the current day, then start the backup (it's an async command) and exit.
3. Else, unmount and eject the disk.

