#! /usr/bin/perl
#
# poly3dToGocad.pl
#
# converts a poly3d INPUT file to a gocad file
# useage: poly3dToGocad.pl input.in > input.ts
#
# works for files with multiple faults
# TODO: write a method in Fault.pm to determine which vertices are
# used by a given fault
#
# NOTE: this script uses Poly3dReader.pm, Fault.pm, Vertex.pm, and Elment.pm
# put these files in the same directory as this script  the FindBin::Bin
# package are used to search for the proper files in the current directory
use strict;
use FindBin;
use lib $FindBin::Bin;
use Poly3dReader;
use Poly3dFault;
use Poly3dVertex;
use Poly3dElement;

# command line args
my ( $INPUTFILE ) = @ARGV;

if(@ARGV != 1)
{
	print "usage: poly3dToGocad.pl input.in > input.ts\n";
	exit;
}

# parse the input file using Poly3dReader::parse_poly3d_input
# this creates a @fault array whose elements and vertices can 
# be accessed using methods described in their respective packages:
# ie: Fault.pm, Element.pm, etc.
my @fault = faults_from_poly3d_input ( $INPUTFILE );

# for each fault in the array:
for( my $i = 0; $i < @fault; ++$i ) {

	# print header information
	print "GOCAD TSurf 1\n";
	print "HEADER {\n";
	print "name:".$fault[$i]->name()."\n";
	print "mesh:false\n";
	print "ivolmap:false\n";
	print "imap:false\n";
	print "*solid*color:1.000000 1.000000 1.000000 1\n";
	print "}\n";
	print "GEOLOGICAL_TYPE top\n";
	print "TFACE \n";

	# define a current fault to make things shorter
	my $f = $fault[$i];
	
	# define the smallest vertex name (index) that we may or may not use
	my $smVert = 9999999;
	
	# if the vertices don't start with 1, we'll need to find the smallest
	# vertex to correct the vertices such that the vertices start with 1
	#  (because gocad doesn't seem to like vertices that start with numbers
	#  greater than 1)
	my $num = $f->vert( 1 )->name;

	if( $num > 1 ) {
		
	        # find the smallest vertex 
         	for( my $j = 1; $j <= $f->numVerts; ++$j ){
                     
                	#define the name of the vertex (number index)
                	my $vName = $f->vert( $j )->name; 
                	if( $vName  < $smVert ) { 
				$smVert = $vName; }
		} # end for
	
	# otherwise, if the vertices do start with 1, $smVert will be 0 (false)	
	} elsif ( $num == 1 ) {

		$smVert = 0;

	# otherwise, something's horribly wrong, so exit the program with message
	} else {

		die "Problem with vertices in poly3dToGocad: first IF statement\n";	
		
	} # end if 		
		
	# print vertices
	for( my $j = 1; $j <= $f->numVerts; ++$j ){
		
		my $newVrtx;
		# if $smVert is true subtract the value of 
		# the smallest vertex and add 1 (and assign
		# to $newVrtx )	
		if ( $smVert ) { 
	
			$newVrtx =  $f->vert( $j )->name - $smVert + 1;

		} else {
			
			# otherwise, just assign the value of the vertex to newVrtx
			$newVrtx = $f->vert( $j )->name;
		}	
		# double check to make sure $newVrtx is positive and exit
		# with message if it is
		( $newVrtx > 0 ) || die "Vertex less than zero!!!";
	
		# print to the file
		print "VRTX  ".$newVrtx.
			"  ".$f->vert( $j )->xyz_to_string."\n";
	}
	
	# print the connectivities
	for( my $j = 1; $j <= $f->numElts; ++$j ) {
		
		# if the vertices start with 1 (ie of $smVert is not zero)
		# correct the connectivity array
		if( $smVert  ) {  
		
			# get the connectivity array
			my @c = $f->elt( $j )->connectivity_array;
			
			#subtract the smallest vertex and add 1
			for ( my $k = 0; $k < @c; ++$k ){
				$c[ $k ] = $c[$k] - $smVert + 1;

			} # end for

			# print connectivities
			print "TRGL  ".$c[ 0 ]."  ".$c[1]."  ".$c[2]."\n";

		# otherwise, $smVert should be 1, so just print the
		# original connectivity array
		} else {
			
			print "TRGL  ".$f->elt( $j )->connectivity_to_string."\n";
		} # end if
		
	}
	
#	# I think this is unnecessary...
#	print "BSTONE 1\n";
#	print "BORDER  $largestVert  1 2\n";
	print "END\n\n";	

}

