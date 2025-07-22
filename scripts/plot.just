import? "../justfile"
result_dir := proot+"/results/"

plots:
    #!/usr/bin/env bash
    python footprint.py
    python perf.py
    python reboot_times.py
