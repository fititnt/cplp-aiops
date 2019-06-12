echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit

#### speedtest-cli
root@aguia-pescadora-bravo:~# speedtest-cli
Retrieving speedtest.net configuration...
Testing from OVH Hosting (192.99.247.117)...
Retrieving speedtest.net server list...
Selecting best server based on ping...
Hosted by Bell Mobility (Montreal, QC) [1.07 km]: 6.361 ms
Testing download speed................................................................................
Download: 97.58 Mbit/s
Testing upload speed......................................................................................................
Upload: 4.04 Mbit/s

root@aguia-pescadora-bravo:~# speedtest-cli --server 18527
Retrieving speedtest.net configuration...
Testing from OVH Hosting (192.99.247.117)...
Retrieving speedtest.net server list...
Retrieving information for the selected server...
Hosted by Claro (Porto Alegre) [8697.78 km]: 243.114 ms
Testing download speed...............................................................................
.Download: 77.89 Mbit/s
Testing upload speed......................................................................................................
Upload: 3.86 Mbit/s
root@aguia-pescadora-bravo:~# speedtest-cli --server 14143
Retrieving speedtest.net configuration...
Testing from OVH Hosting (192.99.247.117)...
Retrieving speedtest.net server list...
Retrieving information for the selected server...
Hosted by NET Virtua (Porto Alegre) [8697.78 km]: 226.735 ms
Testing download speed................................................................................
Download: 57.47 Mbit/s
Testing upload speed......................................................................................................
Upload: 3.70 Mbit/s

root@aguia-pescadora-bravo:~# speedtest-cli --server 24108
Retrieving speedtest.net configuration...
Testing from OVH Hosting (192.99.247.117)...
Retrieving speedtest.net server list...
Retrieving information for the selected server...
Hosted by Unitel AO (Luanda) [10461.19 km]: 342.184 ms
Testing download speed................................................................................
Download: 54.98 Mbit/s
Testing upload speed......................................................................................................
Upload: 3.73 Mbit/s

#### sysbench (Banchmark geral)

### sysbench cpu run

Last login: Sat May 18 04:18:57 2019 from 201.21.106.135
root@aguia-pescadora-bravo:~# sysbench cpu run
sysbench 1.0.17 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Prime numbers limit: 10000

Initializing worker threads...

Threads started!

CPU speed:
    events per second:   955.39

General statistics:
    total time:                          10.0011s
    total number of events:              9560

Latency (ms):
         min:                                    0.96
         avg:                                    1.05
         max:                                    4.77
         95th percentile:                        1.16
         sum:                                 9997.29

Threads fairness:
    events (avg/stddev):           9560.0000/0.00
    execution time (avg/stddev):   9.9973/0.00

root@aguia-pescadora-bravo:~# sysbench --threads=2 cpu run
sysbench 1.0.17 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 2
Initializing random number generator from current time


Prime numbers limit: 10000

Initializing worker threads...

Threads started!

CPU speed:
    events per second:  1281.75

General statistics:
    total time:                          10.0009s
    total number of events:              12822

Latency (ms):
         min:                                    1.19
         avg:                                    1.56
         max:                                   38.74
         95th percentile:                        1.73
         sum:                                19946.85

Threads fairness:
    events (avg/stddev):           6411.0000/37.00
    execution time (avg/stddev):   9.9734/0.01


### sysbench memory run

root@aguia-pescadora-bravo:~# sysbench memory run
sysbench 1.0.17 (using bundled LuaJIT 2.1.0-beta2)

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

Total operations: 41430889 (4142154.86 per second)

40459.85 MiB transferred (4045.07 MiB/sec)


General statistics:
    total time:                          10.0001s
    total number of events:              41430889

Latency (ms):
         min:                                    0.00
         avg:                                    0.00
         max:                                    0.06
         95th percentile:                        0.00
         sum:                                 4351.66

Threads fairness:
    events (avg/stddev):           41430889.0000/0.00
    execution time (avg/stddev):   4.3517/0.00

## Disco SSH, via sysbench
#@see https://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench

# O tamanho do arquivo de teste precisa ser muito maior que nossa RAM
# (que é 8GB), porém nosso disco tem livre 75GB. Vamos testar com 50GB
sysbench --test=fileio --file-total-size=50G prepare
root@aguia-pescadora-bravo:~# sysbench --test=fileio --file-total-size=50G prepare
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.17 (using bundled LuaJIT 2.1.0-beta2)

128 files, 409600Kb each, 51200Mb total
Creating files for the test...
Extra file open flags: (none)
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
53687091200 bytes written in 279.73 seconds (183.03 MiB/sec).

root@aguia-pescadora-bravo:~# sysbench --test=fileio --file-total-size=50G --file-test-mode=rndrw --max-requests=0 run
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.17 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Extra file open flags: (none)
128 files, 400MiB each
50GiB total file size
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
    reads/s:                      229.33
    writes/s:                     152.89
    fsyncs/s:                     492.28

Throughput:
    read, MiB/s:                  3.58
    written, MiB/s:               2.39

General statistics:
    total time:                          10.2015s
    total number of events:              8795

Latency (ms):
         min:                                    0.00
         avg:                                    1.14
         max:                                   25.34
         95th percentile:                        5.88
         sum:                                 9983.70

Threads fairness:
    events (avg/stddev):           8795.0000/0.00
    execution time (avg/stddev):   9.9837/0.00

root@aguia-pescadora-bravo:~# sysbench --test=fileio --file-total-size=50G cleanup
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.17 (using bundled LuaJIT 2.1.0-beta2)

Removing test files...


#### BENCHMARK DISCO SSD________________________________________________________
### @see https://www.shellhacks.com/disk-speed-test-read-write-hdd-ssd-perfomance-linux/

# fititnt at bravo in /alligo/code/fititnt/cplp-aiops on git:master x [1:18:51]
$ ssh root@aguia-pescadora-bravo.etica.ai
Last login: Sat May 18 04:10:43 2019 from xxx.xxx.xxx.xxx
root@aguia-pescadora-bravo:~# sudo swapon --show
root@aguia-pescadora-bravo:~# sync; dd if=/dev/zero of=tempfile bs=1M count=1024; sync
1024+0 registos dentro
1024+0 registos fora
1073741824 bytes (1,1 GB, 1,0 GiB) copied, 2,23655 s, 480 MB/s
root@aguia-pescadora-bravo:~# dd if=tempfile of=/dev/null bs=1M count=1024
1024+0 registos dentro
1024+0 registos fora
1073741824 bytes (1,1 GB, 1,0 GiB) copied, 0,199229 s, 5,4 GB/s
root@aguia-pescadora-bravo:~# sudo /sbin/sysctl -w vm.drop_caches=3
vm.drop_caches = 3
root@aguia-pescadora-bravo:~# vm.drop_caches = 3
vm.drop_caches: comando não encontrado
root@aguia-pescadora-bravo:~# dd if=tempfile of=/dev/null bs=1M count=1024
1024+0 registos dentro
1024+0 registos fora
1073741824 bytes (1,1 GB, 1,0 GiB) copied, 1,36111 s, 789 MB/s
root@aguia-pescadora-bravo:~# sudo hdparm -Tt /dev/sda

/dev/sda:
 Timing cached reads:   20374 MB in  1.99 seconds = 10242.90 MB/sec
 Timing buffered disk reads: 1606 MB in  3.00 seconds = 535.22 MB/sec

#### BENCHMARK MEMORIA RAM______________________________________________________

### CHECAR SE ESTA TUDO OK
## @see https://linuxhint.com/check-ram-ubuntu/
sudo apt-get install memtester

root@aguia-pescadora-bravo:~# sudo memtester 100M 2
memtester version 4.3.0 (64-bit)
Copyright (C) 2001-2012 Charles Cazabon.
Licensed under the GNU General Public License version 2 (only).

pagesize is 4096
pagesizemask is 0xfffffffffffff000
want 100MB (104857600 bytes)
got  100MB (104857600 bytes), trying mlock ...locked.
Loop 1/2:
  Stuck Address       : ok         
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok         
  Block Sequential    : ok         
  Checkerboard        : ok         
  Bit Spread          : ok         
  Bit Flip            : ok         
  Walking Ones        : ok         
  Walking Zeroes      : ok         
  8-bit Writes        : ok
  16-bit Writes       : ok

Loop 2/2:
  Stuck Address       : ok         
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok         
  Block Sequential    : ok         
  Checkerboard        : ok         
  Bit Spread          : ok         
  Bit Flip            : ok         
  Walking Ones        : ok         
  Walking Zeroes      : ok         
  8-bit Writes        : ok
  16-bit Writes       : ok

Done.

### @see http://www.geekpills.com/operating-system/linux/linux-check-ram-speed-type

root@aguia-pescadora-bravo:~# dmidecode –type 17
# dmidecode 3.1
Getting SMBIOS data from sysfs.
SMBIOS 2.8 present.
11 structures occupying 536 bytes.
Table at 0x000F6820.

Handle 0x0000, DMI type 0, 24 bytes
BIOS Information
	Vendor: SeaBIOS
	Version: 2:1.10.2-58953eb7
	Release Date: 04/01/2014
	Address: 0xE8000
	Runtime Size: 96 kB
	ROM Size: 64 kB
	Characteristics:
		BIOS characteristics not supported
		Targeted content distribution is supported
	BIOS Revision: 0.0

Handle 0x0100, DMI type 1, 27 bytes
System Information
	Manufacturer: OpenStack Foundation
	Product Name: OpenStack Nova
	Version: 14.0.10
	Serial Number: 5b429103-2856-154f-1caf-5ffb5694cdc3
	UUID: 6E3D75E1-4BE7-4C49-AC0B-EA9EF01C4CD4
	Wake-up Type: Power Switch
	SKU Number: Not Specified
	Family: Virtual Machine

Handle 0x0300, DMI type 3, 21 bytes
Chassis Information
	Manufacturer: QEMU
	Type: Other
	Lock: Not Present
	Version: pc-i440fx-xenial
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Boot-up State: Safe
	Power Supply State: Safe
	Thermal State: Safe
	Security Status: Unknown
	OEM Information: 0x00000000
	Height: Unspecified
	Number Of Power Cords: Unspecified
	Contained Elements: 0

Handle 0x0400, DMI type 4, 42 bytes
Processor Information
	Socket Designation: CPU 0
	Type: Central Processor
	Family: Other
	Manufacturer: QEMU
	ID: C1 06 03 00 FF FB 8B 07
	Version: pc-i440fx-xenial
	Voltage: Unknown
	External Clock: Unknown
	Max Speed: 2000 MHz
	Current Speed: 2000 MHz
	Status: Populated, Enabled
	Upgrade: Other
	L1 Cache Handle: Not Provided
	L2 Cache Handle: Not Provided
	L3 Cache Handle: Not Provided
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Part Number: Not Specified
	Core Count: 1
	Core Enabled: 1
	Thread Count: 1
	Characteristics: None

Handle 0x0401, DMI type 4, 42 bytes
Processor Information
	Socket Designation: CPU 1
	Type: Central Processor
	Family: Other
	Manufacturer: QEMU
	ID: C1 06 03 00 FF FB 8B 07
	Version: pc-i440fx-xenial
	Voltage: Unknown
	External Clock: Unknown
	Max Speed: 2000 MHz
	Current Speed: 2000 MHz
	Status: Populated, Enabled
	Upgrade: Other
	L1 Cache Handle: Not Provided
	L2 Cache Handle: Not Provided
	L3 Cache Handle: Not Provided
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Part Number: Not Specified
	Core Count: 1
	Core Enabled: 1
	Thread Count: 1
	Characteristics: None

Handle 0x1000, DMI type 16, 23 bytes
Physical Memory Array
	Location: Other
	Use: System Memory
	Error Correction Type: Multi-bit ECC
	Maximum Capacity: 8000 MB
	Error Information Handle: Not Provided
	Number Of Devices: 1

Handle 0x1100, DMI type 17, 40 bytes
Memory Device
	Array Handle: 0x1000
	Error Information Handle: Not Provided
	Total Width: Unknown
	Data Width: Unknown
	Size: 8000 MB
	Form Factor: DIMM
	Set: None
	Locator: DIMM 0
	Bank Locator: Not Specified
	Type: RAM
	Type Detail: Other
	Speed: Unknown
	Manufacturer: QEMU
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Part Number: Not Specified
	Rank: Unknown
	Configured Clock Speed: Unknown
	Minimum Voltage: Unknown
	Maximum Voltage: Unknown
	Configured Voltage: Unknown

Handle 0x1300, DMI type 19, 31 bytes
Memory Array Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x000BFFFFFFF
	Range Size: 3 GB
	Physical Array Handle: 0x1000
	Partition Width: 1

Handle 0x1301, DMI type 19, 31 bytes
Memory Array Mapped Address
	Starting Address: 0x00100000000
	Ending Address: 0x00233FFFFFF
	Range Size: 4928 MB
	Physical Array Handle: 0x1000
	Partition Width: 1

Handle 0x2000, DMI type 32, 11 bytes
System Boot Information
	Status: No errors detected

Handle 0x7F00, DMI type 127, 4 bytes
End Of Table


root@aguia-pescadora-bravo:~# lshw  -short -C memory
H/W path        Device      Class          Description
======================================================
/0/0                        memory         96KiB BIOS
/0/1000                     memory         8000MiB System Memory
/0/1000/0                   memory         8000MiB DIMM RAM
root@aguia-pescadora-bravo:~# lshw   -C memory
  *-firmware                
       description: BIOS
       vendor: SeaBIOS
       physical id: 0
       version: 2:1.10.2-58953eb7
       date: 04/01/2014
       size: 96KiB
  *-memory
       description: System Memory
       physical id: 1000
       size: 8000MiB
       capabilities: ecc
       configuration: errordetection=multi-bit-ecc
     *-bank
          description: DIMM RAM
          vendor: QEMU
          physical id: 0
          slot: DIMM 0
          size: 8000MiB

