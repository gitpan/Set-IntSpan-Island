
use strict;
use Set::IntSpan::Island 0.04;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["-",undef],
	    ["1","1"],
	    ["1-5","1-5"],
	    ["1-5,7","1-5"],
	    ["1-5,7-8","1-5"],
	    ["1-5,7-8,10","1-5"],
	    );

print "1..",1*@sets,"\n";
first_island();

sub first_island {
    print "#first_island\n";
    for my $setdata (@sets) {
	my $set    = Set::IntSpan::Island->new($setdata->[0]);
	my $island = $setdata->[1] ? Set::IntSpan::Island->new($setdata->[1]) : $setdata->[1];
	if($island) {
	    printf("#first_island %s -> %s\n",$set->first_island()->run_list,$island->run_list);
	    $set->first_island->run_list eq $island->run_list || Not;
	} else {
	    ! defined $set->first_island || Not;
	}
	OK;
    }
}
