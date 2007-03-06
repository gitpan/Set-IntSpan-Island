
use strict;
use Set::IntSpan::Island 0.01;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["1-5",1,"1-5"],
	    ["1-5,7",1,"1-7"],
	    ["1-5,7",2,"1-7"],
	    ["1-5,7-8",1,"1-8"],
	    ["1-5,9-10",2,"1-5,9-10"],
	    ["1-5,9-10",3,"1-10"],
	    ["1-5,9-10,12-13,15",2,"1-5,9-15"],
	    ["1-5,9-10,12-13,15",3,"1-15"],
	    );

print "1..",1*@sets,"\n";
fill();

sub fill {
    print "#fill\n";
    for my $setdata (@sets) {
	my $set1 = Set::IntSpan::Island->new($setdata->[0]);
	my $set2 = Set::IntSpan::Island->new($setdata->[2]);
	my $set3 = $set1->fill($setdata->[1]);
	printf("#fill %s -> %s\n",$set3->run_list,$set2->run_list);
	$set3->run_list eq $set2->run_list || Not;
	OK;
    }
}
