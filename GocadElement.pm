# GocadElement object
# for use with GocadFault.pm and GocadVertex.pm
# represents a TRGL or element in a gocad file
package GocadElement;
use strict;

# constructor
# to construct: my $element = new Element( $indexNumber, @parsedArray );
# where parsed array is an array consisting of the following entries from a
# GOCAD file like this:
# TRGL  515  516  530
sub new {
	
	# class type (Element in this case) is automatically assigned to the
	# first element in the array
	my ($class) = $_[0];

	# @_ array is the input, which will consist of an array of strings and
	# numbers in the following order:
	# TRGL  515  516  530
	# ( recall that $_[0] was the object type (Element) above )
	my $self = {
		
		label => $_[1],
		v1 => $_[2],
		v2 => $_[3],
		v3 => $_[4]

	};
		
	# create the new object by blessing the reference to $self
	bless  ( $self, $class );

	# return the reference to self
	return $self;

}

# GETTER METHODS
# generally have the form: ATTRIBUTENAME(), so to call:
# $elementReferenceName->index()
# 
# notes on how these methods work:
# #  each method simply returns the variable of the same name by referring
# #  to the object reference that called it $_[0].  Recall that the @_ array is
# #  special in perl and contains the input arguments such that $_[0] is
# #  always the first argument that contains a reference to the variable or 
# #  object that called it, so if the method "index" is called by $element1, then 
# #  $_[0] refers to $element1, which is also "$self" in this case.  These methods
# #  could also be written as:
# #  sub index {
# #        my ($self) = @_;
# #        return $self->{ index };
# #  }
# 
sub label {  return $_[0]->{ label };       }
sub v1 { return $_[0]->{ v1 };              }
sub v2 { return $_[0]->{ v2 };              }
sub v3 { return $_[0]->{ v3 };              }

# returns a 3 or 4 entry array of vertex connectivities (depends
# on how many vertices there actually are )
sub connectivity_array {

	my ( $s ) = @_;

	return ( $s->v1(), $s->v2(), $s->v3() ); 

}
# SETTER METHODS
# general format is change_ATTRIBUTE( $newAttributeValue );
# to call: $newIndex = $vertex->change_index( $newAttributeValue );

# change connectivity array (returns nothing)
# changes the vertex connectivities to a new array that is given
# exits with an error message if there are not 3 vertices in the array
# $element->change_connectivity_array( @newArray );
sub change_connectivity_array {

	my ( $s, @newArray ) = @_;

	# check to make sure there are three vertices in the 
	# new array or die with an error message
	my $length = @newArray;
	my $id = $s->inputLine_to_string;
	( $length == 3 ) || die "Can't assign a vertex array
			of length $length, to $id\n";
	
	# assign the new vertices
	$s->{ v1 } = $newArray[ 0 ];
	$s->{ v2 } = $newArray[ 1 ];
	$s->{ v3 } = $newArray[ 2 ];

}
		

# TO STRING METHODS
# general format is ATTRIBUTE_to_string()

# returns a string representing the connectivity between elements (no endline)
# usage: my $string = $element->connectivity_to_string;
sub connectivity_to_string {
	my ($s ) = @_;

	return $s->v1()." ".$s->v2()." ".$s->v3();

}

# returns a string representing a standard gocad input line for
# a TRGL with it's connectivities (no endline)
# example: TRGL 3 5 8
# usage: my $string = $element->inputLine_to_string;
sub inputLine_to_string {
	my ($s) = @_;

	return $s->label()." ".$s->v1()." ".$s->v2()." ".
		$s->v3();

}
1;
