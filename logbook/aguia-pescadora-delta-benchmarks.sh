echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit

#### speedtest-cli

root@aguia-pescadora-delta:~# apt install speedtest-cli

root@aguia-pescadora-delta:~# speedtest-cli
Retrieving speedtest.net configuration...
Testing from Contabo GmbH (173.249.10.99)...
Retrieving speedtest.net server list...
Selecting best server based on ping...
Hosted by Contabo GmbH (Nuremberg) [7.56 km]: 0.844 ms
Testing download speed................................................................................
Download: 399.19 Mbit/s
Testing upload speed......................................................................................................
Upload: 4.14 Mbit/s

## Nota: baixou do proprio datacenter, logo definitivamente bateria o limite

root@aguia-pescadora-delta:~# speedtest-cli --list | grep 'Angola'
 5513) ZAP (Luanda, Angola) [6478.71 km]
11674) TVCABO Angola (Luanda, Angola) [6478.71 km]
24108) Unitel AO (Luanda, Angola) [6478.71 km]
 4722) Angola Telecom (Luanda, Angola) [6478.71 km]
17057) TVCABO Angola (Benguela, Angola) [6897.13 km]
17191) TVCABO Angola (Huambo, Angola) [6928.61 km]
17192) TVCABO Angola (Lubango, Angola) [7156.26 km]
root@aguia-pescadora-delta:~# speedtest-cli --server 24108
Retrieving speedtest.net configuration...
Testing from Contabo GmbH (173.249.10.99)...
Retrieving speedtest.net server list...
Retrieving information for the selected server...
Hosted by Unitel AO (Luanda) [6478.71 km]: 202.758 ms
Testing download speed................................................................................
Download: 220.59 Mbit/s
Testing upload speed......................................................................................................
Upload: 3.88 Mbit/s


root@aguia-pescadora-delta:~# speedtest-cli --list | grep 'Porto Alegre'
13905) Melnet (Porto Alegre, Brazil) [10766.80 km]
14143) NET Virtua (Porto Alegre, Brazil) [10767.35 km]
18527) Claro (Porto Alegre, Brazil) [10767.35 km]
 9710) Vogel Telecom (Porto Alegre, Brazil) [10767.35 km]
17678) RLNET (Porto Alegre, BR) [10767.35 km]
21511) Vivo PAE (Porto Alegre, Brazil) [10767.35 km]
21769) Tubaron (Porto Alegre, Brazil) [10767.35 km]
23624) BLUE3 INTERNET (Porto Alegre, Brazil) [10767.35 km]
24878) RSnetPOA (Porto Alegre, Brazil) [10767.35 km]
16264) GiganetSul (Porto Alegre, Brazil) [10767.35 km]
root@aguia-pescadora-delta:~# speedtest-cli --server 18527
Retrieving speedtest.net configuration...
Testing from Contabo GmbH (173.249.10.99)...
Retrieving speedtest.net server list...
Retrieving information for the selected server...
Hosted by Claro (Porto Alegre) [10767.35 km]: 247.497 ms
Testing download speed................................................................................
Download: 53.28 Mbit/s
Testing upload speed......................................................................................................
Upload: 3.79 Mbit/s

root@aguia-pescadora-delta:~# speedtest-cli --server 14143
Retrieving speedtest.net configuration...
Testing from Contabo GmbH (173.249.10.99)...
Retrieving speedtest.net server list...
Retrieving information for the selected server...
Hosted by NET Virtua (Porto Alegre) [10767.35 km]: 276.814 ms
Testing download speed................................................................................
Download: 91.50 Mbit/s
Testing upload speed......................................................................................................
Upload: 3.73 Mbit/s


### sysbench cpu run

root@aguia-pescadora-delta:~# sysbench cpu run
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Prime numbers limit: 10000

Initializing worker threads...

Threads started!

CPU speed:
    events per second:   783.51

General statistics:
    total time:                          10.0008s
    total number of events:              7838

Latency (ms):
         min:                                  0.94
         avg:                                  1.27
         max:                                  4.52
         95th percentile:                      1.47
         sum:                               9992.08

Threads fairness:
    events (avg/stddev):           7838.0000/0.00
    execution time (avg/stddev):   9.9921/0.00

root@aguia-pescadora-delta:~# sysbench --threads=6 cpu run
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 6
Initializing random number generator from current time


Prime numbers limit: 10000

Initializing worker threads...

Threads started!

CPU speed:
    events per second:  4446.41

General statistics:
    total time:                          10.0018s
    total number of events:              44485

Latency (ms):
         min:                                  1.13
         avg:                                  1.35
         max:                                  8.24
         95th percentile:                      1.64
         sum:                              59960.15

Threads fairness:
    events (avg/stddev):           7414.1667/129.54
    execution time (avg/stddev):   9.9934/0.00

### sysbench memory run

root@aguia-pescadora-delta:~# sysbench memory run
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Running memory speed test with the following options:
  block size: 1KiB
  total size: 102400MiB
  operation: write
  scope: global

Initializing worker threads...

Threads started!

Total operations: 33686434 (3367623.19 per second)

32896.91 MiB transferred (3288.69 MiB/sec)


General statistics:
    total time:                          10.0001s
    total number of events:              33686434

Latency (ms):
         min:                                  0.00
         avg:                                  0.00
         max:                                  0.07
         95th percentile:                      0.00
         sum:                               4474.82

Threads fairness:
    events (avg/stddev):           33686434.0000/0.00
    execution time (avg/stddev):   4.4748/0.00

## Disco SSH, via sysbench
#@see https://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench
sudo apt install sysbench

# O tamanho do arquivo de teste precisa ser muito maior que nossa RAM
# (que é 16GB), porém nosso disco tem livre 400GB. Vamos testar com 100GB

sysbench --test=fileio --file-total-size=100G prepare

root@aguia-pescadora-delta:~# sysbench --test=fileio --file-total-size=100G prepare
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)

128 files, 819200Kb each, 102400Mb total
Creating files for the test...
Extra file open flags: 0
Creating file test_file.0
Creating file test_file.1
Creating file test_file.2
Creating file test_file.3
Creating file test_file.4
Creating file test_file.5
Creating file test_file.6
Creating file test_file.7
Creating file test_file.8
Creating file test_file.9
Creating file test_file.10
Creating file test_file.11
Creating file test_file.12
Creating file test_file.13
Creating file test_file.14
Creating file test_file.15
Creating file test_file.16
Creating file test_file.17
Creating file test_file.18
Creating file test_file.19
Creating file test_file.20
Creating file test_file.21
Creating file test_file.22
Creating file test_file.23
Creating file test_file.24
Creating file test_file.25
Creating file test_file.26
Creating file test_file.27
Creating file test_file.28
Creating file test_file.29
Creating file test_file.30
Creating file test_file.31
Creating file test_file.32
Creating file test_file.33
Creating file test_file.34
Creating file test_file.35
Creating file test_file.36
Creating file test_file.37
Creating file test_file.38
Creating file test_file.39
Creating file test_file.40
Creating file test_file.41
Creating file test_file.42
Creating file test_file.43
Creating file test_file.44
Creating file test_file.45
Creating file test_file.46
Creating file test_file.47
Creating file test_file.48
Creating file test_file.49
Creating file test_file.50
Creating file test_file.51
Creating file test_file.52
Creating file test_file.53
Creating file test_file.54
Creating file test_file.55
Creating file test_file.56
Creating file test_file.57
Creating file test_file.58
Creating file test_file.59
Creating file test_file.60
Creating file test_file.61
Creating file test_file.62
Creating file test_file.63
Creating file test_file.64
Creating file test_file.65
Creating file test_file.66
Creating file test_file.67
Creating file test_file.68
Creating file test_file.69
Creating file test_file.70
Creating file test_file.71
Creating file test_file.72
Creating file test_file.73
Creating file test_file.74
Creating file test_file.75
Creating file test_file.76
Creating file test_file.77
Creating file test_file.78
Creating file test_file.79
Creating file test_file.80
Creating file test_file.81
Creating file test_file.82
Creating file test_file.83
Creating file test_file.84
Creating file test_file.85
Creating file test_file.86
Creating file test_file.87
Creating file test_file.88
Creating file test_file.89
Creating file test_file.90
Creating file test_file.91
Creating file test_file.92
Creating file test_file.93
Creating file test_file.94
Creating file test_file.95
Creating file test_file.96
Creating file test_file.97
Creating file test_file.98
Creating file test_file.99
Creating file test_file.100
Creating file test_file.101
Creating file test_file.102
Creating file test_file.103
Creating file test_file.104
Creating file test_file.105
Creating file test_file.106
Creating file test_file.107
Creating file test_file.108
Creating file test_file.109
Creating file test_file.110
Creating file test_file.111
Creating file test_file.112
Creating file test_file.113
Creating file test_file.114
Creating file test_file.115
Creating file test_file.116
Creating file test_file.117
Creating file test_file.118
Creating file test_file.119
Creating file test_file.120
Creating file test_file.121
Creating file test_file.122
Creating file test_file.123
Creating file test_file.124
Creating file test_file.125
Creating file test_file.126
Creating file test_file.127
107374182400 bytes written in 1020.32 seconds (100.36 MiB/sec).

sysbench --test=fileio --file-total-size=100G --file-test-mode=rndrw --max-requests=0 run

root@aguia-pescadora-delta:~# sysbench --test=fileio --file-total-size=100G --file-test-mode=rndrw --max-requests=0 run
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Extra file open flags: 0
128 files, 800MiB each
100GiB total file size
Block size 16KiB
Number of IO requests: 0
Read/Write ratio for combined random IO test: 1.50
Periodic FSYNC enabled, calling fsync() each 100 requests.
Calling fsync() at the end of test, Enabled.
Using synchronous I/O mode
Doing random r/w test
Initializing worker threads...

Threads started!


File operations:
    reads/s:                      2783.14
    writes/s:                     1855.43
    fsyncs/s:                     5936.18

Throughput:
    read, MiB/s:                  43.49
    written, MiB/s:               28.99

General statistics:
    total time:                          10.0004s
    total number of events:              105780

Latency (ms):
         min:                                  0.00
         avg:                                  0.09
         max:                                146.47
         95th percentile:                      0.28
         sum:                               9926.50

Threads fairness:
    events (avg/stddev):           105780.0000/0.00
    execution time (avg/stddev):   9.9265/0.00

root@aguia-pescadora-delta:~# sysbench --test=fileio --file-total-size=100G cleanup
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)

Removing test files...

root@aguia-pescadora-delta:~# sysbench cpu run
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time

### BENCHMARK DISCO SSD________________________________________________________
### @see https://www.shellhacks.com/disk-speed-test-read-write-hdd-ssd-perfomance-linux/

root@aguia-pescadora-delta:~# sudo swapon --show
NAME      TYPE SIZE USED PRIO
/swapfile file   2G   0B   -2
root@aguia-pescadora-delta:~# sync; dd if=/dev/zero of=tempfile bs=1M count=1024; sync
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 2.1631 s, 496 MB/s
root@aguia-pescadora-delta:~# dd if=tempfile of=/dev/null bs=1M count=1024
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 0.231768 s, 4.6 GB/s
root@aguia-pescadora-delta:~# sudo /sbin/sysctl -w vm.drop_caches=3
vm.drop_caches = 3
root@aguia-pescadora-delta:~# vm.drop_caches = 3
vm.drop_caches: command not found
root@aguia-pescadora-delta:~# dd if=tempfile of=/dev/null bs=1M count=1024
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 0.723575 s, 1.5 GB/s
root@aguia-pescadora-delta:~# sudo hdparm -Tt /dev/sda

/dev/sda:
 Timing cached reads:   17044 MB in  1.99 seconds = 8572.35 MB/sec
 Timing buffered disk reads: 1926 MB in  3.00 seconds = 641.80 MB/sec
