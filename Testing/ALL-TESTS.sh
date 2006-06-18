#!/bin/csh


foreach dir (combig count dice leftFisher \
             ll ll3 odds phi pmi rank rightFisher statistic tmi tmi3 \
             tscore x2 huge-count huge-combine sort-bigrams split-data) 

	cd $dir
	./normal-op.sh 
	./error-handling.sh
	cd ..
end

foreach dir (kocos)

      cd $dir

        foreach subdir (unit integration)

	    cd $subdir

     	    ./normal-op.sh 
 	    ./error-handling.sh

     	    cd ..
        end

      cd ..
end

