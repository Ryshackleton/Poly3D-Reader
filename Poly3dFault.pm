# instantiable module for creating and manipulating faults in Poly3d 
# written by Ryan Shackleton, summer 2005

# ===========================================================
# SUMMARY OF SUBROUTINES
# ===========================================================
# constructor: new
# used to create fault objects.  Vertices and elements are later
# added using "ADDER" subroutines below
# 	my $fault = new Poly3dFault( @parsedArray );
# where @parsedArray is an array consisting of the following entries
# from a poly3d INPUT file like this:
# *o   name outp  eltc csys
# o   fault  bt  global  <- pass this line in as an array
# 
# ***for more information on fault creation and 
# addition of output file data, see methods
# in Poly3dReader.pm such as: faults_from_poly3d_input,
# parse_fault_displacements, and parse_fault_stresses***
# -----------------------------------------------------------



# ===========================================================
# GETTER METHODS
# ===========================================================
# these methods return data from within the poly3d object, so 
# to "get" any of the data input into the file, the variable name
# in the poly3d input file can be used (variable names with spaces
# are replaced by an _, so in Poly3d, "eltc csys" becomes eltc_csys
# in this script)
# 	my $newName = $fault->name;
# 	my $newOutp = $fault->outp;
# 	my $coordSys = $fault->eltc_csys;
# NOTE: you cannot assign anything using this reference style, so
# 	$fault->name = "fred"; # WRONG!!!!
# will not compile at runtime.  To assign variables, see SETTER
# METHODS below.
# 
# SPECIAL GETTER METHODS FOR ELEMENTS AND VERTICES
# -----------------------------------------------------------
# Poly3dFaults contain arrays of Poly3dVertex and Poly3dElement objects
# these arrays are indexed from 1 to variables in the Poly3dFault called
# numVerts and numElts.  So to get the number of vertices or elements,
# 	my $n = $fault->numVerts;
# 	my $p = $fault->numElts;
#
# To access an individual vertex or element in the array, use the following
# getter methods (subroutines):
#	my $newVertexReference = $fault->vert( $vertexIndex );
#	my $newElementReference = $fault->elt( $elementIndex );
# where $vertexIndex or $elementIndex are between 1 and numVerts or numElts
#
# here's a useful example of how to loop through all the vertices in a fault
#  ***notice that $i starts at 1 and goes until $i is less than OR EQUAL TO
#  							$fault->numVerts***
# for( my $i = 1; $i <= $fault->numVerts; ++$i ) {
#
# 	# do some stuff, like print the name of a vertex
# 	# (notice that we refer to "name" in the vertex by
# 	#    using another -> and "name", which is a subroutine
# 	#	the Poly3dVertex object)
# 	print $fault->vert( $i )->name;
#
#	# print an endline character
# 	print "\n";
# } # end for
# -----------------------------------------------------------


# ===========================================================
# SETTER METHODS
# change variables in a fault
# ===========================================================
# subroutine: change_name
# changes the name of a fault
# 	my $fault->change_name( $changeNameTo );
# -----------------------------------------------------------
# subroutine: change_outp
# changes the outp string of a fault
# 	my $fault->change_outp( $changeOutpTo );
# -----------------------------------------------------------
# subroutine: change_eltc_csys
# 	my $fault->change_eltc_csys( $changeEltCsysTo );
# -----------------------------------------------------------



# ===========================================================
# "ADDER" METHODS
# used to add and create vertices and elements in the fault
# ***there methods are used by Poly3dReader in;
# parse_fault_displacements, and parse_fault_stresses
# which has good examples of usage***
# ===========================================================
# VERTICES:
# -----------------------------------------------------------
# subroutine: add_vertices
# adds an array of vertices to the fault:
# 	$faultReference->add_vertices( @newArrayOfVertices );
# where @newArrayOfVertices is an array of Poly3dVertex objects
# (pass in vertices indexed from 0..n-1)
# ***THE { vert } ARRAY IS INDEXED FROM 1 TO numVerts*****
# -----------------------------------------------------------
# subroutine: add_vertex
# adds a single vertex to the fault
# 	$faultReference->add_vertex( $newVertexToAdd );
# -----------------------------------------------------------
# subroutine: create_vertex
# creates a new vertex in the fault using an array parsed
# from an input line 
# 	$faultReference->create_vertex( @parsedVertexArray );
# where @parsedElementArray is an array representing a Vertex
# input line in a poly3d input file
# --------------------------------------------------------------------
# subroutine: vertex_names 
# 	my @indices = $fault->vertex_names; 

# returns an array with the names of the vertices contained in the fault
# sorted in ascending order
# ****USEFUL SUBROUTINE IF clean_up_vertices OR
#    renumber_and_remove_unused_vertices IS NOT CALLED AND ALL OF THE 
#    VERTICES IN THE MODEL ARE LISTED WITH EACH FAULT******	
#   e.g. to loop through vertices:
# 	my @indices = $fault->vertex_names; 
#
#	# loop through vertices
#	for( my $i = 1; $i < @indices; ++$i ) {
#		
#		# reference to current vertex
#		my $v = $fault->vert( $indices[$i] );
#
#		print $v->name;
#
#	}
# -----------------------------------------------------------
# subroutine: min_vertex_name 
# 	$fault->min_vertex_name; 
#
# returns the lowest name (index # in the Poly3d file) of the fault 
# -----------------------------------------------------------
# subroutine: max_vertex_name 
# 	$fault->max_vertex_name; 
#
# returns the largest name (index # in the Poly3d file) of the fault 
#
# -----------------------------------------------------------
# ELEMENTS:
# -----------------------------------------------------------
# subroutine: add_elements
# adds an array of elements to the fault:
# 	$faultReference->add_elements( @newArrayOfElements );
# where @newArrayOfElements is an array of Element objects
# (pass in elements indexed from 0..n-1)
# ***THE { vert } ARRAY IS INDEXED FROM 1 TO numVerts*****
# -----------------------------------------------------------
# subroutine: add_element
# adds a single element to the fault
# $faultReference->add_element( $newElementToAdd );
# -----------------------------------------------------------
# subroutine: create_element
# creates a new element in the fault using referenced inputs
# 	$faultReference->create_element( $newElementIndex,
# 					 @parsedElementArray );
# where @parsedElementArray is an array representing a Element
# input line in a poly3d input file
# -----------------------------------------------------------



# ===========================================================
# TO STRING METHODS
# ===========================================================
# subroutine: inputLine_to_string
# 	my $string = $fault->inputLine_to_string;
# returns a space delimited string representing the input line
# parsed from the poly3d input file
# -----------------------------------------------------------
# subroutine: to_gocad_string
# 	my $string = $fault->to_gocad_string;
# returns a string representing a gocad TSurf object
# ***works only for faults with triangular elements***
# -----------------------------------------------------------
# subroutine: to_pyramid_string
# 	my $string = $fault->to_pyramid_string;
# returns a string representing an Explorer Pyramid
# ***only works for faults with triangular elements***
# -----------------------------------------------------------
# subroutine: to_base_string
# 	my $string = $fault->to_base_string;
# returns a string representing an Explorer Base file
# ***only works for faults with triangular elements***
# -----------------------------------------------------------
# subroutine: to_lattice_string
# 	my $string = $fault->to_lattice_string( $slipInterval );
# takes a slip interval in years, calculates the slip rate
# for that interval, and returns a string representing an 
# Explorer Lattice file
# ***only works for faults with triangular elements****
# ***fault DISPLACEMENTS must have already been defined****
# ***data should be in meters? or km? ask Michele***
# -----------------------------------------------------------


# ===========================================================
# VERTEX/ELEMENT MANIPULATION SUBROUTINES
# used to parse, remove and re-number vertices in the Poly3dFault
# ===========================================================
# subroutine: clean_up_vertices
# 	$fault->clean_up_vertices;
# designed to remove the extra vertices that are encountered when a
# poly3d input file has all the vertices listed at the beginning of the
# file (all the vertices are added to the fault in Poly3dReader)
# this subroutine does the following:
# 1) checks to make sure the vertices are numbered consecutively
# 2) finds the minimum and maximum vertex index used in the fault
#    from the connectivities between vertices (in each element)
# 3) if the min and max are 1 and numVerts respectively, we'll assume
#    that there are no unused vertices, so the subroutine will exit
# 4) if the min and max are NOT 1 and numVerts, AND there are no unused
#    vertices, this subroutine will renumber the vertices to start at 1
# 5) if there are unused vertices, this subroutine removes all vertices 
#    smaller than min and greater than max, and renumbers them from 1..n
# 6) changes the connectivity arrays to match the new vertex indices
# 7) returns true if the removal was successful, or false if no
# package declaration
# --------------------------------------------------------------------
# subroutine: remove_vertex ********UNTESTED******* 
# 	$fault->remove_vertex( $vertexIndex );
# ****assumes vertices are numbered sequentially*****
# 1) removes a vertex and moves all of the other vertices up in the array
# 2) changes the name of remaining vertices so the remaining vertices will 
#    be sequentially numbered
# 3) renumbers the element connectivity array to reflect the change
# 	in the vertex name
# --------------------------------------------------------------------
# subroutine: remove_element ********UNTESTED*******
# 	$fault->remove_element( $elementIndex ); 
# ****assumes elements are numbered sequentially*****
# 1) removes an element and moves all of the other elements up in the array
# 2) changes the name of each element so that the elements will be sequential
# -----------------------------------------------------------
# subroutine: change_element_connectivity
# 	 $faultRef->change_element_connectivity( 
# 	 			$findVertexName, $changeToName );
# searches the connectivity array in each element for a given
# vertex name (index) and replaces it with the given value
# (used by clean_up_vertices and remove_vertex)
# -----------------------------------------------------------

package Poly3dFault;
use strict;

# finds and "loads" the appropriate Poly3dVertex and Poly3dElement
# objects
use FindBin;
use lib $FindBin::Bin;
use Poly3dVertex;
use Poly3dElement;

# constructor
# to construct: my $fault = new Poly3dFault( @parsedArray );
# where @parsedArray is an array consisting of the following entries
# from a poly3d INPUT file like this:
# o   faultName outputType eltc_csystem
# o   fault  bt  global
#
# Fault objects are made to hold and reference Vertex and Element
# objects which can be added to the fault as follows:
# eg:
# $fault = new Poly3dFault( @parsedFaultLine );
# 
# $vertex = new Poly3dVertex( @parsedVertexLine );
# $element = new Poly3dElement( $indexNumber, @parsedElementLine );
#
# $fault->add_vertex( $vertex );
# $fault->add_element( $element );
sub new {

	my ( $class ) = $_[0];

	# create arrays for vertices (XYZ's)
	# and vertex numbers
	my $self = {

		name => $_[2],
		outp => $_[3],
		eltc_csys => $_[4],
		numVerts => 0,
		numElts => 0
				
	};

	bless ( $self, $class );

	return $self;

}

# GETTER METHODS
sub name {  return $_[0]->{ name };       }
sub outp {  return $_[0]->{ outp };     }
sub eltc_csys { return $_[0]->{ eltc_csys };  }

# the next two methods return a specified vertex or element
# in the array eg: my $vertex = $vertRef->vert( 5 );
sub vert {  return $_[0]->{ vert }->[$_[1] ];        }
sub elt {  return $_[0]->{ elt }->[$_[1] ];        }
sub numVerts { return $_[0]->{numVerts};        }
sub numElts {  return $_[0]->{numElts};         }

# SETTER METHODS
#
# subroutine: change_name
# changes the name of a fault
# 	my $fault->change_name( $changeNameTo );
sub change_name {

	my ( $s, $newName ) = @_;

	$s->{ name } = $newName; 

}
# subroutine: change_outp
# changes the outp string of a fault
# 	my $fault->change_outp( $changeOutpTo );
sub change_outp {

	my ( $s, $newOutp ) = @_;

	$s->{ outp } = $newOutp; 

}
# subroutine: change_eltc_csys
# 	my $fault->change_eltc_csys( $changeEltCsysTo );
sub change_eltc_csys {

	my ( $s, $new ) = @_;

	$s->{ eltc_csys } = $new; 

}

# adds an array of vertices to the fault:
# $faultReference->add_vertices( @newArrayOfVertices );
# where @newArrayOfVertices is an array of Vertex objects
# (pass in vertices indexed from 0..n-1)
# ***THE { vert } ARRAY IS INDEXED FROM 1 TO numVerts*****
sub add_vertices {

	my ( $self, @vertices ) = @_;
	
	# loop through the array passed in
	# FROM 0 TO n-1
	for( my $i = 0; $i < @vertices; ++$i ) {

		# increment numVerts	
		$self->{numVerts}++;

		# get the input line from the old vertex
		# and parse it to a new array
		my $line = $vertices[$i]->inputLine_to_string;
		my @p = split( " ", $line );
		
		# add each vertex at the end of the vertex array
		$self->{vert}->[ $self->numVerts ] = new Poly3dVertex( @p );
		
	}
}

# adds a single vertex to the fault
# $faultReference->add_vertex( $newVertexToAdd );
sub add_vertex {

	my ( $self, $vertex ) = @_;

	# increment numVerts
	$self->{numVerts}++;

	# get the input line from the old vertex
	# and parse it to a new array
	my $line = $vertex->inputLine_to_string;
	my @p = split( " ", $line );

	#add the new vertex in the new space
	$self->{ vert }->[ $self->numVerts ] = new Poly3dVertex( @p );

}

# creates a new vertex in the fault using referenced inputs
# $faultReference->create_vertex( @parsedElementArray );
sub create_vertex {

	my ($self, @parsedArray ) = @_; 
	
	$self->{ numVerts }++;
	$self->{ vert }->[ $self->numVerts ] = new Poly3dVertex( @parsedArray );
			                 
}

# # adds an array of elements to the fault:
# # $faultReference->add_elements( @newArrayOfElements );
# # where @newArrayOfElements is an array of Element objects
# # ***THE { elt } ARRAY IS INDEXED FROM 0 TO numElts-1*****
sub add_elements {

	my( $self, @elements ) = @_;

	# loop through the element array from 0 to n-1
	for( my $i = 0; $i < @elements; ++$i ) {
		
		# increment numElts
		$self->{ numElts }++;

		# get the input line from the old element
		# and parse it to a new array
		my $line = $elements[$i]->inputLine_to_string;
		my @p = split( " ", $line );
		
		# add each element to the end of the array
		$self->{ elt }->[ $self->numElts ] = new Poly3dElement(
		       			$self->numElts,	@p );

	}
}

# adds a single element to the fault
# $faultReference->add_element( $newElementToAdd );
sub add_element {

	my( $self, $element ) = @_;

	#increment numElts
	$self->{ numElts }++;

	# get the input line from the old element
	# and parse it to a new array
	my $line = $element->inputLine_to_string;
	my @p = split( " ", $line );
	
	# add the new element to the array
	$self->{ elt }->[ $self->numElts ] = new Poly3dElement(
				$self->numElts, @p );

}

# creates a new element in the fault using referenced inputs
# $faultReference->create_element( $elementIndex, @parsedElementArray );
sub create_element {

	my ($self, $elementIndex, @parsedArray ) = @_;

	# increment numElts
	$self->{numElts}++;
	# create a new element at the end of the element array
	$self->{ elt }->[ $self->numElts ] = 
		new Poly3dElement( $elementIndex, @parsedArray );

	
}

# TO STRING METHODS
# general format is ATTRIBUTE_to_string()
# #to call: $string = xyz_to_string();
sub inputLine_to_string {
	my ($s) = @_;

	return "o  ".$s->{ name }."  ".$s->{ outp }."  ".$s->{ eltc_csys };

}

# subroutine: to_gocad_string
# returns a string representing a gocad TSurf object
sub to_gocad_string {
	
	my ( $s ) = @_;
	
	# string to hold the output
	my $gocad;

	# make faults different colors
	my @colorlines = ( "*solid*color:1.000000 0.000000 0.000000 1",
		"*solid*color:0.000000 0.000000 1.000000 1",
		"*solid*color:1.000000 1.000000 0.007843 1",
		"*solid*color:0.000000 1.000000 0.000000 1"  );
		
	# add header information for each fault in the gocad string
	$gocad .=  "GOCAD TSurf 1\n";
	$gocad .=  "HEADER {\n";
	$gocad .=  "name:".$s->name."\n";
	$gocad .=  "mesh:false\n";
	$gocad .=  "ivolmap:false\n";
	$gocad .=  "imap:false\n";
	$gocad .=  "*solid*color:1.000000 1.000000 1.000000 1\n";
	$gocad .=  "}\n";
	$gocad .=  "GEOLOGICAL_TYPE top\n";
	$gocad .=  "TFACE \n";

	# add the vertices
	for( my $j = 1; $j <= $s->numVerts; ++$j ){
		
		$gocad .=  "VRTX  ".$s->vert( $j )->name.
			"  ".$s->vert( $j )->xyz_to_string."\n";
	}

	# add the elements
	for( my $j = 1; $j <= $s->numElts; ++$j ) {

		$gocad .=  "TRGL  ".$s->elt( $j )->
				connectivity_to_string."\n";

	}
	
	# add end to end the current fault in the gocad file
	$gocad .= "END\n\n";	

	return $gocad;

} # end sub to_gocad_string
# --------------------------------------------------------------------



# --------------------------------------------------------------------
# subroutine: to_pyramid_string
# 	my $string = $fault->to_pyramid_string;
# returns a string representing an Explorer Pyramid file
sub to_pyramid_string {

	my  ( $s ) = @_;

	# define a string to hold the file info
	my $str;

	# define the name of the fault
	my $name = $s->name;

	# write the header info
	$str .= "\n#!/usr/explorer/bin/explorer cxPyramid plain 1.0";
	$str .= "\n\n# base lattice in plain ascii format ";
	$str .= "\ninclude $name.base.lat";
	$str .= "\n2     # count";
	$str .= "\n1     # compression type (cx_compress_unique)";
	$str .= "\n2       # compression dict (cx_pyramid_dict_triangle)";
	$str .= "\n# layer 1";
	$str .= "\n0 0 # compressed";
	$str .= "\n# layer 2 -- this is the compression layer";

	# define the number of connections
	my $numConnections = ( $s->numElts ) * 3;

	# add it to the string
	$str .= "\n".$s->numElts." $numConnections".
		 " #numElements, numConnections";
	
	# write the element numbers to the file???
	# ????why start at 0 when Gocad files always
	# start at 1????
	$str .= "\n# elements:\n";
	my $i = 0;
	while( $i < $numConnections  + 1 ) {
		
		# add the number to the string		
		$str .= "$i ";

		# increment i by 3
		$i=$i+3;
	}

	# add the connections (connectivities) to the file
	$str .= "\n# connections\n";
	
	for( my $i = 1; $i <= $s->numElts; ++$i ) {

		# get connectivity array
		my @con = $s->elt($i)->connectivity_array;

		# loop through the connectivities
		for( my $j = 0; $j < @con; ++$j ){
			
			# decrement the connn array
			# (because the vertices need to
			# start at 0?)
			$con[$j]--;

			# add the connectivity to the
			# output string
			$str .= "$con[$j] ";
		}
	}

	# write the ending info to the file
	$str .= "\n# there is a lattice at this layer so include it here";
	$str .= "\ninclude $name.layer.lat";
	$str .= "\n# end of pyramid definition\n";

	return $str;
	
}
# end sub to_pyramid_string
# --------------------------------------------------------------------


# --------------------------------------------------------------------
# subroutine: to_base_string
# 	my $string = $fault->to_base_string;
# returns a string representing an Explorer Base file
sub to_base_string {

	my ( $s ) = @_;

	my $str;

	# write header info
	$str .= "\n#!/usr/explorer/bin/explorer cxLattice plain 1.0";
	$str .= "\n# this file contains the base lattice (vertices) definition for PV.pyr";
	$str .= "\n1    #nDim";
	$str .= "\n".$s->numVerts." #dims";
	$str .= "\n1       # nDataVar";
	$str .= "\n3       # cxPrimType (cx_prim_float)";
	$str .= "\n2       # cxCoordType (cx_coord_curvilinear)";
	$str .= "\n1       # nSteps";
	$str .= "\n3       # nCoordVar";

	# write the xyz coordinates
	# while creating an empty data string
	my $zeros;
	$str .= "\n# coord values\n";
	for( my $i = 1; $i <= $s->numVerts; ++$i ) {
		
		# write the xyz data for each element	
		$str .= $s->vert($i)->xyz_to_string." ";

		# add a zero (to be added as empty
		# data values later)
		$zeros .= "0 ";
		
	}

	# I don't know why, but we're short 1 zero, so add one more(?)
	$zeros .= "0 ";

	# write some empty data values
	$str .= "\n# data values (empty)\n";
	$str .= $zeros;
	
	# write end of file
	$str .= "\n# end of lattice definition\n";

	return $str;
}
# end sub to_base_string
# --------------------------------------------------------------------


# --------------------------------------------------------------------
# subroutine: to_lattice_string
# 	my $string = $fault->to_lattice_string( $slipInterval );
# Made to be used with to_base_string and to_pyramid_string
# to create flies readable by Explorer.
# Takes a slip interval in years, calculates the slip rate
# for that interval, from the fault DISPLACEMENTS section
#  and returns a string representing an Explorer Lattice file
sub to_lattice_string {

	my ( $s, $slipInterval ) = @_;
	
	# string to return
	my $str;

	# define the fault name
	my $name = $s->name;

	# write the header info
	$str .= "\n#!/usr/explorer/bin/explorer cxLattice plain 2.0";
	$str .= "\n# this file contains the lattice data (elements) at level";
	$str .= "\n# 2 of the pyramid deinfed in $name.pyr";
	$str .= "\n1   #nDim";
	my $num = $s->numElts;
	$str .= "\n$num        #dims";
	$str .= "\n3       # nDataVar";
	$str .= "\n3       # PrimType (cx_prim_float)";
	$str .= "\n2       # CoordType (cx_coord_curvilinear)";
	$str .= "\n1       # nSteps";
	$str .= "\n3       # nCoordVar";

	# write the coordinate values X1C, X2C, X3C
	# ...meanwhile, calculate some slip info and
	# add it to a string to be added later
	my $data;
	$str .= "\n# coord values\n";
	for( my $i = 1; $i <= $s->numElts; ++$i ) {

		# define the current element
		my $e = $s->elt( $i );
		
		# write the xyz center info
		$str .= $e->X1C."  ".$e->X2C."  ".
			$e->X3C."\n";

		# calculate the dip slip, strike slip,
		# and net slip for the current element
		my $dip = $e->B1 * 1000 / $slipInterval;
		my $strike = $e->B2 * 1000 / $slipInterval;
		my $net = sqrt( $dip**2 + $strike**2 );

		# write the slip to the temp data string
		$data .= "$dip  $strike  $net\n";
		
	}
	
	# write the data values
	$str .= "\n# data values \n";
	$str .= $data;

	# end file
	$str .= "\n# end of pyramid definition\n";
	
	return $str;

}
# end sub to_lattice_string
# --------------------------------------------------------------------



# VERTEX/ELEMENT MANIPULATION SUBROUTINES
# used to parse, remove and re-number vertices in the Poly3dFault
#
# --------------------------------------------------------------------
# subroutine: clean_up_vertices
# designed to remove the extra vertices that are encountered when a
# poly3d input file has all the vertices listed at the beginning of the
# file (all the vertices are added to the fault in Poly3dReader)
# this subroutine does the following:
# 1) checks to make sure the vertices are numbered consecutively
# 2) finds the minimum and maximum vertex index used in the fault
#    from the connectivities between vertices (in each element)
# 3) if the min and max are 1 and numVerts respectively, we'll assume
#    that there are no unused vertices, so the subroutine will exit
# 4) if the min and max are NOT 1 and numVerts, AND there are no unused
#    vertices, this subroutine will renumber the vertices to start at 1
# 5) if there are unused vertices, this subroutine removes all vertices 
#    smaller than min and greater than max, and renumbers them from 1..n
# 6) changes the connectivity arrays to match the new vertex indices
# 7) returns true if the removal was successful, or false if not
sub clean_up_vertices {
	
	my ( $s ) = @_;

	# CHECK TO MAKE SURE THE VERTICES ARE NAMED CONSECUTIVELY
	# loop through the vertices
	for( my $i = 1; $i < $s->numVerts; ++$i ) {

		# the next vertex should be the name + 1
		my $next = $s->vert($i)->name + 1; 

		# if the next vertex name isn't equal to $next
		if( $next != $s->vert($i + 1)->name ) {

			print "Vertices: ";
			print $s->vert( $i )->name;
			print " and ".$s->vert( $i+1 )->name;
			print " are not consecutive in fault:";
			print $s->name."\n";

			# return false
			return 0;
		}
	}

	# FIND THE MIN AND MAX VERTEX INDICES IN THE FAULT CONNECTIVITY ARRAYS
	# start by defining a min and max
	my $min = 99999999999;
	my $max = -1;
	
	# loop through the elements
	for( my $i = 1; $i <= $s->numElts; ++$i ) {

		# get the connectivity array for the current element
		my @c = $s->elt($i)->connectivity_array;
	
		# loop through the connectivity array
		for( my $j = 0; $j < @c; ++$j ){

			# if the vertex name is less than min
			if( $c[$j] < $min ){
				
				# min gets the new low
				$min = $c[$j];
			} # end if

			#if the vertex name is bigger than the max
			if( $c[$j] > $max ) {

				# max gets the new high
				$max = $c[$j];
			} # end if
		} # end inner for
	} #end outer (all element looping) for

	# CHECK TO MAKE SURE WE REALLY NEED TO DO ANY WORK
	# (ie, if there are no unused vertices)	
	# if min = 1 and max = numVerts, then there are no unused vertices,
	# and we don't need to do anything else, so exit
	if( ( $min == 1 ) && ( $max == $s->numVerts ) ) {
		
		# return true
		return 1;

	# OTHERWISE, if there are no unused vertices, BUT the vertices are 
	# just numbered from min to max and don't happen to start at 1, 
	# we'll renumber the vertices, correct the connectivities, and exit
	} elsif ( $max - $min + 1 == $s->numVerts ) {

		# loop through the vertices
		for( my $i = 1; $i <= $s->numVerts; ++$i ) {

			# change the element connectivities
			$s->change_element_connectivity(
				$s->vert($i)->name, $i );

			# change the name of the vertex
			$s->vert($i)->change_name( $i );

		}

		return 1;

	}

	# if we've gotten here, then we need to do some work:
	#	
	# REMOVE ALL THE VERTICES THAT ARE GREATER THAN MAX AND LESS THAN MIN
	# count the number removed
	my $nRemoved = 0;
	
	# loop from 1 to $min - 1 vertex number
	for( my $i = 1; $i < $min; ++$i ) {

		# undefine the vertex
		$s->{vert}->[$i] = undef;
		
		$nRemoved++;
	}

	# loop from $max + 1 to $numVerts
	for( my $i = $max + 1; $i <= $s->numVerts; ++$i ) {

		# undefine the vertex
		$s->{vert}->[$i] = undef;

		$nRemoved++;
	}
	
	# ERROR CHECKING: find the number of vertices there SHOULD BE
	# in the fault by subtracting the number removed from
	# the total numVerts
	my $shouldBeNumVerts = $s->numVerts - $nRemoved;
	
	# if the min is 1 and the max is the right number of
	# vertices, we don't need to do any more renumbering, so
	# go ahead and reassign $fault->numVerts and exit
	if( ( $min == 1 ) && ( $max == $shouldBeNumVerts ) ) {

		# change the number of vertices in the fault
		$s->{numVerts} = $shouldBeNumVerts;

		return 1;
	}	

	# RENUMBER THE VERTICES THAT ARE STILL PRESENT AND 
	#  FIX THE ELEMENT CONNECTIVITY ARRAY
	my $newIndex = 0;
	
	# loop through the remaining vertices from $min to $max
	for( my $i = $min; $i <= $max; ++$i ) {

		# increment the new index counter
		$newIndex++;

		# fix the element connectivity
		$s->change_element_connectivity( 
			$s->vert($i)->name, $newIndex );

		# change the name of the vertex in question
		$s->vert($i)->change_name( $newIndex );

		# copy the new vertex to it's new index in the
		# fault array
		$s->{vert}->[$newIndex] = $s->vert($i);

		# undefine the old vertex
		$s->{vert}->[$i] = undef;

	}


	# change the number of vertices in the fault
	$s->{numVerts} = $newIndex;

	# ERROR CHECKING 
	# check to make sure the number removed equals what it should
       	if( $newIndex != $shouldBeNumVerts ) {

		print "wrong number of vertices removed for fault: ".
			$s->name."\n";
		print "numVerts = ".$s->numVerts."\n";
		print "numRemoved = $nRemoved, ".
			"shouldBeNumVerts = $shouldBeNumVerts,".
		       		"numNewVerts = $newIndex\n";
		return 0;

	}

	# if we've gotten here, everything's OK, so return true
	return 1;
		
} # end sub: clean_up_vertices
# --------------------------------------------------------------------

		
# --------------------------------------------------------------------
# subroutine: remove_vertex ********UNTESTED******* 
# 	$fault->remove_vertex( $vertexIndex );
# removes a vertex and moves all of the other vertices up in the array
# changes the name of each vertex so that the vertices will be sequential
# renumbers the element connectivity array to reflect the change
# in the vertex names
# ****assumes vertices are numbered sequentially*****
sub remove_vertex {

	my ($s, $vNum ) = @_;

	# loop through the vertices starting at the specified vert
	for( my $i = $vNum + 1; $i <= $s->numVerts; ++$i ) {
		
		#change the name of the current vertex to the
		#name of the next vertex
		$s->{vert}->[$i]->change_name ( 
			$s->{vert}->[$i]->name - 1 );
		
		# replace the previous vertex with the next vertex
		$s->{vert}->[$i-1] = $s->{vert}->[$i];

		# change the name of the vertex indices in the
		# each element's connectivity array
		$s->change_element_connectivity( $i, $i - 1 );

	} # end for
		
	# undefine the last vertex which no longer exists
	$s->{vert}->[$s->numVerts] = undef;
		
	#decrement the vertex counter
	$s->{numVerts}--;
}
# end sub: remove_vertex
# --------------------------------------------------------------------


# --------------------------------------------------------------------
# subroutine: vertex_names 
# 	$fault->vertex_names; 
# returns an array with the names of the vertices contained in the fault
# sorted in ascending order
# ( names = indices of #'s in the Poly3d file)  
sub vertex_names {

	my ($s) = @_;

	my @verts;
	
	# loop through the elements
	for( my $i = 1; $i <= $s->numElts; ++$i ) {

		# get the connectivity array for the current element
		my @c = $s->elt($i)->connectivity_array;
	
		# add the connectivity array to the verts array	
		push ( @verts, @c );
 
	} #end outer (all element looping) for

	# remove the duplicate vertex names from the array with perl magic
	my @temp;
	@verts = grep( !$temp[$_]++, @verts );

	# sort ascending
	@verts = sort { $a <=> $b } @verts;

	return @verts;	

} # end sub vertex_names
# --------------------------------------------------------------------


# --------------------------------------------------------------------
# subroutine: min_vertex_name 
# 	$fault->min_vertex_name; 
# returns the lowest name (index # in the Poly3d file) of the fault 
sub min_vertex_name {

	my ($s) = @_;

	# FIND THE MIN AND MAX VERTEX INDICES IN THE FAULT CONNECTIVITY ARRAYS
	# start by defining a min and max
	my $min = 99999999999;
	
	# loop through the elements
	for( my $i = 1; $i <= $s->numElts; ++$i ) {

		# get the connectivity array for the current element
		my @c = $s->elt($i)->connectivity_array;
	
		# loop through the connectivity array
		for( my $j = 0; $j < @c; ++$j ){

			# if the vertex name is less than min
			if( $c[$j] < $min ){
				
				# min gets the new low
				$min = $c[$j];
			} # end if

		} # end inner for
	} #end outer (all element looping) for

	return $min;

} # end sub min_vertex_name
# --------------------------------------------------------------------

# --------------------------------------------------------------------
# subroutine: max_vertex_name 
# 	$fault->max_vertex_name; 
# returns the largest name (index # in the Poly3d file) of the fault 
sub max_vertex_name {

	my ($s) = @_;

	# FIND THE MIN AND MAX VERTEX INDICES IN THE FAULT CONNECTIVITY ARRAYS
	# start by defining a min and max
	my $max = -1;
	
	# loop through the elements
	for( my $i = 1; $i <= $s->numElts; ++$i ) {

		# get the connectivity array for the current element
		my @c = $s->elt($i)->connectivity_array;
	
		# loop through the connectivity array
		for( my $j = 0; $j < @c; ++$j ){

			#if the vertex name is bigger than the max
			if( $c[$j] > $max ) {

				# max gets the new high
				$max = $c[$j];
			} # end if
		} # end inner for
	} #end outer (all element looping) for

	return $max;

} # end sub max_vertex_name
# --------------------------------------------------------------------



# --------------------------------------------------------------------
# subroutine: remove_element ********UNTESTED*******
# 	$fault->remove_element( $elementIndex ); 
# removes an element and moves all of the other elements up in the array
# changes the name of each element so that the elements will be sequential
# ****assumes elements are numbered sequentially*****
sub remove_element {

	my ($s, $eNum ) = @_;

	# loop through the elements starting at the specified elt
	for( my $i = $eNum; $i < $s->numElts; ++$i ) {
			
		#change the name of the next element to be 
	 	#the name of the current element
		$s->{elt}->[$i + 1]->change_name(  
			$s->{elt}->[$i]->name );
		
		# replace the current element with the next element
		$s->{elt}->[$i] = $s->{elt}->[$i + 1 ];


	} # end for
		
	# undefine the last element which no longer exists
	$s->{elt}->[$s->numElts] = undef;
		
	#decrement the element counter
	$s->{numElts}--;
}
# end sub: remove_element
# --------------------------------------------------------------------


# --------------------------------------------------------------------
# subroutine: change_element_connectivity
# searches the connectivity array in each element for a given
# vertex name (index) and replaces it with the given value
# use: $faultRef->change_element_connectivity( $findVertexName, $changeToName);
sub change_element_connectivity {

	my ( $s, $from, $to ) = @_;
	
	for( my $i = 1; $i <= $s->numElts; ++$i ) {

		# get the connectivity array for the current element
		my @c = $s->elt($i)->connectivity_array;

		# loop through that connectivity array
		for( my $j = 0; $j < @c; ++$j ){

			# if we find the vertex we're looking for
			if( $c[$j] == $from ){

				# replace the vertex with the new name
				# in the connectivity array
				$c[$j] = $to;

				# and replace the connectivity array
				# in the element
				$s->elt($i)->change_connectivity_array( @c );
				
			} # end if
		} # end inner for
	} #end outer (all element looping) for
}
# end sub change_element_connectivity
# --------------------------------------------------------------------

1;
