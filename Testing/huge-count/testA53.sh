#!/bin/csh

echo "Test A53 for huge-count.pl"
echo "Running huge-count.pl --newLine --token token.regex --nontoken nontoken.regex --stop stoplist --window 3 test-A53.output test-A53.data1 test-A53.data2 test-A53.data3 test-A53.data4"

huge-count.pl --newLine --token token.regex --nontoken nontoken.regex --stop stoplist --window 3 test-A53.output test-A53.data1 test-A53.data2 test-A53.data3 test-A53.data4

# testing count

diff test-A53.output/test-A53.data1.bigrams test-A5.reqd/test-A5.data1.bigrams > var1
diff test-A53.output/test-A53.data2.bigrams test-A5.reqd/test-A5.data2.bigrams > var2
diff test-A53.output/test-A53.data3.bigrams test-A5.reqd/test-A5.data3.bigrams > var3
diff test-A53.output/test-A53.data4.bigrams test-A5.reqd/test-A5.data4.bigrams > var4

if(-z var1 && -z var2 && -z var3 && -z var4) then
        echo "Test Ok";
else
        echo "Test Error";
        echo "When tested against test-A5.reqd/test-A5.data1.bigrams";
        cat var1;
        echo "When tested against test-A5.reqd/test-A5.data2.bigrams";
        cat var2;
        echo "When tested against test-A5.reqd/test-A5.data3.bigrams";
        cat var3;
        echo "When tested against test-A5.reqd/test-A5.data4.bigrams";
        cat var4;
endif

/bin/rm -f var1 var2 var3 var4

# testing final output

sort test-A53.output/huge-count.output > t0
sort test-A5.reqd/huge-count.output > t1

diff -w t0 t1 > var1

if(-z var1) then
        echo "Test Ok";
else
        echo "Test Error";
        echo "When tested against test-A5.reqd/huge-count.output";
        cat var1;
endif

/bin/rm -f -r var1 t0 t1 test-A53.output
