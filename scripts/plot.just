import? "../justfile"
result_dir := proot+"/results/"

plots:
    #!/usr/bin/env bash
    python footprint.py -W 1.5 -H 1.5 -f {{result_dir}}/footprint.pdf
