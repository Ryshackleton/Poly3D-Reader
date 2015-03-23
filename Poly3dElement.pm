# instantiable code for creating and manipulating Elements in Poly3d
# for use with Poly3dFault.pm and Poly3dVertex.pm
# written by Ryan Shackleton, summer 2005

# ===========================================================
# SUMMARY OF SUBROUTINES
# ===========================================================
# constructor: new
# 	 my $element = new Element( $nameNumber, @parsedArray );
# REMEMBER TO INCLUDE A NAME (NUMBER) IN YOUR ELEMENT DECLARATION!!!!!
# where @parsedArray is an array consisting of the following entries from a
# poly3d INPUT file like this:
# *e  #vert  Bcsys  BC type	BC1	BC2	BC3	v1 v2  v3 v4 
# *-  -----  -----  -------	---	---	---	-- --  -- --
# e  3  global  ttb   0 0 0   515 516 530
# if there are only 3 vertices (ie it's a triangular element,
# 			then v4 will be undefined)
# -----------------------------------------------------------




# ===========================================================
# GETTER METHODS
# ===========================================================
# these methods return data from within the poly3d object, so 
# to "get" any of the data input into the file, just call
# the variable name as shown below:
# 	my $stringBcsys = $element->Bcsys;
# 	my $stringBC1 = $element->BC1;
#  NOTABLE EXCEPTIONS: 
#  1) spaces in variable names are replaced by an _, so
#  "BC type" in poly3d will be called BC_type in the Poly3dElement
#  Poly3d      Poly3dElement 
#  BC type ----> BC_type
#  
#  2) variables in poly3d with odd characters are replaced:
#  Poly3d      Poly3dElement
#  #vert ---->  nVerts
#  U1(+)  ---->  U1pos
#  U1(-)  ---->  U1neg
#  U2(+)  ---->  U2pos
#  U2(-)  ---->  U2neg
#  U3(+)  ---->  U3pos
#  U3(-)  ---->  U3neg
#
# Other useful getter methods:
# -----------------------------------------------------------  
# subroutine: xyz_array
# returns an array of the X1C, X2C, and X3C values
# ***returned array is numbered from 0 to 2
# or from 0 to @xyzs - 1 in the case below:
# 	my @xyzs = $element->xyz_array;
# -----------------------------------------------------------
# subroutine: connectivity_array
# returns a 3 or 4 element array containing the vertex 
# connectivities in the element
# ***returned array is numbered from 0 to $element->nVerts
# or from 0 to @connectivity - 1 in the case below:
# 	my @connectivity = $element->connectivity_array;
# -----------------------------------------------------------   




# ===========================================================
# SETTER METHODS
# change variables in an element
# ===========================================================
# subroutine: change_name
# 	$element->change_name( $changeNameTo );
# changes the name of an element
# -----------------------------------------------------------
# subroutine: change_elt_xyz
# changes the X1C, X2C, and X3C coordinates of the element
# 	$element->change_elt_xyz( @arrayOfXYZCoordinates );
# takes an array of 3 x,y,z coordinates and
# replaces the X1C, X2C, and X3C element center coordinates
# with the values in the array
# -----------------------------------------------------------
# change_connectivity_array
# takes an array of 3 or 4 numbers and replaces the element's connectivity
# array with the array passed in 
# 	$eltRef->change_connectivity_array( @newArray );
# -----------------------------------------------------------
# subroutine: change_variable
# changes any variable whose name you specify to a value given
# 	$element->change_variable( $variableName, $to );
# 	eg: $element->change_variable( "T1", 0.0003 );
# 	modifies the value in T1 to be 0.0003
# BE CAREFUL WITH THIS METHOD!!!!!  
# Make sure you know what you're changing!!!
# -----------------------------------------------------------



# ===========================================================
# "ADDER" METHODS
# add information to the element (displacements and stresses)
# ===========================================================
# subroutine: add_displacements
# adds a parsed data line from DISPLACEMENTS output
# 	$elt->add_displacements( @p );
# where @p is an array of numbers in the following order:
# ELT X1C X2C X3C B1 U1(+) U1(-) B2 U2(+) U2(-) B3 U3(+) U3(-) Coord Sys
# (recall that U1(+) becomes U1pos, and U1(-) becomes U1neg, etc)
# -----------------------------------------------------------
# subroutine: add_stresses
# adds a parsed data line from STRESSES (TRACTIONS) output
# 	$elt->add_stresses( @p );
# where @p is an array of numbers in the following order:
# ELT X1C X2C  X3C T1 T2  T3 Coord Sys
# -----------------------------------------------------------



# ===========================================================
# TO STRING METHODS
# return concatenated strings of variables in the element
# ===========================================================
# subroutine: inputLine_to_string
# returns a space delimited string containing the information
# parsed from the input file
# 	my $string = $element->inputLine_to_string
# eg: e  3  global  ttb   0 0 0   515 516 530
# -----------------------------------------------------------
# subroutine: displacements_to_string
# returns a space delimited string containing the variables
# parsed in from the poly3d output DISPLACEMENTS section
# 	my $line = $element->displacements_to_string;
# -----------------------------------------------------------
# subroutine: stresses_to_string
# returns a space delimited string containing the variables
# parsed in from the poly3d output STRESSES (TRACTIONS) section
# 	my $line = $element->displacements_to_string;
# -----------------------------------------------------------
# subroutine: connectivity_to_string
# returns a string containing the 3 or 4 vertex connectivities
# 	my $connectivityString = $elment->connectivity_to_string;
# -----------------------------------------------------------



# package declaration
package Poly3dElement;
use strict;

# constructor
# to construct: my $element = new Element( $nameNumber, @parsedArray );
# where parsed array is an array consisting of the following entries from a
# poly3d INPUT file like this:
# e numElts Bcsys BC_type BC1 BC2 BC3 v1 v2 v3 v4
# e  3  global  ttb   0 0 0   515 516 530
# (if there are only 3 vertices (ie it's a triangular element,
# then v4 will be undefined)
# REMEMBER TO INCLUDE AN INDEX NUMBER IN YOUR ELEMENT DECLARATION!!!!!
sub new {
	
	# class type (Element in this case) is automatically assigned to the
	# first element in the array
	my ($class) = $_[0];

	# @_ array is the input, which will consist of an array of strings and
	# numbers in the following order:
	# $nameNumber e  3  global  ttb   0 0 0   515 516 530
	# where $_[1] = $nameNumber, $_[2] = e, $_[3] = 3, $_[4] = global, etc.
	# ( recall that $_[0] was the object type (Element) above )
	my $self = {
		
		# from input files
		name => $_[1],
		nVerts => $_[3],
		Bcsys => $_[4],
		BC_type => $_[5],
		BC1 => $_[6],
		BC2 => $_[7],
		BC3 => $_[8],
		v1 => $_[9],
		v2 => $_[10],
		v3 => $_[11],
		v4 => $_[12],
		
		#from output files (all undefined when created by "new" )
		X1C => undef,
		X2C => undef,
		X3C => undef,
	       	
		# from DISPLACEMENTS output
		B1 => undef,
		U1pos => undef,
		U1neg => undef,
		
		B2 => undef,
		U2pos => undef,
		U2neg => undef,
		
		B3 => undef,
		U3pos => undef,
		U3neg => undef,
		
		#from STRESSES (TRACTIONS) output
		T1 => undef,
		T2 => undef,
		T3 => undef

	};
		
	# create the new object by blessing the reference to $self
	bless  ( $self, $class );

	# return the reference to self
	return $self;

}

# GETTER METHODS
# generally have the form: ATTRIBUTENAME(), so to call:
# $elementReferenceName->name()
# 
# notes on how these methods work:
# #  each method simply returns the variable of the same name by referring
# #  to the object reference that called it $_[0].  Recall that the @_ array is
# #  special in perl and contains the input arguments such that $_[0] is
# #  always the first argument that contains a reference to the variable or 
# #  object that called it, so if the method "name" is called by $element1, then 
# #  $_[0] refers to $element1, which is also "$self" in this case.  These methods
# #  could also be written as:
# #  sub name {
# #        my ($self) = @_;
# #        return $self->{ name };
# #  }
# 
# from input files
sub name {  return $_[0]->{ name };       }
sub nVerts {  return $_[0]->{ nVerts };     }
sub Bcsys { return $_[0]->{ Bcsys };  }
sub BC_type { return $_[0]->{ BC_type };      }
sub BC1 {   return $_[0]->{ BC1 };          }
sub BC2 {    return $_[0]->{ BC2 };         }
sub BC3 {     return $_[0]->{ BC3 };        }
sub v1 { return $_[0]->{ v1 };              }
sub v2 { return $_[0]->{ v2 };              }
sub v3 { return $_[0]->{ v3 };              }
sub v4 { return $_[0]->{ v4 };              }

# from output files
sub X1C {  return $_[0]->{ X1C };       }
sub X2C {  return $_[0]->{ X2C };     }
sub X3C { return $_[0]->{ X3C };  }

sub xyz_array { return ( $_[0]->X1C, $_[0]->X2C, $_[0]->X3C ); }

# from DISPLACEMENTS
sub B1 { return $_[0]->{ B1 };      }
sub U1pos {   return $_[0]->{ U1pos };          }
sub U1neg {    return $_[0]->{ U1neg };         }
sub B2 {     return $_[0]->{ B2 };        }
sub U2pos {   return $_[0]->{ U2pos };          }
sub U2neg {    return $_[0]->{ U2neg };         }
sub B3 {     return $_[0]->{ B3 };        }
sub U3pos {   return $_[0]->{ U3pos };          }
sub U3neg {    return $_[0]->{ U3neg };         }

# from STRESSES (TRACTIONS)
sub T1 {     return $_[0]->{ T1 };        }
sub T2 {   return $_[0]->{ T2 };          }
sub T3 {    return $_[0]->{ T3 };         }

# returns a 3 or 4 entry array of vertex connectivities (depends
# on how many vertices there actually are )
sub connectivity_array {

	my ( $s ) = @_;

	( $s->nVerts() == 3 ) ? return ( $s->v1(), $s->v2(), $s->v3() ) 
	: return (  $s->v1(), $s->v2(), $s->v3(), $s->v4()  );

}

# SETTER METHODS
# general format is change_ATTRIBUTE( $newAttributeValue );
# to call: $newIndex = $vertex->change_name( $newAttributeValue );

sub change_name {
	my ($self, $newIndex) = @_;
	
	$self->{name} = $newIndex;
}

# change_elt_xyz
# takes an array of 3 x,y,z coordinates and
# replaces the X1C, X2C, and X3C element center coordinates
# with the values in the array
sub change_elt_xyz {

	my ( $self, @xyz ) = @_;

	$self->{ X1C } = $xyz[0];
	$self->{ X2C } = $xyz[1];
	$self->{ X3C } = $xyz[2];

}

# change_connectivity_array
# takes an array of 3 or 4 numbers and replaces the element's connectivity
# array with the array passed in 
# usage: $eltRef->change_connectivity_array( @newArray );
sub change_connectivity_array {
	my ( $s, @c ) = @_;

	if( @c == 3 ){

		$s->{v1} = $c[0];
		$s->{v2} = $c[1];
		$s->{v3} = $c[2];
		
	} elsif( @c == 4 ) {

		$s->{v1} = $c[0];
		$s->{v2} = $c[1];
		$s->{v3} = $c[2];
		$s->{v4} = $c[3];
	} else {

		die "Can't add vertex arrays that have more than 4 vertices";
	}
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

# adds a parsed data line from DISPLACEMENTS output
# usage $fault->elt->add_displacements( @p );
# where @p is an array of numbers in the following order:
#  ELT  X1C  X2C X3C  B1  U1(+)  U1(-)  B2  U2(+)  U2(-) B3 U3(+) U3(-) Coord Sys
sub add_displacements {

	my ( $s, @p ) = @_;

	( $s->name == $p[0] ) || die "Adding wrong information at element ".
				$s->inputLine_to_string."\n";
	$s->{ X1C } = $p[1];
	$s->{ X2C } = $p[2];
	$s->{ X3C } = $p[3];
	$s->{ B1  } = $p[4];
	$s->{ U1pos } = $p[5];
	$s->{ U1neg } = $p[6];
	$s->{ B2  } = $p[7];
        $s->{ U2pos } = $p[8];
        $s->{ U2neg } = $p[9];
        $s->{ B3  } = $p[10];
        $s->{ U3pos } = $p[11];
        $s->{ U3neg } = $p[12];
	( $s->Bcsys eq $p[13] ) || die "Coordinate system changed between".
			" input and output at Element ".$s->name."\n";
	return 1;

}

sub add_stresses {

        my ( $s, @p ) = @_;

        ( $s->name == $p[0] ) || die "Adding wrong information at element ".
                               $s->inputLine_to_string."\n";
						
        $s->{ X1C } = $p[1];
        $s->{ X2C } = $p[2];
        $s->{ X3C } = $p[3];
        $s->{ T1  } = $p[4];
        $s->{ T2 } = $p[5];
        $s->{ T3 } = $p[6];

        ( $s->Bcsys eq $p[7] ) || die "Coordinate system changed between".
                         " input and output at Element ".$s->name."\n";
        return 1;

}
		
# TO STRING METHODS
# general format is ATTRIBUTE_to_string()
#to call: $string = xyz_to_string();
#
sub connectivity_to_string {
	my ($s ) = @_;

	$s->v4() ? return $s->v1()."  ".$s->v2()."  ".$s->v3()."  ".$s->v4()
	:  return $s->v1()."  ".$s->v2()."  ".$s->v3();

}

sub inputLine_to_string {
	my ($s) = @_;

	return "e  ".$s->nVerts()."  ".$s->Bcsys()."  ".$s->BC_type()."  ".$s->BC1().
		"  ".$s->BC2()."  ".$s->BC3()."  ".$s->v1()."  ".$s->v2()."  ".
		$s->v3()."  ".$s->v4();

}
sub displacements_to_string {
	my ($s) = @_;

	my $a = "  ";

	return  $s->name.$a.$s->X1C.$a.$s->X2C.$a.$s->X3C.$a.
		$s->B1.$a.$s->U1pos.$a.$s->U1neg.$a.
		$s->B2.$a.$s->U2pos.$a.$s->U2neg.$a.
		$s->B3.$a.$s->U3pos.$a.$s->U3neg.$a.
		$s->Bcsys;
}

sub stresses_to_string {
	my ($s) = @_;

	my $a = "  ";

	return $s->name.$a.$s->X1C.$a.$s->X2C.$a.$s->X3C.$a.
		$s->T1.$a.$s->T2.$a.$s->T3.$a.$s->Bcsys;
}



# -----------------------------------------------------------------------------
# subroutine: strike_slip_vector  INCOMPLETE!!!!!
# 	my @ssVector = $elt->strike_slip_vector( $faultRef, $normalize );
#	my @ssVector = $elt->strike_slip_vector( $faultRef, 0 );
# takes a reference to the parent fault and a 1 if the vector 
# should be normalized or 0 if not and returns a 3 element array
# representing the u, v, w components of the strike slip vector
# of the element (vertices of the element must be defined and in the 
# fault being referenced)
sub strike_slip_vector {

	my ( $s, $f, $normalize ) = @_;

	#define an array to hold the vector
	my @vector;

	# define the three vertices of the element to make things simpler
	my $v1 = $f->vert( $s->v1 );
	my $v2 = $f->vert( $s->v2 );
	my $v3 = $f->vert( $s->v3 );
	
	# calculate the vector components: u = 
	$vector[0] = ( $v1->X2 - $v2->X2 ) * ( $v2->X3 - $v3->X3 )
	 - ( $v1->X3 - $v2->X3 ) * ( $v2->X2 - $v3->X2 );

	# ASHLEY HAS A NEGATIVE IN FRONT OF THE NORMAL OF THIS COMPONENT,
	# DON'T KNOW WHY HE DID IT THERE, BUT I'LL PUT IT HERE
	# v =
	$vector[1] = - ( $v1->X3 - $v2->X3 ) * ( $v2->X1 - $v3->X1 )
	 - ( $v1->X1 - $v2->X1 ) * ( $v2->X3 - $v3->X3 );

	# not sure why we're calculating this if it's going to be
	# zero when normalized anyway, DOUBLE CHECK THIS!!!!
	# w = 
	$vector[2] = ( $v1->X1 - $v2->X1 ) * ( $v2->X2 - $v3->X2 )
	 - ( $v1->X2 - $v2->X2 ) * ( $v2->X1 - $v3->X1 );

	# if required, normalize the vector
	if ( $normalize ) {
		
		# set the third vector component equal to zero
		$vector[2] = 0;
		
		# normalize the vector
	 	@vector = normalize( @vector );
	}

	return @vector;
}
# end sub strike_slip_vector
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# subroutine: dip_slip_vector INCOMPLETE!!!!
# 	my @dsVector = $elt->dip_slip_vector( $faultRef, $normalize );
#	my @dsVector = $elt->dip_slip_vector( $faultRef, 0 );
# takes a reference to the parent fault and a 1 if the vector 
# should be normalized or 0 if not and returns a 3 element array
# representing the u, v, w components of the dip slip vector
# of the element (vertices of the element must be defined and in the 
# fault being referenced)
sub dip_slip_vector {

	my ( $s, $f, $normalize ) = @_;

	#define an array to hold the vector
	my @vector;

	# find the strike slip vector
	my @v = $s->strike_slip_vector( $f, 0 );

	# calculate the vector components: 
	$vector[0] = $v[0] * $v[2]; # u
	$vector[1] = - $v[1] * $v[2]; # v 
	$vector[2] = $v[1] * $v[1] - $v[2] * $v[2]; # w


	# if required, normalize the vector
	if ( $normalize ) {
		
		# normalize the vector
	 	@vector = normalize( @vector );
	}

	return @vector;
}
# end sub dip_slip_vector
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# subroutine: net_slip_vector REALLY INCOMPLETE!!!
# 	my @netVector = $elt->net_slip_vector( $faultRef );
# takes a reference to the parent fault returns a 3 element array
# representing the u, v, w components of the net slip vector
# of the element (vertices of the element must be defined and in the 
# fault being referenced)
sub strike_slip_vector {

	my ( $s, $f, $normalize ) = @_;

	#define an array to hold the vector
	my @vector;

	# get the strike slip and dip slip vectors
	my @strike = $s->strike_slip_vector( $f, 1 );
	my @dip = $s->dip_slip_vector( $f, 1 );
	
	# calculate the vector components: u = 
	$vector[0] = 0; 

	$vector[1] = 0; 

	$vector[2] = 0;
	
	# if required, normalize the vector
	if ( $normalize ) {
		
		# normalize the vector
	 	@vector = normalize( @vector );
	}

	return @vector;
}
# end sub net_slip_vector
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# subroutine: normalize
# 	@vector = normalize( @vector );
# Return unit-length version of a vector (array)
#	CAN'T BE USED OUTSIDE THIS ELEMENT
sub normalize {               
        my ( @v ) = @_;

	# calculate the sum of squares for all three components
	# of the vector
        my $vLengthSquared = 0.0;
        for (my $i = 0; $i < @v; $i++) {
                $vLengthSquared += $v[$i] * $v[$i];
        }
	
	# normalize the vector
	for( my $i = 0; $i < @v; ++$i ){

		$v[$i] = $v[$i] / $vLengthSquared;
	}  
	
        return @v;
}
# end sub normalize 
#------------------------------------------------------------------------------
1;
