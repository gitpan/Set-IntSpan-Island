

=pod

=head1 NAME

Set::IntSpan::Island - extension for Set::IntSpan to handle islands and covers

=head1 SYNOPSIS

  use Set::IntSpan::Island

  # inherits normal behaviour from Set::IntSpan
  $set = Set::IntSpan::Enhanced->new( $set_spec );
  # special two-value input creates a range a-b
  $set = Set::IntSpan::Enhanced->new( $a,$b );

  # equivalent to $set->cardinality($another_set)->size;
  if ($set->overlap( $another_set )) { ... }

  # negative if overlap, positive if no overlap
  $distance = $set->distance( $another_set );

  # remove islands shorter than $minlength
  $set = $set->remove_short( $minlength );

  # fill holes up to $maxholesize
  $set = $set->fill( $maxholesize );

  # return a set composed of islands of $set that overlap $another_set
  $set = $set->find_island( $another_set );

  # return a set comopsed of the nearest non-overlapping island(s) to $another_set
  $set = $set->nearest_island( $another_set );

  # construct a list of covers by exhaustively intersecting all sets
  @covers = Set::IntSpan::Island->extract_cover( { id1=>$set1, id2=>set2, ... } );
  for $cover (@covers) {
    ($coverset,@ids) = ($cover->[0], @{$cover->[1]});
    print "cover",$coverset->run_list,"contains sets",join(",",@ids);
  }

=head1 DESCRIPTION

=head2 Data Structure

This module extends the Set::IntSpan module. It adds a number of methods to Set::IntSpan that are specific to islands and covers. An integer set, as represented by Set::IntSpan, is a collection of covers on the integer line

  ...-----xxxx----xxxxxxxx---xxxxxxxx---xx---x----....

=head2 Terminology

An integer set may be composed of one or more contiguous spans. In this module, spans are called islands. Regions not in the set that fall between adjacent spans are termed holes. For example, this set

  ...-----xxxxx----xx---x-----...

has three islands and two holes. Since this is a finite set, the two infinite regions on either side of the set are not counted as holes within the context of this module.

=head2 Operations

This module permits the following operations, here shown graphically. Each method is described fully in the METHODS section.

=head1 METHODS

=cut

package Set::IntSpan::Island;

use 5;
use strict;
use base qw(Exporter);
use Set::IntSpan 1.10;
use Carp;

our @ISA = qw(Set::IntSpan);
our @EXPORT_OK = qw();
our $VERSION = '0.01';

=pod

=head2 $set = Set::IntSpan::Enhanced->new( $set_spec )

Constructs a set using the set specification as supported by C<Set::IntSpan>.

=head2 $set = Set::IntSpan::Enhanced->new( $a, $b )

Extension to C<Set::IntSpan> C<new> method, this double-argument version creates a set formed by the range a-b. This is equivalent to

  $set = Set::IntSpan::Enhanced->new("$a-$b")

but permits initialization from a list instead of a string.

=cut 

sub new {
  my ($this, @args) = @_;
  my $class = ref($this) || $this;
  my $self;
  if(@args <= 1) {
    # relegate to parent
    $self = $class->SUPER::new(@args);
  } elsif (@args==2) {
    # treat as cover
    $self = $class->SUPER::new(sprintf("%d-%d",@args));
  } else {
    croak "Set::IntSpan::Island: cannot create object using more than two integers [@args]"; 
  }
  return $self;
}

=pod

=head2 $set_copy = $set->duplicate()

Creates a copy of $set.

=cut

sub duplicate {
  my $self = shift;
  return $self->new($self->run_list);
}

=pod

=head2 $overlap_amount = $set->overlap( $another_set );

Returns the size of intersection of two sets. Equivalent to

  $set->intersect( $another_set )->size;

=cut

sub overlap {
  my ($self,$set) = @_;
  return $self->intersect($set)->size;
}

=pod

=head2 $d = $set->distance( $another_set )

Returns the distance between sets, measured as follows. If the sets overlap, then the distance is negative and given by

  $d = - $set->overlap( $another_set )

If the sets do not overlap, $d is positive and given by the distance on the integer line between the two closest islands of the sets.

=cut

sub distance {
  my ($set1,$set2) = @_;
  return undef unless $set1 && $set2;
  my $overlap = $set1->overlap($set2);
  my $min_d;
  if($overlap) {
    return -$overlap;
  } else {
    for my $span1 ($set1->sets) {
      for my $span2 ($set2->sets) {
	my $d1 = abs($span1->min - $span2->max);
	my $d2 = abs($span1->max - $span2->min);
	my $d  = $d1 < $d2 ? $d1 : $d2;
	if(! defined $min_d || $d < $min_d) {
	  $min_d = $d;
	}
      }
    }
  }
  return $min_d;
}

=head2 $d = $set->sets()

Returns all spans in $set as C<Set::IntSpan::Island> objects.

=cut

sub sets {
  my $set = shift;
  return map { $set->new($_)->cover } $set->spans;
}

=head2 $set = $set->excise( $minlength)

Removes all islands within $set smaller than $minlength.

=cut

sub excise {
  my ($self,$minlength) = @_;
  my $set = $self->new();
  map { $set = $set->union($_) } grep($_->size >= $minlength, $self->sets);
  return $set;
}

=head2 $set = $set->fill( $maxlength)

Fills in all holes in $set smaller than $maxlength.

=cut

sub fill {
  my ($self,$maxfill) = @_;
  my $set = $self->duplicate();
  if($maxfill > 0) {
    for my $hole ( $set->holes->sets ) {
      if($hole->size <= $maxfill) {
	$set = $set->union($hole);
      }
    }
  }
  return $set;
}

=head2 $set = $set->find_islands( $integer )

Returns a set containing the island in $set containing C<$integer>. If C<$integer> is not in C<$set>, an empty set is returned.

=head2 $set = $set->find_islands( $another_set )

Returns a set containing all islands in $set intersecting C<$another_set>. If C<$set> and C<$another_set> have an empty intersection, an empty set is returned. 

=cut

sub find_islands {
  my ($self,$member) = @_;
  if(ref($member) eq ref($self)) {
    # 
  } elsif (! ref($member)) {
    $member = $self->new($member);
  } else {
    croak "Set::IntSpan::Island: don't know how to deal with input to find_island";
  }
  my $islands = $self->new;
  return $islands if ! $self->overlap($member);
  for my $set ($self->sets) {
    $islands = $islands->union($set) if $set->overlap($member);
  }
  return $islands;
}

=pod 

=head2 $set = $set->nearest_island( $integer )

Returns the nearest island(s) in C<$set> that contains, but does not overlap with, C<$integer>. If C<$integer> lies exactly between two islands, then the returned set contains these two islands.

=head2 $set = $set->nearest_island( $another_set );

Returns the nearest island(s) in C<$set> that intersects, but does not overlap with, C<$another_set>. If C<$another_set> lies exactly between two islands, then the returned set contains these two islands.

=cut

sub nearest_island {
  my ($self,$member) = @_;
  if(ref($member) eq ref($self)) {
    # 
  } elsif (! ref($member)) {
    $member = $self->new($member);
  } else {
    croak "Set::IntSpan::Island: don't know how to deal with input to nearest_island";
  }
  my $island = $self->new();
  my $min_d;
  for my $s ($self->sets) {
    for my $ss ($member->sets) {
      next if $s->overlap($ss);
      my $d = $s->distance($ss);
      if(! defined $min_d || $d <= $min_d) {
	if(defined $min_d && $d == $min_d) {
	  $island = $island->union($s);
	} else {
	  $min_d = $d;
	  $island = $s;
	}
      }
    }
  }
  return $island;
}

=pod

=head2 $cover_data = extract_covers( $set_hash_ref )

Given a C<$set_hash> reference

  { id1=>$set1, id2=>$set2, ..., idn=>$setn}

where $setj is a finite Set::IntSpan::Enhanced object and idj is a unique key, C<extract_covers> performs an exhaustive intersection of all sets and returns a list of all covers and set memberships. For example, given the id/runlist combination
 
  a  10-15
  b  12
  c  14-20
  d  25

The covers are

  10-11 a
  12    a b
  13    a
  14-15 a c
  16-20 c
  21-24 -
  25    d

The cover data is returned as an array reference and its structure is

  [ [ $cover_set1, [ id11, id12, id13, ... ] ],
    [ $cover_set2, [ id21, id22, id23, ... ] ],
    ...
  ]

If a cover contains no elements, then its entry is

  [ $cover_set, [ ] ]

=cut

sub extract_covers {
  my ($self,$sets) = @_;
  
  my @sets = map { [ $_, $sets->{$_} ] } sort {$sets->{$a}->min <=> $sets->{$b}->min || $sets->{$a}->max <=> $sets->{$b}->max} keys (%$sets);
  my %edges;
  use Data::Dumper;
  for my $set (map {$_->[1]} @sets) {
    map {$edges{$_}++} ( map { ($_->[0]-1,$_->[0],$_->[1],$_->[1]+1) } $set->spans );
  }
  my @edges = sort {$a <=> $b} keys %edges;
  splice(@edges,0,1);
  splice(@edges,-1,1);
  my $i = 0;
  my $j_low = 0;
  my $covers;
  #print join(" ",@edges),"\n";
  while($i < @edges) {
    my $edge      = $edges[$i];
    my $edge_next = $edges[$i+1];
    my $cover;
    if(! defined $edge_next || $edge + 1 == $edge_next) {
      $cover = $self->new($edge);
      $i++;
    } else {
      $cover = $self->new($edge,$edge_next);
      $i += 2;
    }
    #printf("cover %3d %3d    j_low %d\n",$cover->min,$cover->max,$j_low);
    my $found;
    my $j_low_incr = 0;
    push @$covers, [ $cover , []];
    for my $j ($j_low..@sets-1) {
      my ($id,$set) = @{$sets[$j]};
      my $ol  = $set->overlap($cover);
      if($ol) {
	$found = 1;
	#print "      ",$sets[$j][0],$set->run_list,"\n" if $ol;
	push @{$covers->[-1][1]}, $id;
      } else {
	if($found) {
	  last if $set->min > $cover->max;
	} else {
	  $j_low_incr++;
	}
      }
    }
    if(@$covers > 1 &&
       join("",@{$covers->[-1][1]}) eq join("",@{$covers->[-2][1]})) {
      $covers->[-2][0] = $covers->[-2][0]->union ($covers->[-1][0]);
      splice(@$covers,-1,1);
    }
    $j_low += $j_low_incr if $found;
  }
  return $covers;
}

1;

__END__

=head1 AUTHOR

Martin Krzywinski <martink@bcgsc.ca>

=head1 ACKNOWLEDGMENTS

=item * Steve McDougall <swmcd@theworld.com>

=head1 HISTORY

v0.01 5 Mar 2007

=head1 SEE ALSO

Set::IntSpan by Steven McDougall

=head1 COPYRIGHT

Copyright (c) 2007 by Martin Krzywinski. This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
