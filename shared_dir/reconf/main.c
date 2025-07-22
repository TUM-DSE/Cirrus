#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>
#include <time.h>

#ifndef DB_NAME
#define DB_NAME     "/root/ssb.sqlite"
#endif
sqlite3 *db;

int main(int argc, char **argv){
  char *zErrMsg = 0;
  int rc;
  sqlite3_open(DB_NAME, &db);
  sqlite3_enable_load_extension(db, 1);
  struct timespec start;
  if (clock_gettime(CLOCK_MONOTONIC, &start)) {
    perror("Could not read start time!");
    sqlite3_close(db);
    return -1;
  }

  rc = sqlite3_load_extension(db, "/root/reconf/crypto.so", 0, &zErrMsg);
    
  struct timespec end;
  if (clock_gettime(CLOCK_MONOTONIC, &end)) {
    perror("Could not read start time!");
    sqlite3_close(db);
    return -1;
  }

  time_t n_sec = end.tv_sec - start.tv_sec;
  long n_nsec = end.tv_nsec - start.tv_nsec;
  if (n_nsec < 0) {
    --n_sec;
    n_nsec += 1000000000L;
  }
  printf("Run Time: %ld.%09ld\n", n_sec, n_nsec);
    
  if( rc!=SQLITE_OK ){
    fprintf(stderr, "SQL error: %s\n", zErrMsg);
    sqlite3_free(zErrMsg);
    return -1;
  }

  sqlite3_close(db);

  // Ensure output is printed and VM really quits
  fflush(stdout);
  return 0;
}
