
use strict;
use Set::IntSpan::Island 0.01;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["-",[]],
	    ["1",["1"]],
	    ["1-5",["1-5"]],
	    ["1-5,7",["1-5","7"]],
	    ["1-5,7-8",["1-5","7-8"]],
	    ["1-5,7-8,10",["1-5","7-8","10"]],
	    );

print "1..",2*@sets,"\n";
next_island();
prev_island();

sub next_island {
    print "#next_island\n";
    for my $setdata (@sets) {
	my @islands = map { Set::IntSpan::Island->new($_) } @{$setdata->[1]};
	my $set = Set::IntSpan::Island->new($setdata->[0]);
	my $n = 0;
	while(my $island = $set->next_island) {
	    my $cisland = $set->current_island;
	    my $expected = $islands[$n];
	    if($expected) { 
		printf("#next_island %s -> %s\n",$island->run_list,$expected->run_list);
		$island->run_list eq $expected->run_list && $cisland->run_list eq $expected->run_list || Not;
		$n++;
	    } else {
		
	    }
	}
	(! defined $islands[$n] && ! defined $set->current_island) || Not;
	OK;
    }
}

sub prev_island {
    print "#prev_island\n";
    for my $setdata (@sets) {
	my @islands = map { Set::IntSpan::Island->new($_) } reverse @{$setdata->[1]};
	my $set = Set::IntSpan::Island->new($setdata->[0]);
	my $n = 0;
	while(my $island = $set->prev_island) {
	    my $cisland = $set->current_island;
	    my $expected = $islands[$n];
	    if($expected) { 
		printf("#prev_island %s -> %s\n",$island->run_list,$expected->run_list);
		$island->run_list eq $expected->run_list && $cisland->run_list eq $expected->run_list || Not;
		$n++;
	    } else {
		
	    }
	}
	(! defined $islands[$n] && ! defined $set->current_island) || Not;
	OK;
    }
}
