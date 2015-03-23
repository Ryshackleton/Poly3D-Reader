# GocadVertex object
# for use with GocadFault.pm and GocadElement.pm
# represents a vertex in a gocad file
package GocadVertex;
use strict;

# constructor
sub new {

	# to construct: my $vertex = new Vertex( v, INDEX, COORDSYS, X, Y, Z );
	# but these are probably the safest way to construct
	# -> or better yet my $vertex = new Vertex( @parsedArray );
	# -> or even $vertex = Vertex->new( @parsedArray );
	# see below for more detail
	my ($class) = $_[0];

	# @_ array is the subroutine input, which will consist of an array of strings and
	# numbers in the following order:
	# VRTX  1  -0.000329417912904007  -0.00130957110808484  -4.003368384524
	# ( recall that $_[0] was the object type (Vertex) above )
	my $self = {
	
		label => $_[1],	
		name => $_[2],
		x1 => $_[3],
		x2 => $_[4],
		x3 => $_[5]
	};
		
	# create the new object by blessing the reference to $self
	bless  ( $self, $class );

	# return the reference to self (self)
	return $self;

}

# GETTER METHODS
# generally have the form: ATTRIBUTENAME(), so to call:
# my $foo = $vertexReferenceName->name();  or
# my $foo = $vertexReferenceName->name;
#
# notes on how these methods work:
#  each method simply returns the variable of the same name by referring
#  to the object reference that called it $_[0].  Recall that the @_ array is
#  special in perl and contains the input arguments such that $_[0] is
#  always the first argument that contains a reference to the variable or 
#  object that called it, so if the method "name" is called by $vertex1, then 
#  $_[0] refers to $vertex1, which is also "$self" in this case.  These methods
#  could also be written as:
#  sub name {
#        my ($self) = @_;
#        return $self->{ name };
#  }
#
#  other notes -> calling this subroutine is not a way to change the values 
#  of a given vertex, so $vertex->name = 5; will not execute, but
#  $vertex->change_name( 5 ); will work, because there is a method change_name
#  that allows you to change the name of the vertex
sub name { return $_[0]->{ name };	    }
sub label { return $_[0]->{ label };        }
sub x1 { return $_[0]->{ x1 };              }
sub x2 { return $_[0]->{ x2 };              }
sub x3 { return $_[0]->{ x3 };              }

# return an array of the xyz coordinates of the vertex
# usage: my @array = $vertex->xyz_array;
sub xyz_array { return ( $_[0]->{x1}, $_[0]->{x2}, $_[0]->{x3} );     }

# SETTER METHODS
# general format is change_ATTRIBUTE( $newAttributeValue );
# to call: $vertex->change_name( $newAttributeValue );

# changes the name (index) of the vertex, returns nothing
# usage: $vertex->change_name( $newName );
sub change_name {
	my ($self, $newName ) = @_;
	
	$self->{name} = $newName;
}

# changes the label of a vertex
# usage: $vertex->change_label( $newLabel );
sub change_label {

	my ( $s, $newLabel ) = @_;

	$s->{label} = $newLabel;

}

# changes the x1, x2, x3 array of a vertex
# usage: $vertex->change_xyz( @newXYZarray );
sub change_xyz {

	my ( $s, @coords ) = @_;

	$s->{x1} = $coords[0];
	$s->{x2} = $coords[1];
	$s->{x3} = $coords[2];
}

# TO STRING METHODS
# general format is ATTRIBUTE_to_string()
#to call: $string = xyz_to_string();

# returns the xyz coordinates as a string (no endline character)
# usage: my $string = $vertexRef->xyz_to_string;
sub xyz_to_string {
	my ($self) = @_;

	return $self->{x1}." ".$self->{x2}." ".$self->{x3}." ";
}

# returns a standard gocad gocad vertex input line to a string (no endline character)
# example VRTX 2 4.000 3.775757 8.49444
# usage: my $string = $vertex->inputLine_to_string;
sub inputLine_to_string {

	my ( $s ) = @_;
	return $s->{label}." ".$s->{name}." ".$s->xyz_to_string();

}

1;
