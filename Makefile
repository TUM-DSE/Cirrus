all: build build_ebpf

build:
	mkdir -p libs/sqlite/build
	rm -rf libs/sqlite/build/*
	cd libs/sqlite/build; ../sqlite_src/configure; make sqlite3.c
	if [[ -f .config.sqlite_qemu-x86_64 ]]; then \
		kraft build --log-type basic --env QUERFYFILE="/queries/q1.1.sql" -K Kraftfile_cirrus $(EXTRA_KRAFT_ARGS) --no-configure; \
	else \
		kraft build --log-type basic --env QUERFYFILE="/queries/q1.1.sql" -K Kraftfile_cirrus $(EXTRA_KRAFT_ARGS); \
	fi

build_ebpf:
	clang -O2 -fno-stack-protector -target bpf -Ilibs/sqlite/sqlite_src/src -c libs/sqlite/bpf/insert.c -o shared_dir/insert.bpf
