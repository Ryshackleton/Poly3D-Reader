# instantiable code for creating and manipulating Vertices in Poly3d
# for use with Poly3dFault.pm and Poly3dElement.pm
# written by Ryan Shackleton, summer 2005


# ===========================================================
# SUMMARY OF SUBROUTINES
# ===========================================================
# constructor: new
# used to create Poly3dVertex objects
# 	my $newVertex = new Poly3dVertex( @parsedArray );
# where @parsedArray is an array of variables from a Poly3d
# inputfile in the following order:
# *v name     csys   x1      x2            x3
# *- -------- ----- --------- -------  ------
# v  1  global  0.000000   3.000000   -4.000000
# so, $parsedArray[0] = v, $parsedArray[1] = 1, 
# $parsedArray[2] = global, $parsedArray[3] = 0.000000, etc.
# -----------------------------------------------------------



# ===========================================================
# GETTER METHODS
# ===========================================================
# these methods return data from within the poly3d object, so 
# to "get" any of the data input into the file, just call
# the variable name as shown below:
# 	my $nameVariable = $vertex->name;
# 	my $x = $vertex->x1;
# 	my $coordSys = $vertex->csys;
# 
# other useful getter methods:
# -----------------------------------------------------------
# subroutine: xyz_array
# returns an array of the x1, x2, and x3 values
# ***returned array is numbered from 0 to 2
# or from 0 to @xyzs - 1 in the case below:
# 	my @xyzs = $vertex->xyz_array;
# -----------------------------------------------------------


# ===========================================================
# SETTER METHODS
# change variables in a vertex
# ===========================================================
# subroutine: change_name
# 	$vertex->change_name( $changeNameTo );
# changes the name of a vertex
# -----------------------------------------------------------
# subroutine: change_vert_xyz
# changes the x1, x2, and x3 coordinates of the vertex
# 	$vertex->change_vert_xyz( @arrayOfXYZCoordinates );
# takes an array of 3 x,y,z coordinates and
# replaces the x1, x2, and x3 vertex coordinates
# with the values in the array
# -----------------------------------------------------------
# subroutine: change_variable
# changes any variable whose name you specify to a value given
# 	$vertex->change_variable( $variableName, $to );
# 	eg: $vertex->change_variable( "x1", 0.0003 );
# 	modifies the value in x1 to be 0.0003
# BE CAREFUL WITH THIS METHOD!!!!!  
# Make sure you know what you're changing!!!
# -----------------------------------------------------------



# ===========================================================
# TO STRING METHODS
# return concatenated strings of variables in the vertex
# ===========================================================
# subroutine: inputLine_to_string
# returns a space delimited string containing the information
# parsed from the input file
# 	my $string = $vertex->inputLine_to_string
# eg: v  1  global  0.000000   0.000000   -4.000000
# -----------------------------------------------------------
# subroutine: xyz_to_string
# returns a space delimited string of the x1, x2, and x3
# variables in the vertex
# 	my $xyzString = $vertex->xyz_to_string
# -----------------------------------------------------------


# package declaration
package Poly3dVertex;
use strict;

# constructor
sub new {

	my ($class) = $_[0];

	# @_ array is the subroutine input, which will consist of an array of strings and
	# numbers in the following order:
	# v  1  global  -0.000329417912904007 -0.00130957110808484 -4.003368384524
	# where $_[1] = v, $_[2] = 1, $_[3] = global, etc.
	# ( recall that $_[0] was the object type (Vertex) above )
	my $self = {
		
		name => $_[2],
		csys => $_[3],
		x1 => $_[4],
		x2 => $_[5],
		x3 => $_[6]
	};
		
	# create the new object by blessing the reference to $self
	bless  ( $self, $class );

	# return the reference to self (self)
	return $self;

}

# GETTER METHODS
# generally have the form: ATTRIBUTENAME(), so to call:
# $vertexReferenceName->name()
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
sub name {  return $_[0]->{ name };	    }
sub csys { return $_[0]->{ csys };  }
sub x1 { return $_[0]->{ x1 };              }
sub x2 { return $_[0]->{ x2 };              }
sub x3 { return $_[0]->{ x3 };              }

# return an array of the xyz coordinates of the vertex
sub xyz_array { return ( $_[0]->{x1}, $_[0]->{x2}, $_[0]->{x3} );     }

# SETTER METHODS
# general format is change_ATTRIBUTE( $newAttributeValue );
# to call: $vertex->change_name( $newAttributeValue );
sub change_name {
	my ($self, $newName ) = @_;
	
	$self->{name} = $newName;
}

sub change_vert_xyz {

	my ( $s, @xyz ) = @_;

	$s->{ x1 } = $xyz[0];
	$s->{ x2 } = $xyz[1];
	$s->{ x3 } = $xyz[2];
}

# UNIVERSAL SETTER: BE CAREFUL WITH THIS METHOD!!!!!  
# Make sure you know what you're changing!!!
# changes any variable whose name you specify to a value given
# 
# usage: $obsObject->change_variable( $variableName, $to );
# eg: $obsObject->change)_variable( "E11", 7.1797392 );
# 	modifies the value in E11 to be 7.1797392
sub change_variable {
	my ($s, $variableName, $to ) = @_;

	$s-> { $variableName } = $to;

}

# TO STRING METHODS
# general format is ATTRIBUTE_to_string()
#to call: $string = xyz_to_string();
#
sub xyz_to_string {
	my( $self ) = @_;

	return $self->{x1}."  ".$self->{x2}."  ".$self->{x3}."  ";
}

sub inputLine_to_string {
	my ($self) = @_;

        return "v ".$self->{name}."  ".$self->{csys}."  ".$self->xyz_to_string();

}
		
1;
