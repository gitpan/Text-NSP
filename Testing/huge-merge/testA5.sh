#!/bin/csh

echo "Test A5 for huge-merge.pl"
echo "Running huge-merge.pl --keep --frequency 400 --ufrequency 3000 test-A5" 

huge-merge.pl --keep --frequency 400 --ufrequency 3000 test-A5

sort ./test-A5/merge.2 > ./test-A5/t0
sort ./test-A5/test-A5.reqd > ./test-A5/t1

diff ./test-A5/t0 ./test-A5/t1 > ./test-A5/var

if(-z ./test-A5/var) then
	echo "Test Ok";
else
	echo "Test Error";
	echo "When tested against test-A5.reqd";
	cat ./test-A5/var;
endif

/bin/rm -f ./test-A5/t0 ./test-A5/t1 ./test-A5/var ./test-A5/merge.2
