
use strict;
use Set::IntSpan::Island 0.04;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["1","",undef],
	    ["","",undef],
	    ["","1",undef],
	    ["1","1",-1],
	    ["1","2",1],
	    ["1-5","1-10",-5],
	    ["1-5,6","6-10",-1],
	    ["1-5","10-15",5],
	    ["1-5,10-15","5-9",-1],
	    ["1-5,10-15","6",1],
	    ["1-5,10-15","7",2],
	    ["1-5,10-15","7-9",1],
	    ["1-5,10-15","16-20",1],
	    ["1-5,10-15","17-20",2],
	    ["1-2,5-6,10-11,15-16","3",1],
	    ["1-2,5-6,10-11,15-16","3-4",1],
	    ["1-2,5-6,10-11,15-16","3-5",-1],
	    ["1-2,5-6,10-11,15-16","0",1],
	    ["1-2,5-6,10-11,15-16","20",4],
	    );

print "1..",1*@sets,"\n";
distance();

sub distance {
    print "#distance\n";
    for my $setdata (@sets) {
	my $set1 = Set::IntSpan::Island->new($setdata->[0]);
	my $set2 = Set::IntSpan::Island->new($setdata->[1]);
	my $d = $set1->distance($set2);
	printf("#distance %s -> %s\n",$d ||"-",$setdata->[2]||"-");
	(! defined $d && ! defined $setdata->[2]) || $d == $setdata->[2] || Not;
	OK;
    }
}
