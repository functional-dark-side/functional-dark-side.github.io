#Read a hist file from beddtools coverage -hist and create a coverage per gene file.
#Coverage per each gene is calculated as: coverage_geneA = sum(depth_of_coverage * fraction_covered)
{
    if ($0 i ~ /^all/){
        next;
    }else{
        split($4,a,"_");
        b=$1"_"$6"_"$2+1"_"$3"_orf-"a[2]"\t"$13;
        c[b]=c[b] + ($11*$14)
    }
}END{
    for (var in c){
        print var"\t"c[var]
    }
}
