
use strict;
use Set::IntSpan::Island 0.04;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["1-5",1,"-"],
	    ["1-5,7",6,"1-5,7"],
	    ["1-5,7",8,"7"],
	    ["1-5,7",0,"1-5"],
	    ["1-5,7-8",8,"1-5"],
	    ["1-5,7-8",9,"7-8"],
	    ["1-5,7-8",10,"7-8"],
	    ["1-5,7-8",-5,"1-5"],

	    ["1-5,7-8","-5--3","1-5"],
	    ["1-5,7-8","-5-3","7-8"],
	    ["1-5,8-9","6-7","1-5,8-9"],
	    ["1-5,10-15","6-7","1-5"],
    
	    );

print "1..",1*@sets,"\n";
nearest_island();

sub nearest_island {
    print "#nearest_island\n";
    for my $setdata (@sets) {
	my $set1 = Set::IntSpan::Island->new($setdata->[0]);
	my $set2 = Set::IntSpan::Island->new($setdata->[2]);
	my $island;
	if($setdata->[1] =~ /[-,]/) {
	    $island = $set1->nearest_island(Set::IntSpan->new($setdata->[1]));
	} else {
	    $island = $set1->nearest_island($setdata->[1]);
	}
	printf("#nearest_island %s -> %s\n",$island->run_list,$set2->run_list);
	$island->run_list eq $set2->run_list || Not;
	OK;
    }
}
