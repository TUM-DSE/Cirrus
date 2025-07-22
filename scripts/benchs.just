import? "../justfile"
result_dir := proot+"/results/"

run_linux:
    #!/usr/bin/env bash
    mkdir -p {{result_dir}}

    just vm-linux > /dev/null 2> /dev/null &
    sleep 30

    echo "query,time" > {{result_dir}}/perf_linux.csv
    for i in `seq 1 {{rep}}`
    do 
        for q in 1.1 1.2 1.3 #2.1 2.2 2.3 3.1 3.2 3.3 3.4 4.1 4.2 4.3
        do
            just ssh "sqlite3 -cmd '.timer on' ssb.sqlite < queries/q$q.sql" | grep "Run Time" | awk -v query=$q '{printf "%s,%.3f\n", query, $4;}' >> {{result_dir}}/perf_linux.csv
            sleep 3
        done
    done 

    just ssh "shutdown now"

run_unikraft:
    #!/usr/bin/env bash
    mkdir -p {{result_dir}}

    cd {{proot}}/..
    echo "query,time" > {{result_dir}}/perf_unikraft.csv
    for i in `seq 1 {{rep}}`
    do
        for q in 1.1 1.2 1.3
        do
            rm -f .config.sqlite_qemu-x86_64
            kraft build --env QUERYFILE="/queries/q$q.sql" -K Kraftfile_unikraft
            just vm-unikraft | grep "Run Time" | awk -v query=$q '{printf "%s,%.3f\n", query, $3;}'  >> {{result_dir}}/perf_unikraft.csv
            sleep 3
        done
    done

run_cirrus:
    #!/usr/bin/env bash
    mkdir -p {{result_dir}}

    cd {{proot}}/..
    echo "query,time" > {{result_dir}}/perf_cirrus.csv
    for i in `seq 1 {{rep}}`
    do
        for q in 1.1 1.2 1.3
        do
            rm -f .config.sqlite_qemu-x86_64
            kraft build --env QUERYFILE="/queries/q$q.sql" -K Kraftfile_cirrus
            just vm-unikraft | grep "Run Time" | awk -v query=$q '{printf "%s,%.3f\n", query, $3;}'  >> {{result_dir}}/perf_cirrus.csv
            sleep 3
        done
    done
