import? "../justfile"
result_dir := proot+"/results/"

reconf:
    #!/usr/bin/env bash
    mkdir -p {{result_dir}}
    echo "system,time" > {{result_dir}}/reconf.csv
    just vm-linux > /dev/null 2> /dev/null &
    sleep 30
     
    for i in `seq 1 {{rep}}`
    do 
        just ssh "./reconf/reconf" | grep "Run Time" | awk '{printf "Linux,%.3f\n", $3*1000;}' >> {{result_dir}}/reconf.csv
    done

    just ssh "poweroff"

    sleep 2

    rm -f .config.sqlite_qemu-x86_64
    kraft build --env QUERYFILE="/queries/q1.1.sql" -K Kraftfile_unikraft
    for i in `seq 1 {{rep}}`
    do 
        touch {{result_dir}}/tmp_bpftrace
        sudo -E bpftrace -e 'tracepoint:kvm:kvm_entry / @a[pid] == 0 / { printf("qemu kvm entry ns %lld ", nsecs()); @a[pid]=1;} tracepoint:kvm:kvm_pio / args.port == 0xf4 / { printf("qemu kvm port %d ns %lld\n", args->val, nsecs()); }' -c "just vm-unikraft" -o {{result_dir}}/tmp_bpftrace 
        cat {{result_dir}}/tmp_bpftrace | grep "port 255" | awk '{ printf "Unikraft,%.3f\n", ($11 - $5)/1000000;}' >> {{result_dir}}/reconf.csv
        rm {{result_dir}}/tmp_bpftrace
    done

    sleep 2

    rm -f .config.sqlite_qemu-x86_64
    kraft build --env QUERYFILE="/queries/q1.1.sql" -K Kraftfile_cirrus

    for i in `seq 1 {{rep}}`
    do 
        just vm-unikraft | grep "Reconfiguration time" | awk '{printf "Cirrus,%.3f\n", $5/1000000;}' >> {{result_dir}}/reconf.csv
    done
