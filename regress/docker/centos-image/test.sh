#!/bin/bash

set -eu

extra_channels="0 2"
buffer_size="32768 131072"
num_requests="64 512"
host1="server1"
host2="server2"
hosts="$host1 both"
sftp="/usr/bin/time -f Elapsed time: %e /tmp/openssh-portable/sftp"

do_cleanup() {
	rm -rf dir2
	ssh $host1 rm -rf dir /share/dir
	ssh $host2 rm -rf dir
}

do_create() {
	rm -rf dir
	echo -e "\e[1m===== Creating test tree =====\e[0m"
	mkdir -p dir/a/1
	mkdir -p dir/a/2
	mkdir -p dir/b
	dd if=/dev/urandom of=dir/test1 bs=1024 count=32768 2>/dev/null
	dd if=/dev/urandom of=dir/test2 bs=1024 count=150000 2>/dev/null
	dd if=/dev/urandom of=dir/a/test3 bs=1024 count=32768 2>/dev/null
	dd if=/dev/urandom of=dir/a/test4 bs=1024 count=150000 2>/dev/null
	dd if=/dev/urandom of=dir/a/1/test5 bs=1024 count=32768 2>/dev/null
	dd if=/dev/urandom of=dir/a/1/test6 bs=1024 count=150000 2>/dev/null
	dd if=/dev/urandom of=dir/a/2/test7 bs=1024 count=32768 2>/dev/null
	dd if=/dev/urandom of=dir/a/2/test8 bs=1024 count=150000 2>/dev/null
	dd if=/dev/urandom of=dir/b/test9 bs=1024 count=32768 2>/dev/null
	dd if=/dev/urandom of=dir/b/test10 bs=1024 count=150000 2>/dev/null
}

do_compare() {
	cd dir
	found=`find -type f`
	cd ..
	echo -ne "\e[31m"
	for i in $found; do
		cmp dir/$i dir2/$i
	done
	echo -ne "\e[39m"
}

do_tests() {
	mode=$1
	for h in $hosts; do
		for r in $num_requests; do
			for b in $buffer_size; do
				for n in $extra_channels; do
					if [ $mode = "NFS" ] || [ $h = $host1 ] || [ $n = "0" ]; then
						echo -e "\e[1m===== $mode host=$h num_requests=$r buffer_size=$b extra_channels=$n =====\e[0m"
						$sftp -R $r -B $b -n $n -b batch $h
						do_compare
						do_cleanup
					fi
				done
			done
		done
	done
}

do_cleanup
do_create

echo "put -r dir /share" > batch
echo "get -r /share/dir dir2" >> batch
do_tests NFS

echo "put -r dir" > batch
echo "get -r dir dir2" >> batch
do_tests noNFS
