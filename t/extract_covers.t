
use strict;
use Set::IntSpan::Island 0.01;

my $N = 1;
sub Not { print "not " };
sub OK { print "ok ", $N++, "\n" };

my @sets = (

	    [ {
		a=>"10",
		},
	      [ 
		[10,10,"a"],
		],
	      ],

	    [ {
		a=>"10",
		b=>"12",
		},
	      [ 
		[10,10,"a"],
		[11,11,""],
		[12,12,"b"],
		],
	      ],

	    [ {
		a=>"10-12",
		b=>"10",
		c=>"12",
		},
	      [ 
		[10,10,"ab"],
		[11,11,"a"],
		[12,12,"ac"],
		],
	      ],

	    [ {
		a=>"10-12",
		b=>"10",
		c=>"12,20-25",
		},
	      [ 
		[10,10,"ab"],
		[11,11,"a"],
		[12,12,"ac"],
		[13,19,""],
		[20,25,"c"],
		],
	      ],


	    [ {
		a=>"10-13",
		b=>"10",
		c=>"12",
		d=>"15",
		},
	      [ 
		[10,10,"ab"],
		[11,11,"a"],
		[12,12,"ac"],
		[13,13,"a"],
		[14,14,""],
		[15,15,"d"],
		],
	      ],

	    [ {
		a=>"10-13",
		b=>"10",
		c=>"12",
		d=>"15",
		e=>"15",
		},
	      [ 
		[10,10,"ab"],
		[11,11,"a"],
		[12,12,"ac"],
		[13,13,"a"],
		[14,14,""],
		[15,15,"de"],
		],
	      ],

	    [ {
		a=>"10-20",
		b=>"15-25"
		},
	      [ 
		[10,14,"a"],
		[15,20,"ab"],
		[21,25,"b"],
		],
	      ],

	    [ {
		a=>"10-20",
		b=>"15-20",
		c=>"25-30",
		},
	      [ 
		[10,14,"a"],
		[15,20,"ab"],
		[21,24,""],
		[25,30,"c"],
		],
	      ],

	    [ {
		a=>"10-20",
		b=>"22",
		c=>"23-24",
		d=>"25-30",
		},
	      [ 
		[10,20,"a"],
		[21,21,""],
		[22,22,"b"],
		[23,24,"c"],
		[25,30,"d"],
		],
	      ],

	    [ {
		a=>"5-35",
		b=>"10-20",
		c=>"22",
		d=>"23-24",
		e=>"25-30",
		f=>"27-28",
		},
	      [ 
		[5,9,"a"],
		[10,20,"ab"],
		[21,21,"a"],
		[22,22,"ac"],
		[23,24,"ad"],
		[25,26,"ae"],
		[27,28,"aef"],
		[29,30,"ae"],
		[31,35,"a"],
		],
	      ],

	    [ {
		a=>"10-15",
		b=>"12",
		c=>"14-20",
		d=>"25",
		},
	      [ 
		[10,11,"a"],
		[12,12,"ab"],
		[13,13,"a"],
		[14,15,"ac"],
		[16,20,"c"],
		[21,24,""],
		[25,25,"d"],
		],
	      ],

	    );

print "1..",1*@sets,"\n";
extract_covers();

use Data::Dumper;

sub extract_covers {
    print "#extract_covers\n";
    for my $setdata (@sets) {
	my $h;
	for my $id (keys %{$setdata->[0]}) {
	    $h->{$id} = Set::IntSpan::Island->new( $setdata->[0]{$id} );
	}
	my $covers = Set::IntSpan::Island->extract_covers( $h );
	my $results = $setdata->[1];
	my $ok = 1;
	if(@$results != @$covers) {
	    #print Dumper($covers);
	    $ok = 0;
	} else {
	    for my $i (0..@$results-1) {
		my $result = $results->[$i];
		my $cover  = $covers->[$i];
		if($cover) {
		    printf("#%3d %3d %5s %3d %3d %5s\n",
			   $cover->[0]->min,
			   $cover->[0]->max,
			   join("",@{$cover->[1]}),
			   @$result);
		    if($result->[0] == $cover->[0]->min &&
		       $result->[1] == $cover->[0]->max &&
		       $result->[2] eq join("",sort @{$cover->[1]})) {
			
		    } else {
			$ok = 0;
			last;
		    }
		} else {
		    $ok = 0;
		    last;
		}
	    }
	}
	$ok || Not();
	OK;
    }
}
