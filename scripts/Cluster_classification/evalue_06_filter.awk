#!/bin/awk -f

# if the results from the search were coverted to a flat file with convertalis (if converted with createtsv the e-value column is $5)
{
 if ($1 in array) {
        A=array[$1]
        L=(log($11)/log(10));
         if(L <= A) {
                print $0;
        }
}else{
        L=0.6*(log($11)/log(10));
        array[$1]=L;
        print $0;
     }
}
