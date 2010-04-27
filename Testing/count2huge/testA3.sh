#!/bin/csh

echo "Test A3 for count2huge.pl"

count.pl --newline testA1.count testA1.data        

huge-count.pl --tokenlist --newline --split 100 testA1.hugecount testA1.data

count2huge.pl testA1.count A3  

diff ./A3/count2huge.output ./testA1.hugecount/huge-count.output > ./A3/var

if( -z ./A3/var ) then
	echo "Test Ok";
else
	echo "Test Error";
	echo "When tested against test-A1.reqd";
	cat ./A3/var;
endif

/bin/rm -r A3 testA1.hugecount
/bin/rm -f testA1.count
