
use strict;
use Set::IntSpan::Island 0.04;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["-",0],
	    ["1",1],
	    ["1-5",1],
	    ["1-5,7",2],
	    ["1-5,7-8",2],
	    ["1-5,7-8,10",3],
	    ["1-5,7-8,10,12-)",4],
	    ["(--2,1-5,7-8,10,12-)",5],
	    ["(-)",1],
	    );

print "1..",1*@sets,"\n";
num_islands();

sub num_islands {
    print "#num_islands\n";
    for my $setdata (@sets) {
	my $set = Set::IntSpan::Island->new($setdata->[0]);
	my $n   = $setdata->[1];
	printf("#num_islands %s -> %s\n",$set->num_islands,$n);
	$set->num_islands == $n || Not;
	OK;
    }
}
