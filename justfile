proot := justfile_directory()
qemu_ssh_port := "2222"
user := `whoami`
sf := "1"
smp := "1"
mem := "10G"
rep := "3"

default:
    @just --choose

help:
    just --list

ssh COMMAND="":
    ssh \
    -i {{proot}}/nix/ssh_key \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o IdentityAgent=/dev/null \
    -F /dev/null \
    -p {{qemu_ssh_port}} \
    root@localhost -- "{{COMMAND}}"

vm-linux EXTRA_CMDLINE="" :
    sudo taskset -c 0 qemu-system-x86_64 \
        -cpu host \
        -smp {{smp}} \
        -enable-kvm \
        -m {{mem}} \
        -machine q35,accel=kvm,kernel-irqchip=split \
        -device intel-iommu,intremap=on,device-iotlb=on,caching-mode=on \
        -device virtio-serial \
        -fsdev local,id=home,path={{proot}}/shared_dir,security_model=none \
        -device virtio-9p-pci,fsdev=home,mount_tag=home,disable-modern=on,disable-legacy=off \
        -fsdev local,id=nixstore,path=/nix/store,security_model=none \
        -device virtio-9p-pci,fsdev=nixstore,mount_tag=nixstore,disable-modern=on,disable-legacy=off \
        -drive file={{proot}}/VMs/guest-image.qcow2 \
        -net nic,netdev=user.0,model=virtio \
        -netdev user,id=user.0,hostfwd=tcp:127.0.0.1:{{qemu_ssh_port}}-:22 \
        -nographic

vm-image-init:
    #!/usr/bin/env bash
    set -x
    set -e
    echo "Initializing disk for the VM"
    mkdir -p {{proot}}/VMs

    # build images fast
    overwrite() {
        install -D -m644 {{proot}}/VMs/ro/nixos.qcow2 {{proot}}/VMs/$1.qcow2
        qemu-img resize {{proot}}/VMs/$1.qcow2 +8g
    }

    nix build .#guest-image --out-link {{proot}}/VMs/ro
    overwrite guest-image

vm-unikraft:
    sudo taskset -c 0 qemu-system-x86_64 \
        -accel kvm -cpu host -smp {{smp}} \
        -m {{mem}} \
        -nodefaults -machine acpi=off -display none \
        -fsdev local,id=myid,path={{proot}}/shared_dir,security_model=none \
        -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
        -kernel .unikraft/build/sqlite_qemu-x86_64 \
        -serial stdio -device isa-debug-exit \
        -nographic

prepare_db:
  #!/usr/bin/env bash
  cd {{proot}}/TPCH-sqlite; SCALE_FACTOR={{sf}} make
  mv {{proot}}/TPCH-sqlite/TPC-H.db {{proot}}/shared_dir/
  mkdir -p {{proot}}/shared_dir/queries
  cd {{proot}}/TPCH-sqlite/tpch-dbgen; for q in `seq 1 22`;
    do
        DSS_QUERY=queries \
                ./qgen \
                -s {{sf}} -d \
                $q | tail -n +4 | {{proot}}/scripts/fix_sqlite_dates.pl | perl -00 -pe 's/;\nwhere rownum <= (-?\d+);/($1 == -1) ? ";" : "\nlimit $1;"/e'> {{proot}}/shared_dir/queries/q$q.sql
    done

qemu-startup:
    BPFTRACE_MAX_STRLEN=123 sudo -E bpftrace -e " \
    tracepoint:kvm:kvm_entry / @a[pid] == 0 / { printf(\"qemu kvm entry ns %lld\n\", nsecs()); @a[pid] = 1; } \
    tracepoint:kvm:kvm_pio / args.port == 0xf4 / { printf(\"qemu kvm port %d ns %lld\n\", args->val, nsecs()); } \
    tracepoint:syscalls:sys_enter_execve* \
    / str(args.filename) == \"$(which qemu-system-x86_64)\" / \
    { printf(\"qemu start ns %lld\n\", nsecs()); printf(\"filename %s\n\", str(args.filename))}" \


UBUNTU_PATH := "~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-jammy64/20241002.0.0/virtualbox/ubuntu-jammy-22.04-cloudimg.vmdk"
ALPINE_PATH := "~/.vagrant.d/boxes/generic-VAGRANTSLASH-alpine319/4.3.12/virtualbox/generic-alpine319-virtualbox-x64-disk001.vmdk"

imagesizes:
    # downloading images
    [ -e {{ALPINE_PATH}} ] || nix run --inputs-from ./ nixpkgs#vagrant -- box add generic/alpine319 --provider virtualbox --box-version 4.3.12
    [ -e {{UBUNTU_PATH}} ] || nix run --inputs-from ./ nixpkgs#vagrant -- box add ubuntu/jammy64 --provider virtualbox --box-version 20241002.0.0
    # default unikraft
    rm -f .config.sqlite_qemu-x86_64
    kraft build --env QUERYFILE="/queries/q1.1.sql" -K Kraftfile_unikraft
    ls -l ./.unikraft/build/sqlite_qemu-x86_64
    # Cirrus
    rm -f .config.sqlite_qemu-x86_64
    kraft build --env QUERYFILE="/queries/q1.1.sql" -K Kraftfile_cirrus
    ls -l ./.unikraft/build/sqlite_qemu-x86_64
    # Linux
    ls -l $(which sqlite3)
    ls -l {{ALPINE_PATH}}
    ls -l {{UBUNTU_PATH}}


