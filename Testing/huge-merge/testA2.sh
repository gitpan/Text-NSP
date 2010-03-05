#!/bin/csh

echo "Test A2 for huge-merge.pl"
echo "Running huge-merge.pl --keep test-A2"

huge-merge.pl --keep test-A2

sort ./test-A2/merge.3 > ./test-A2/t0 
sort ./test-A2/test-A2.reqd > ./test-A2/t1

diff ./test-A2/t0 ./test-A2/t1 > ./test-A2/var

if(-z ./test-A2/var) then
	echo "Test Ok";
else
	echo "Test Error";
	echo "When tested against test-A1.reqd";
	cat ./test-A2/var;
endif

/bin/rm -f ./test-A2/t0 ./test-A2/t1 ./test-A2/var ./test-A2/merge.*
