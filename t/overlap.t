
use strict;
use Set::IntSpan::Island 0.04;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["1","1",1],
	    ["1","2",0],
	    ["1-5","1-10",5],
	    ["1-5","-10-10",5],
	    ["1-5,6","6-10",1],
	    ["1,3,5-10","2,4-6",2],
	    ["1,3,5-10","2-4,9-10",3],
	    );

print "1..",1*@sets,"\n";
overlap();

sub overlap {
    print "#overlap\n";
    for my $setdata (@sets) {
	my $set1 = Set::IntSpan::Island->new($setdata->[0]);
	my $set2 = Set::IntSpan::Island->new($setdata->[1]);
	my $ol = $set1->overlap($set2);
	printf("#overlap %s -> %s\n",$ol,$setdata->[2]);
	$ol == $setdata->[2] || Not;
	OK;
    }
}
