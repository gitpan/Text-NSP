#!/bin/csh

echo "Test A4 for huge-merge.pl"
echo "Running huge-merge.pl --keep --remove 400 --uremove 2000 test-A4" 

huge-merge.pl --keep --remove 400 --uremove 2000 test-A4

sort ./test-A4/merge.2 > ./test-A4/t0
sort ./test-A4/test-A4.reqd > ./test-A4/t1

diff ./test-A4/t0 ./test-A4/t1 > ./test-A4/var

if(-z ./test-A4/var) then
	echo "Test Ok";
else
	echo "Test Error";
	echo "When tested against test-A4.reqd";
	cat var;
endif

/bin/rm -f ./test-A4/t0 ./test-A4/t1 ./test-A4/var ./test-A4/merge.2
