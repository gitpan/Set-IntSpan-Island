
use strict;
use Set::IntSpan::Island 0.04;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["-",0,undef],
	    ["-",1,undef],
	    ["-",-1,undef],
	    ["1",0,"1"],
	    ["1",1,undef],
	    ["1",-1,"1"],
	    ["1-5",0,"1-5"],
	    ["1-5,7",0,"1-5"],
	    ["1-5,7",1,"7"],
	    ["1-5,7-8",0,"1-5"],
	    ["1-5,7-8",1,"7-8"],
	    ["1-5,7-8,10",2,"10"],
	    ["1-5,7-8,10",3,undef],
	    );

print "1..",1*@sets,"\n";
at_island();

sub at_island {
    print "#at_island\n";
    for my $setdata (@sets) {
	my $set    = Set::IntSpan::Island->new($setdata->[0]);
	my $n      = $setdata->[1];
	my $island = $setdata->[2] ? Set::IntSpan::Island->new($setdata->[2]) : $setdata->[2];
	if($island) {
	    printf("#at_island %s -> %s\n",$set->at_island($n)->run_list,$island->run_list);
	    $set->at_island($n)->run_list eq $island->run_list || Not;
	} else {
	    ! defined $set->at_island($n) || Not;
	}
	OK;
    }
}
