echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit

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

