
use strict;
use Set::IntSpan::Island 0.04;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (
	    ["1-5",1,"1-5"],
	    ["1-5,7",1,"1-5,7"],
	    ["1-5,7",2,"1-5"],
	    ["1-5,7-8",1,"1-5,7-8"],
	    ["1-5,7-8",3,"1-5"],
	    ["1-5,7-8",6,"-"],
	    ["1-5,7,9-10",0,"1-5,7,9-10"],
	    ["1-5,7,9-10",10,""],
	    ["1-5,7","1-2","1-5"],
	    ["1-5,7,9-10","1-2","1-5"],
	    ["1-5,7,9-11","1-2","1-5,9-11"],
	    ["","1-2",""],
	    );

print "1..",1*@sets,"\n";
excise();

sub excise {
    print "#excise\n";
    for my $setdata (@sets) {
	my $set1 = Set::IntSpan::Island->new($setdata->[0]);
	my $set2 = Set::IntSpan::Island->new($setdata->[2]);
	my $set3;
	my $set4;
	if($setdata->[1] =~ /[,-]/ ) {
	    my $sizes = Set::IntSpan->new($setdata->[1]);
	    $set3 = $set1->excise($sizes);
	    $set4 = $set1->keep($sizes->complement);
	    Not if $set3 ne $set4;
	} else {
	    $set3 = $set1->excise($setdata->[1]);
	}
	printf("#excise %s -> %s\n",$set3->run_list,$set2->run_list);
	$set3->run_list eq $set2->run_list || Not;
	OK;
    }
}
