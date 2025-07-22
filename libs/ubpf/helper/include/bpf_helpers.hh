#ifndef UBPF_HELPERS_H
#define UBPF_HELPERS_H

#include <stdint.h>
#include <string.h>

void bpf_trace_printk(const char *fmt, int fmt_size, ...);

/*void *bpf_map_lookup_elem(void *map, void *key);

long bpf_map_update_elem(void *map, void *key, const void *value, uint64_t flags);

long bpf_map_delete_elem(void *map, void *key);*/

uint64_t bpf_ktime_get_ns(void);

//uint32_t bpf_get_prandom_u32(void);

/*enum bpf_map_type {
    BPF_MAP_TYPE_UNSPEC,
    BPF_MAP_TYPE_HASH,
    BPF_MAP_TYPE_ARRAY,
    BPF_MAP_TYPE_PROG_ARRAY,
    BPF_MAP_TYPE_PERF_EVENT_ARRAY,
    BPF_MAP_TYPE_PERCPU_HASH,
    BPF_MAP_TYPE_PERCPU_ARRAY,
    BPF_MAP_TYPE_STACK_TRACE,
    BPF_MAP_TYPE_CGROUP_ARRAY,
    BPF_MAP_TYPE_LRU_HASH,
    BPF_MAP_TYPE_LRU_PERCPU_HASH,
    BPF_MAP_TYPE_LPM_TRIE,
    BPF_MAP_TYPE_ARRAY_OF_MAPS,
    BPF_MAP_TYPE_HASH_OF_MAPS,
    BPF_MAP_TYPE_DEVMAP,
    BPF_MAP_TYPE_SOCKMAP,
    BPF_MAP_TYPE_CPUMAP,
    BPF_MAP_TYPE_XSKMAP,
    BPF_MAP_TYPE_SOCKHASH,
};

struct bpf_map_def {
    unsigned int type;
    unsigned int key_size;
    unsigned int value_size;
    unsigned int max_entries;
    unsigned int map_flags;
    unsigned int inner_map_idx;
    unsigned int numa_node;
};

struct bpf_map {
    struct bpf_map_def def;
    void *data;
};

struct bpf_map_ctx {
    char** maps_names;
    struct bpf_map** maps;
    void* global_data;
    int global_data_size;
};

uint64_t do_map_relocation(
        void *user_context,
        const uint8_t *map_data,
        uint64_t map_data_size,
        const char *symbol_name,
        uint64_t symbol_offset,
        uint64_t symbol_size,
        uint64_t relocation_offset
);*/

#endif /* UBPF_HELPERS_HH */
