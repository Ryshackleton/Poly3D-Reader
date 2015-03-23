#! /usr/bin/perl
#
# netSlipVector.pl 
# written by Ryan Shackleton, summer 2005
# (modified significantly from Ashley Griffith's scaledNetSlipVector.pl)
#
# 1) Reads a poly3d INPUT and OUTPUT file,
# 2) Calculates the net slip vector for elements on each fault
# 3) opens a new file for each fault that is readable by
# 	Explorer's InputPrStress module
# 	(files will be named: poly3doutputfile.faultname.netslip ) 
#	(SIG1 will be dip slip vector, SIG2 will be strike-slip vector,
#		and SIG3 will be net slip vector, in inputPrStressModule)
#		***NOT SURE IF STRIKE SLIP AND DIP SLIP VECTOR CALCULATIONS 
#		     ARE ACCURATE****
#	
# usage: netSlipVector.pl poly3dinputfile.in poly3doutputfile.out
#
# NOTE: this script uses Poly3dReader.pm, Poly3Fault.pm, Poly3dVertex.pm, 
# and Poly3dElement.pm
# put these files in the same directory as this script; the FindBin::Bin
# package are used to search for the proper files in the current directory
use strict;
use FindBin;
use lib $FindBin::Bin;
use Poly3dReader;
use Poly3dFault;
use Poly3dVertex;
use Poly3dElement;

# command line args
my ( $INPUTFILE, $OUTPUTFILE ) = @ARGV;

# check the number of command line arguments, if there aren't 2 or 3 exit
# with a error message
if( @ARGV != 2 ) {

	print "usage: netSlipVector.pl poly3dinputfile.in poly3doutputfile.out\n";
	exit;
}

# parse the input file for fault information
my @fault = faults_from_poly3d_input( $INPUTFILE );

# renumber the vertices
@fault = renumber_and_remove_unused_vertices( @fault );

# parse the displacements and stresses from the output file
# to the new @fault array or if there's a problem (and 
# parse_fault_displacements or stresses returns 0) exit
# with an error message 
parse_fault_displacements( $OUTPUTFILE, @fault ) 
	|| die "Can't parse_fault_displacements";

# calculate and print the net slip vector information to 
# each fault
#
# loop through the faults
for( my $i = 0; $i < @fault; ++$i ) { 

	# ref to current fault
	my $f = $fault[$i];

	# create a filestring for the current fault 
	my $fs;
	# create a spacer for the columns in the file
	my $s = " ";

	# number of elements in the fault
	my $numElts = $f->numElts;
	
	# print the header info to the filestring
	$fs .= "s-resolution: $numElts 1 1\n";
	$fs .= "x1 x2 x3 dipslip1 dipslip2 dipslip3 dipslipMAG ss1 ss2 ss3 ssMAG netslip1 netslip2 netslip3 netslipMAG SIG3\n";

	# CALCULATIONS (wacky, from Ashley Griffith's netslip.pl in:
	# /usr/people_on_kiwi/cooke/erik/fall02/spring03 on kiwi )
	
	# loop through the elements
	for( my $j = 1; $j <= $numElts; ++$j ) {

		# reference to this fault, this element
		my $e = $f->elt( $j );
		
		# references to vertices 1, 2, and 3
		my $v1 = $f->vert( $e->v1 );
		my $v2 = $f->vert( $e->v2 );
		my $v3 = $f->vert( $e->v3 );
		
		# FROM VERTICES SECTION OF ASHLEY'S SCRIPT
		# calculate u, v, w, the strike slip vector components
		my $u = ( $v1->x2 - $v2->x2 )*( $v2->x3 - $v3->x3 )
			- ( $v1->x3 - $v2->x3 )*( $v2->x2 - $v3->x2 );

		my $v = ( $v1->x3 - $v2->x3 )*( $v2->x1 - $v3->x1 )
			- ( $v1->x1 - $v2->x1 )*( $v2->x3 - $v3->x3 );

		my $w = ( $v1->x1 - $v2->x1 )*( $v2->x2 - $v3->x2 ) 
			- ( $v1->x2 - $v2->x2 )*( $v2->x1 - $v3->x1 );

		# normalize the strike-slip vector
		my $rootSums = sqrt( $v*$v + $u*$u );
		my $uN = $v;
		my $vN = -$u;
		my $wN = 0;

		if( $rootSums ) {

				$uN = $v / $rootSums; 
				$vN = -$u / $rootSums;
				$wN = 0;
		}

		# calculate the dip-slip vector	
		my $l = $u * $w;
		my $m = -$v * $w;
		my $n = $v*$v - $u*$u;

		# normalize the dip-slip vector
		my $lN = normalize( $l, $l, $m, $n );
		my $mN = normalize( $m, $l, $m, $n );
		my $nN = normalize( $n, $l, $m, $n );

		# calculate the net-slip vector
		my $p = $uN + $lN;
		my $q = $vN + $mN;
		my $r = $nN;	

		# FROM DISPLACEMENTS SECTION OF ASHLEY'S SCRIPT
		# multiply strike-slip vector by magnitude
		$uN = $uN * $e->B2;
		$vN = $vN * $e->B2;
		$wN = $wN * $e->B2;

		# multiply dip-slip vector by magnitude
		$lN = $lN * $e->B1;
		$mN = $mN * $e->B1;
		$nN = $nN * $e->B1;

		# calculate net-slip vector
		my $n1 = -( $uN + $lN );
		my $n2 = -( $vN + $mN );
		my $n3 = -( $wN + $nN );
	
		# calculate the net-slip magnitude
		my $netslipmag = sqrt( $e->B1 * $e->B1 + $e->B2 * $e->B2 );

		# write the element info to the filestring
		$fs .= $e->X1C.$s.$e->X2C.$s.$e->X3C.$s;

		# write the DIP-SLIP vector and magnitude
		$fs .= $lN/$e->B1.$s.$mN/$e->B1.$s.$nN/$e->B1.$s.$e->B1.$s;
		
		# write the STRIKE-SLIP vector and magnitude
		$fs .= $uN/$e->B2.$s.$vN/$e->B2.$s.$wN/$e->B2.$s.$e->B2.$s; 

		# write the NET-SLIP vector and magnitude 
		$fs .= $n1.$s.$n2.$s.$n3.$s.$netslipmag.$s;
		
		# add an endline character
		$fs .= "\n";

	} # end fault element for loop

	# create a file name based on the output file name
	# and the name of the fault: outputfilename.fault.netslip
	my $filename = $OUTPUTFILE;
	$filename =~ s/.out/./;
	$filename .= $f->name.".netslip";

	
	print "Writing data for fault < ".
       		$f->name." > to new file: $filename\n";
	
	# open the file, print the filestring to it, and close the file
	open( OUT, ">$filename" );
	print OUT $fs;
	close( OUT );
	
} # end fault for loop


# ------------------------------------------------------------------
# subroutine normalize
# normalizes a vector given the vector component to be normalized
#  and the other three comopoenents
# my $normalized = normalize( $toBeNormalized, $u, $v, $w );
sub normalize {

	my ( $numerator, $u, $v, $w ) = @_;

	my $denom = sqrt( $u*$u + $v*$v + $w*$w); 
	if( $denom ){
		return $numerator / $denom;
	}
	return $numerator;

} # end sub normalize
# ------------------------------------------------------------------
