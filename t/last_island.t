
use strict;
use Set::IntSpan::Island 0.04;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["-",undef],
	    ["1","1"],
	    ["1-5","1-5"],
	    ["1-5,7","7"],
	    ["1-5,7-8","7-8"],
	    ["1-5,7-8,10","10"],
	    );

print "1..",1*@sets,"\n";
last_island();

sub last_island {
    print "#last_island\n";
    for my $setdata (@sets) {
	my $set    = Set::IntSpan::Island->new($setdata->[0]);
	my $island = $setdata->[1] ? Set::IntSpan::Island->new($setdata->[1]) : $setdata->[1];
	if($island) {
	    printf("#last_island %s -> %s\n",$set->last_island()->run_list,$island->run_list);
	    $set->last_island->run_list eq $island->run_list || Not;
	} else {
	    ! defined $set->last_island || Not;
	}
	OK;
    }
}
