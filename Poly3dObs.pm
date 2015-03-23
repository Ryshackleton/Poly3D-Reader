# instantiable module for creating and manipulating observation
# points/lines/planes/grids in Poly3d 
# written by Ryan Shackleton, summer 2005
#
# 
# SUMMARY OF SUBROUTINES
# ===========================================================
# constructor: new
# 	my $newObs = new Poly3dObs( @parsedArray );
# where parsed array is an array of values from a 
# Poly3d INPUT file: we ALWAYS start with line definition from
# the input file such as:
# Obsplane 2 spepsed global global global -10.001 -15.001 0.0 9.009 14.009 0.0 5 5 1
# this line should be parsed to an array (for example: using readline_to_array
# 					in Poly3dReader.pm)
# detailed usage and creation:
# { open file, find the section with observation grids, find the first line: }
# 	my @parsedArray = readline_to_array( $filehandle );
#
# 	my $newObservationPoint = new Poly3dObs( @parsedArray );
# ------------------------------------------------------------



# ===========================================================
# GETTER METHODS
# ===========================================================
# these methods return data from within the poly3d object, so 
# to "get" any of the data input into the file, the variable name
# in the poly3d input file can be used (variable names with spaces
# are replaced by an _, so in Poly3d, "outp csys" becomes outp_csys
# in this script)
# 	my $newName = $obsPoint->name;
# 	my $newOutp = $obsLine1->outp;
# 	my $coordSys = $obsGrid1->outp_csys;
#
# other useful getter methods:
# subroutine: xyz_array
# 	my @xyzs = $obsPoint->xyz_array;
# returns a 3 element array indexed from 0 to 2 of the xyz
# coordinates of an observation point (if it's already defined
# by an adder method (see below) )
#
# after creation of a Poly3dObs object, empty variables for any type 
# of Poly3d observation output that exists are created: 
# eg: DISPLACEMENTS, STRAINS, PRINCIPAL STRAINS, etc.
# THESE OBJECT VARIABLES HAVE THE SAME NAMES AS THE POLY3D OUTPUT NAMES
# WITH THE FOLLOWING NOTABLE EXCEPTIONS: 
#  
# PRINCIPAL STRESSES:
# X1  X2  X3  N1    N2   N3   E1   N1   N2    N3   E2   N1   N2     N3   E3
# -------------------------------------------------------------------------
# 	       |     |    |        |     |     |         |    |      |   
# Poly3dObs: E1N1  E1N2 E1N3     E2N1  E2N2  E2N3     E3N1  E3N2  E3N3
#	      
# PRINCIPAL STRAINS:
# X1  X2  X3  N1   N2    N3 SIG1   N1   N2    N3 SIG2   N1   N2     N3   SIG3
# --------------------------------------------------------------------------
# 	       |     |    |         |    |     |         |    |      |   
# Poly3dObs:SIG1N1 SIG1N2 SIG1N3 SIG2N1 SIG2N2 SIG2N3 SIG3N1 SIG3N2  SIG3N3
#
# NOTE: you cannot assign anything using this reference style, so
# 	$obsPoint->name = "fred"; # WRONG!!!!
# will not compile at runtime.  To assign variables, see SETTER
# METHODS below.
# -----------------------------------------------------------



# ===========================================================
# SETTER METHODS
# change variables in an observation point/plane/grid
# ===========================================================
# subroutine: change_name
# changes the name of an obs point
# 	my $obs->change_name( $changeNameTo );
# -----------------------------------------------------------
# subroutine: change_dim
# changes the dimension of an output string 
# 	my $obs->change_dim( $changeDimTo );
# ----------------------------------------------------------
# subroutine: change_obs_xyz
# 	my @xyzArray = ( 2.3, 4.7, 5.5 );
# 	$obsObject->change_obs_xyz( @xyzArray );	
# takes an array of 3 x,y,z coordinates and
# replaces the X1, X2, and X3 element center coordinates
# with the values in the array
# ----------------------------------------------------------
# subroutine: change_variable
# 	$obsObject->change_variable( $variableName, $to );
# eg: $obsObject->change)_variable( "E11", 7.1797392 );
# 	modifies the value in E11 to be 7.1797392
# UNIVERSAL SETTER: BE CAREFUL WITH THIS METHOD!!!!!  
# Make sure you know what you're changing!!!
# changes any variable whose name you specify to a value given
# -----------------------------------------------------------




# ===========================================================
# "ADDER" METHODS
#  (SET MULTIPLE VARIABLES FROM POLY3D OUTPUT FILES)
# ===========================================================
# In general, the following methods add an array of values from a line
# parsed from their respective OBSERVATION sections of Poly3d OUTPUT files:
# they also return true for confirmation
# eg: add_displacements adds a parsed data line from DISPLACEMENTS output
# 	
# 	$obs->add_displacements( @p );
# 
# where @p is an array of numbers in the following order:
# X1  X2 X3  U1  U2  U3 
# (same order as the DISPLACEMENTS line in a poly3d output file)
# -----------------------------------------------------------
# subroutine: add_displacements
# 	$obs->add_displacements( @parsedArrayFromDISPLOUTPUT )
# 		|| die "Can't add displacements to obs point";
# 	(returns true if successful)
# -----------------------------------------------------------
# subroutine: add_principal_stresses
# 	$obs->add_principal_stresses( @parsed )
# 		 || die "error message";
# adds values from a PRINCIPAL STRESSES output in a 
# poly3d output file
# -----------------------------------------------------------
# subroutine: add_principal_strains
# 	$obs->add_principal_strains( @parsed )
# 		 || die "error message";
# adds values from a PRINCIPAL STRAINS output in a poly3d
# output file
# -----------------------------------------------------------
# subroutine: add_stress_tensor
# 	$obs->add_stress_tensor( @parsed )
# 		|| die "error message";
# adds values from a STRESSES output in a poly3d output file
# -----------------------------------------------------------
# subroutine: add_strain_tensor
# 	$obs->add_strain_tensor( @parsed )
# 		|| die "error message";
# adds values from a STRAINS output in a poly3d output file
# -----------------------------------------------------------



# ===========================================================
# TO STRING METHODS
# ===========================================================
# subroutine: inputLine_to_string
# 	my $string = $obs->inputLine_to_string;
# returns a space delimited string representing the input line
# parsed from the poly3d input file
# -----------------------------------------------------------
# subroutine: displacements_to_string
# 	my $string = $obs->displacements_to_string;
# returns a string representing the values in the displacements
# section of a poly3d output file
# -----------------------------------------------------------
# subroutine: principal_stresses_to_string
# 	my $string = $obs->principal_stresses_to_string;
# returns a string representing the values in the principal 
# stresses section of a poly3d output file
# -----------------------------------------------------------
# subroutine: principal_strains_to_string
# 	my $string = $obs->principal_strains_to_string;
# returns a string representing the values in the principal 
# strains section of a poly3d output file
# -----------------------------------------------------------
# subroutine: strain_tensor_to_string
# 	my $string = $obs->strain_tensor_to_string;
# returns a string representing the values in the strains
# section of a poly3d output file
# -----------------------------------------------------------
# subroutine: stress_tensor_to_string
# 	my $string = $obs->stress_tensor_to_string;
# returns a string representing the values in the stresses
# section of a poly3d output file
# -----------------------------------------------------------

# package declaration
package Poly3dObs;

use strict;

# Notes on creation and usage:
# -------------------------------------------------------------------------
# To create a Poly3dObs Object, we ALWAYS start with line definition from
# the input file such as:
# Obsplane 2 spepsed global global global -10.001 -15.001 0.0 9.009 14.009 0.0 5 5 1
# this line should be parsed to an array (for example: using readline_to_array
# 					in Poly3dReader.pm)
# eg usage and creation:
# { open file, find the section with observation grids, find the first line: }
# my @array = readline_to_array( $filehandle );
#
# my $newObservationPoint = new Poly3dObs( @array );
# now ALL VARIABLE NAMES IN THIS OBJECT ARE THE SAME AS IN THE POLY3D INPUT
# FILE WITH THE FOLLOWING EXCEPTIONS:
# "endpt csys"=endpt_csys, "obspt csys"=obspt_csys, "outp csys"=outp_csys

# notice that we have also created empty variables for any type 
# of Poly3d observation output that exists: 
# eg: DISPLACEMENTS, STRAINS, PRINCIPAL STRAINS, etc.
# THESE OBJECT VARIABLES HAVE THE SAME NAMES AS THE POLY3D OUTPUT NAMES
# WITH THE FOLLOWING EXCEPTIONS:
# 
# PRINCIPAL STRESSES:
# X1  X2  X3  N1    N2   N3   E1   N1   N2    N3   E2   N1   N2     N3   E3
# -------------------------------------------------------------------------
# 	       |     |    |        |     |     |         |    |      |   
# Poly3dObs: E1N1  E1N2 E1N3     E2N1  E2N2  E2N3     E3N1  E3N2  E3N3
#	      
# PRINCIPAL STRAINS:
# X1  X2  X3  N1   N2    N3 SIG1   N1   N2    N3 SIG2   N1   N2     N3   SIG3
# ---------------------------------------------------------------------------
# 	       |     |    |         |    |     |         |    |      |   
# Poly3dObs:SIG1N1 SIG1N2 SIG1N3 SIG2N1 SIG2N2 SIG2N3 SIG3N1 SIG3N2  SIG3N3
#
# to change, get, add, or otherwise manipulate the variables in this object
# see the comments for each subroutine below:
# values from the outputfile are later added using the ADDER methods below
sub new {
	
	# class type (Element in this case) is automatically assigned to the
	# first element in the array
	my ($class) = $_[0];

	# @_ array is the input, which will consist of an array of strings and
	# numbers in the following order:
	# 
	# 
	# ( recall that $_[0] was the object type (Element) above )
	my $self = {
		
		# from input files
		name => $_[1],
		dim => $_[2],
		outp => $_[3],
		endpt_csys => $_[4],
		obspt_csys => $_[5],
		outp_csys => $_[6],
		x1beg => $_[7],
		x2beg => $_[8],
		x3beg => $_[9],
		x1end => $_[10],
		x2end => $_[11],
		x3end => $_[12],
		nx1 => $_[13],
		nx2 => $_[14],
		nx3 => $_[15], 
		
		# from DISPLACEMENTS output
		X1 => undef,
		X2 => undef,
		X3 => undef,
		U1 => undef,
		U2 => undef,
		U3 => undef,
		
		#from PRINCIPAL STRESSES
		SIG1N1 => undef,
		SIG1N2 => undef,
		SIG1N3 => undef,
		SIG1 => undef,

		SIG2N1 => undef,
		SIG2N2 => undef,
		SIG2N3 => undef,
		SIG2 => undef,
		
		SIG3N1 => undef,
		SIG3N2 => undef,
		SIG3N3 => undef,
		SIG3 => undef,

		#from PRINCIPAL STRAINS
		E1N1 => undef,
		E1N2 => undef,
		E1N3 => undef,
		E1 => undef,

		E2N1 => undef,
		E2N2 => undef,
		E2N3 => undef,
		E2 => undef,
		
		E3N1 => undef,
		E3N2 => undef,
		E3N3 => undef,
		E3 => undef,		

		#from STRESSES (tensor)
		SIG11 => undef,
		SIG22 => undef,
		SIG33 => undef,
		SIG12 => undef,
		SIG23 => undef,
		SIG13 => undef,

		#from STRAINS (tensor)
		E11 => undef,
		E22 => undef,
		E33 => undef,
		E12 => undef,
		E23 => undef,
		E13 => undef

	};
		
	# create the new object by blessing the reference to $self
	bless  ( $self, $class );

	# return the reference to self
	return $self;

}

# GETTER METHODS
# generally have the form: ATTRIBUTENAME(), so to call:
# $objReferenceName->name();
# or even easier:
# $objReferenceName->name;
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
sub dim {  return $_[0]->{ dim };     }
sub outp { return $_[0]->{ outp };  }
sub endpt_csys { return $_[0]->{ endpt_csys };      }
sub obspt_csys {   return $_[0]->{ obspt_csys };          }
sub outp_csys {    return $_[0]->{ outp_csys };         }
sub x1beg { return $_[0]->{ x1beg };              }
sub x2beg { return $_[0]->{ x2beg };              }
sub x3beg { return $_[0]->{ x3beg };              }
sub x1end { return $_[0]->{ x1end };              }
sub x2end { return $_[0]->{ x2end };              }
sub x3end { return $_[0]->{ x3end };              }
sub nx1 { return $_[0]->{ nx1 };              }
sub nx2 { return $_[0]->{ nx2 };              }
sub nx3 { return $_[0]->{ nx3 };              }

# from output files
sub X1 {  return $_[0]->{ X1 };       }
sub X2 {  return $_[0]->{ X2 };     }
sub X3 { return $_[0]->{ X3 };  }

sub xyz_array { return ( $_[0]->X1, $_[0]->X2, $_[0]->X3 ); }

# from DISPLACEMENTS
sub U1 { return $_[0]->{ U1 };      }
sub U2 {   return $_[0]->{ U2};          }
sub U3 {    return $_[0]->{ U3 };         }

# from PRINCIPAL STRESSES
sub SIG1N1 {     return $_[0]->{ SIG1N1 };        }
sub SIG1N2 {   return $_[0]->{ SIG1N2 };          }
sub SIG1N3 {    return $_[0]->{ SIG1N3 };         }
sub SIG1 {     return $_[0]->{ SIG1 };        }
sub SIG2N1 {     return $_[0]->{ SIG2N1 };        }
sub SIG2N2 {   return $_[0]->{ SIG2N2 };          }
sub SIG2N3 {    return $_[0]->{ SIG2N3 };         }
sub SIG2 {     return $_[0]->{ SIG2 };        }
sub SIG3N1 {     return $_[0]->{ SIG3N1 };        }
sub SIG3N2 {   return $_[0]->{ SIG3N2 };          }
sub SIG3N3 {    return $_[0]->{ SIG3N3 };         }
sub SIG3 {     return $_[0]->{ SIG3 };        }

# from PRINCIPAL STRAINS
sub E1N1 {     return $_[0]->{ E1N1 };        }
sub E1N2 {   return $_[0]->{ E1N2 };          }
sub E1N3 {    return $_[0]->{ E1N3 };         }
sub E1 {     return $_[0]->{ E1 };        }
sub E2N1 {     return $_[0]->{ E2N1 };        }
sub E2N2 {   return $_[0]->{ E2N2 };          }
sub E2N3 {    return $_[0]->{ E2N3 };         }
sub E2 {     return $_[0]->{ E2 };        }
sub E3N1 {     return $_[0]->{ E3N1 };        }
sub E3N2 {   return $_[0]->{ E3N2 };          }
sub E3N3 {    return $_[0]->{ E3N3 };         }
sub E3 {     return $_[0]->{ E3 };        }

#from STRESSES (tensor)
sub SIG11 {   return $_[0]->{ SIG11 };          }
sub SIG22 {   return $_[0]->{ SIG22 };          }
sub SIG33 {   return $_[0]->{ SIG33 };          }
sub SIG12 {   return $_[0]->{ SIG12 };          }
sub SIG23 {   return $_[0]->{ SIG23 };          }
sub SIG13 {   return $_[0]->{ SIG13 };          }

#from STRAINS (tensor)
sub E11 {   return $_[0]->{ E11 };          }
sub E22 {   return $_[0]->{ E22 };          }
sub E33 {   return $_[0]->{ E33 };          }
sub E12 {   return $_[0]->{ E12 };          }
sub E23 {   return $_[0]->{ E23 };          }
sub E13 {   return $_[0]->{ E13 };          }

# SETTER METHODS
# general format is change_ATTRIBUTE( $newAttributeValue );
# to call: $newIndex = $vertex->change_name( $newAttributeValue );
# except for change_variable (see documentation below)
sub change_name {
	my ($self, $newIndex) = @_;
	
	$self->{name} = $newIndex;
}

sub change_dim {
	my ($self, $newDim ) = @_;

	$self->{dim} = $newDim;

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

# change_obs_xyz
# takes an array of 3 x,y,z coordinates and
# replaces the X1, X2, and X3 element center coordinates
# with the values in the array
# usage example:
# my @xyzArray = ( 2.3, 4.7, 5.5 );
# $obsObject->change_obs_xyz( @xyzArray ); 
sub change_obs_xyz {

	my ( $self, @xyz ) = @_;

	$self->{ X1 } = $xyz[0];
	$self->{ X2 } = $xyz[1];
	$self->{ X3 } = $xyz[2];

}

# "ADDER" METHODS (SET MULTIPLE VARIABLES FROM POLY3D OUTPUT FILES)
# in general, the following methods add an array of values from a line
# parsed from their respective OBSERVATION sections:
# they also return true for confirmation
# eg: add_displacements adds a parsed data line from DISPLACEMENTS output
# usage $obs->add_displacements( @p );
# where @p is an array of numbers in the following order:
# X1  X2 X3  U1  U2  U3 
# (same order as the DISPLACMENTS line in a poly3d output file)
sub add_displacements {

	my ( $s, @p ) = @_;

	$s->{ X1 } = $p[0];
	$s->{ X2 } = $p[1];
	$s->{ X3 } = $p[2];
	$s->{ U1 } = $p[3];
	$s->{ U2 } = $p[4];
	$s->{ U3 } = $p[5];
	
	return 1;

}

sub add_principal_stresses {

	my ( $s, @p ) = @_;

	$s->{ X1 } = $p[0];
        $s->{ X2 } = $p[1];
        $s->{ X3 } = $p[2];
	$s->{ SIG1N1 } = $p[3];
	$s->{ SIG1N2 } = $p[4];
	$s->{ SIG1N3 } = $p[5];
	$s->{ SIG1 } = $p[6];
	$s->{ SIG2N1 } = $p[7];
	$s->{ SIG2N2} = $p[8];
	$s->{ SIG2N3 } = $p[9];
	$s->{ SIG2 } = $p[10];
	$s->{ SIG3N1 } = $p[11];
	$s->{ SIG3N2} = $p[12];
	$s->{ SIG3N3 } = $p[13];
	$s->{ SIG3 } = $p[14];

	return 1;
}

sub add_principal_strains {

	my ( $s, @p ) = @_;

	$s->{ X1 } = $p[0];
        $s->{ X2 } = $p[1];
        $s->{ X3 } = $p[2];
	$s->{ E1N1 } = $p[3];
	$s->{ E1N2 } = $p[4];
	$s->{ E1N3 } = $p[5];
	$s->{ E1 } = $p[6];
	$s->{ E2N1 } = $p[7];
	$s->{ E2N2} = $p[8];
	$s->{ E2N3 } = $p[9];
	$s->{ E2 } = $p[10];
	$s->{ E3N1 } = $p[11];
	$s->{ E3N2} = $p[12];
	$s->{ E3N3 } = $p[13];
	$s->{ E3 } = $p[14];

	return 1;
}

sub add_stress_tensor {

        my ( $s, @p ) = @_;

        $s->{ X1 } = $p[0];
        $s->{ X2 } = $p[1];
        $s->{ X3 } = $p[2];
	$s->{ SIG11 } = $p[3];
	$s->{ SIG22 } = $p[4];
	$s->{ SIG33 } = $p[5];
	$s->{ SIG12 } = $p[6];
	$s->{ SIG23 } = $p[7];
	$s->{ SIG13 } = $p[8];

        return 1;

}

sub add_strain_tensor {

        my ( $s, @p ) = @_;

        $s->{ X1 } = $p[0];
        $s->{ X2 } = $p[1];
        $s->{ X3 } = $p[2];
	$s->{ E11 } = $p[3];
	$s->{ E22 } = $p[4];
	$s->{ E33 } = $p[5];
	$s->{ E12 } = $p[6];
	$s->{ E23 } = $p[7];
	$s->{ E13 } = $p[8];

        return 1;

}

		
# TO STRING METHODS
# general format is ATTRIBUTE_to_string()
#to call: $string = xyz_to_string();
# or $string = inputLine_to_string; # no parentheses


sub inputLine_to_string {
	my ($s) = @_;

	my $a = "  ";
	
	return $s->name.$a.$s->dim.$a.$s->outp.
		$a.$s->endpt_csys.$a.$s->obspt_csys.$a.$s->outp_csys.$a.
		$s->x1beg.$a.$s->x2beg.$a.$s->x3beg.$a.
		$s->x1end.$a.$s->x2end.$a.$s->x3end.$a.
		$s->nx1.$a.$s->nx2.$a.$s->nx3;

}
sub displacements_to_string {
	my ($s) = @_;

	my $a = "  ";

	return  $s->name.$a.$s->X1.$a.$s->X2.$a.$s->X3.$a.
		$s->U1.$a.$s->U2.$a.$s->U3;
}
sub strain_tensor_to_string {
	my ($s) = @_;

	my $a = "  ";

	return  $s->name.$a.$s->X1.$a.$s->X2.$a.$s->X3.$a.
		$s->E11.$a.$s->E22.$a.$s->E33.$a.
		$s->E12.$a.$s->E23.$a.$s->E13;

}	
sub stress_tensor_to_string {
	my ($s) = @_;

	my $a = "  ";

	return  $s->name.$a.$s->X1.$a.$s->X2.$a.$s->X3.$a.
		$s->SIG11.$a.$s->SIG22.$a.$s->SIG33.$a.
		$s->SIG12.$a.$s->SIG23.$a.$s->SIG13;

}
sub principal_stresses_to_string {
	my ($s) = @_;

	my $a = "  ";

	return $s->name.$a.$s->X1.$a.$s->X2.$a.$s->X3.$a.
	$s->SIG1N1.$a.$s->SIG1N2.$a.$s->SIG1N3.$a.$s->SIG1.$a.
	$s->SIG2N1.$a.$s->SIG2N2.$a.$s->SIG2N3.$a.$s->SIG2.$a.
	$s->SIG3N1.$a.$s->SIG3N2.$a.$s->SIG3N3.$a.$s->SIG3;
	
}
sub principal_strains_to_string {
	my ($s) = @_;

	my $a = "  ";

	return $s->name.$a.$s->X1.$a.$s->X2.$a.$s->X3.$a.
	$s->E1N1.$a.$s->E1N2.$a.$s->E1N3.$a.$s->E1.$a.
	$s->E2N1.$a.$s->E2N2.$a.$s->E2N3.$a.$s->E2.$a.
	$s->E3N1.$a.$s->E3N2.$a.$s->E3N3.$a.$s->E3;

}

1;

