
use strict;
use Set::IntSpan::Island 0.01;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @runlists = (
		[[1],"1"],
		[[1,2],"1-2"],
		[[1,3],"1-3"]
		);

print "1..",2*@runlists,"\n";
new();
duplicate();

sub new {
    print "#new\n";
    for my $rl (@runlists) {
	my $set = Set::IntSpan::Island->new( @{$rl->[0]} );
	printf("#new %s -> %s\n",join(",",@{$rl->[0]}),$rl->[1]);
	$set->run_list eq $rl->[1] || Not;
	OK;
    }
}

sub duplicate {
    print "#duplicate\n";
    for my $rl (@runlists) {
	my $set = Set::IntSpan::Island->new( @{$rl->[0]} );
	my $setc = $set->duplicate();
	printf("#duplicate %s -> %s\n",join(",",@{$rl->[0]}),$rl->[1]);
	($setc->run_list eq $rl->[1] && $set->run_list eq $rl->[1]) || Not;
	OK;
    }
}
