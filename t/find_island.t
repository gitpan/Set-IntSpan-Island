
use strict;
use Set::IntSpan::Island 0.01;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["1-5",1,"1-5"],
	    ["1-5,7",1,"1-5"],
	    ["1-5,7",6,"-"],
	    ["1-5,7-8",7,"7-8"],
	    ["1-5,7",7,"7"],
	    ["1-5,8",7,"-"],
	    ["1-8",7,"1-8"],

	    ["1-8","7-8","1-8"],
	    ["1-5,7-8","7-8","7-8"],
	    ["1-5,8-9","7-8","8-9"],
	    ["1-5,8-9,11-15","9-11","8-9,11-15"],
	    );

print "1..",1*@sets,"\n";
find_islands();

sub find_islands {
    print "#find_island\n";
    for my $setdata (@sets) {
	my $set1 = Set::IntSpan::Island->new($setdata->[0]);
	my $set2 = Set::IntSpan::Island->new($setdata->[2]);
	my $island = $set1->find_islands($setdata->[1]);
	printf("#island %s -> %s\n",$island->run_list,$set2->run_list);
	$island->run_list eq $set2->run_list || Not;
	OK;
    }
}
