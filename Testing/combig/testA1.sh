#!/bin/csh

echo "Test A1 for combig.pl"
echo "Running combig.pl test-A1.big"

combig.pl test-A1.big > test-A1.output

sort test-A1.output > t0
sort test-A1.reqd > t1

diff -w t0 t1 > var1

if(-z var1) then
	echo "Test Ok";
else
	echo "Test Error";
	echo "When tested against test-A1.reqd";
	cat var1;
endif

/bin/rm -f var1 t0 t1 test-A1.output
 
