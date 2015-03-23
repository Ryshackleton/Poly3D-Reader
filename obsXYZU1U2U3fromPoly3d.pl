#! /usr/bin/perl
#
# obsXYZfromPoly3d.pl
#
# reads poly3d input/output files and prints the XYZ's of the observation
# points to a new file (poly3dfile.xyz) delimited by an argument passed to 
# the command line 
# 			(DEFAULT DELIMITER IS SPACES)
#
# useage: obsXYZU1U2U3fromPoly3d.pl poly3dfile.in poly3dfile.out DELIMITER 
#
# NOTE: uses Poly3dReader.pm, Fault.pm, Vertex.pm, and Elment.pm
# put these files in the same directory as this script  the FindBin::Bin
# package are used to search for the proper files in the current directory
use strict;
use FindBin;
use lib $FindBin::Bin;
use Poly3dReader;
use Poly3dFault;
use Poly3dVertex;
use Poly3dElement;
use Poly3dObs;

# command line args ($D = delimiter
my ( $INPUTFILE, $OUTPUTFILE, $D ) = @ARGV;

# check the number of command line arguments, if there aren't 2 or 3 exit
# with a error message
if( (@ARGV > 3) || (@ARGV < 2) ) {
	print "useage: obsXYZU1U2U3fromPoly3d.pl poly3dfile.in poly3dfile.out DELIMITER\n";
	exit;
}

# if a third command line argument is not passed in, make $D spaces
if( !defined( $D ) ) {

	$D = "  ";

}

# get the observation info from the inputfile
my @obs = obs_from_poly3d_input_output( $INPUTFILE, $OUTPUTFILE );

# get the output file name (remove the .in on the end if there is one)
$INPUTFILE =~ s/.in//;

# open a new file
open( XYZ, ">$INPUTFILE.xyzu" );

print XYZ "X1".$D."X2".$D."X3".$D."U1".$D."U2".$D."U3\n";
				
for( my $i = 1; $i < @obs; ++$i ) {

	my $o = $obs[$i];

	if( $o->X1 != "" ) {
		print XYZ $o->X1.$D.$o->X2.$D.$o->X3.$D.$o->U1.$D.$o->U2.$D.$o->U3."\n";
	}

}

close( XYZ );
