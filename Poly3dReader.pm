# Subroutines to parse Poly3d input and output files and create
# Poly3dFault, Poly3dElement, Poly3dVertex, and Poly3dObs objects
# written by Ryan Shacketon, summer 2005
# 
# ===========================================================
# SUMMARY OF SUBROUTINES
# see method headers below for more detailed information
# on what each method does and how it operates
# ===========================================================
# 
# 
# ===========================================================
# PRE-PACKAGED SUBROUTINES THAT PARSE FAULT DATA
# ===========================================================
# subroutine: faults_from_poly3d_input
# 	@faults = faults_from_poly3d_input( $filename );
# 	
# parses a poly3d Input file for fault vertices and elements
# creates an array of Poly3dFault objects, 
# with their respective Poly3dElement and Poly3dVertex objects
# 
# ****does not modify or renumber vertices*****
#    call renumbre_and_remove_unused_vertices to fix this
#
# ***this method looks for flag "Section 4:" but some Poly3d files
#  don't have headers, so to fix, add "Section 4:" anywhere
#  above the fault definition section****
# -----------------------------------------------------------
# subroutine: renumber_and_remove_unused_vertices
# 	@faults = renumber_and_remove_unused_vertices( @fault )
# 	
# this subroutine takes an array of parsed Poly3dFault objects
# and calls Poly3dFault->clean_up_vertices which renumbers all
# the vertices in the fault object to be numbered from 1 to n
# -----------------------------------------------------------
# subroutine: parse_fault_displacements
# 	parse_fault_displacements( $outputFileName, @faultArray )
# 				 || die "can't parse";
# 				 
# parses a Poly3d out file for a given fault array and
# assigns the fault DISPLACEMENTS to the Elements of that fault
# returns true if successful or false if there's a problem
# -----------------------------------------------------------
# subroutine: parse_fault_stresses: 
# 	parse_fault_stresses( $outputFileName, @faultArray )
# 				 || die "can't parse";
# parses an input file for a given fault array and
# assigns the fault STRESSES to the Elements of that fault
# returns true if successful or false if there's a problem
# -----------------------------------------------------------



# ===========================================================
# PRE-PACKAGED SUBROUTINES TO READ POLY3D OBSERVATION DATA
# ===========================================================
# subroutine: obs_from_poly3d_input_output
# 	@obsPlanesPointsGrids = obs_from_poly3d_input_output( 
# 			$inputfilename, $outputfilename );
# 			
# READ ME CARFULLLY!!!!
# takes a poly3dInputFileName and a poly3dOutputFileName, and parses 
# the input and output files to create an array of Poly3dObs
# objects numbered from 1 to n
#
# ORDER OF OBJECTS IN THE NEW ARRAY:
# Observation points will retain the same name in the new array,
# Observation lines/planes/grids will be converted to Poly3dObs point objects
# whose name will be OriginalName1, OriginalName2,...OriginalNameN
# Multiple points/lines/planes/grids are ok, but a SINGLE ARRAY of Poly3dObs
# point objects will be returned, so the Poly3dObs object array may look like:
# $obsPlanesPointsGrids[0] = nothing (DUMMY OBJECT),
# $obsPlanesPointsGrids[1] = ObsPlane1,
# $obsPlanesPointsGrids[2] = ObsPlane2,
#      ......
# $obsPlanesPointsGrids[N] = ObsPlaneN,
# 
# $obsPlanesPointsGrids[N+1] = ObsPointA,
# $obsPlanesPointsGrids[N+2] = ObsPointB,
# 
# # $obsPlanesPointsGrids[N+3] = ObsGrid1,
# $obsPlanesPointsGrids[N+4] = ObsGrid2,
# ......
# $obsPlanesPointsGrids[N+M] = ObsGridM
#  where "ObsPlane, ObsPointA, ObsPointB, ObsGrid" were the names of the 
#  original observation objects
# 
# for more info, see obs_from_poly3d_input and obs_from_poly3d_output which
# are the methods that actually do the parsing
# -----------------------------------------------------------



# ===========================================================
# HELPER ROUTINES FOR PARSING POLY3D FILES
# ===========================================================
#  @array = line_to_array( $line );
#  	Takes a line, removes the endline (\n) character and
#  	splits the $line to an array by whitespace
# ---------------------------------------------------------- 	
#  @array = readline_to_array ( $fileHandle );
#  	same as line to array except it takes a filhandle,
#  	where $fileHandle is an already open file or typeglob to a file
#  eg: open( IN, $filename );
#  my $fh = *IN; # typeglob of the filename basically says where the file is
#  @array = readline_to_array( $fh );
#  or just:
#  open( IN, $filename );
#  @array = readline_to_array( *IN );
# ----------------------------------------------------------
#  $pat = number_pattern();
#    Return a perl regular expression pattern that matches a
#    scientific notation number (e.g. -1 or -1.0 or -1.0e-00)
# ----------------------------------------------------------
#  @array = read_numbers($line);
#    Fill up $array[0]..$array[n] with decimal numbers from input $line
# ----------------------------------------------------------
#  $line = skip_to_numbers(*FILEHANDLE, 8)
#    Keep reading lines from FILEHANDLE (e.g. STDIN) until you get
#    to a line with exactly 8 numbers on it.  Then return the line.
# ----------------------------------------------------------
#  $line = skip_to(*FILEHANDLE, 'PATTERN STRING');
#    Keep reading lines from FILEHANDLE until you get a line matching
#    PATTERN STRING, which is a full Perl regular expression.
#    Quick info on Perl regular expressions:
#     'DATA'  matches any line containing the letters DATA
#     '^DATA' matches a line BEGINNING with DATA 
#             (^ means the beginning of the line)
#     '^DATA$' matches a line that has ONLY 'DATA' on it-- ^ means
#          the beginning of a line, $ means the end.
#    For more info, do a 'man perlrequick' at a Unix command prompt.
# ----------------------------------------------------------
#  $lines = read_through(*FILEHANDLE, 'PATTERN STRING');
#    Keep reading lines from FILEHANDLE until you get a line matching
#    PATTERN STRING, which is a full Perl regular expression.
#    Returns all the lines read.
# ----------------------------------------------------------


# package definition
package Poly3dReader;

# this package is used to export the subroutines so that
# they can be used by other scripts
use Exporter;
@ISA = ('Exporter');
@EXPORT = qw( faults_from_poly3d_input renumber_and_remove_unused_vertices
	parse_fault_displacements parse_fault_stresses
	obs_from_poly3d_input_output
	number_pattern read_numbers skip_to 
	readline_to_array line_to_array skip_to_numbers read_through);

# ----------------------------------------------------------
# ----------------------------------------------------------
# SUBROUTINES FOR PARSING POLY3D INPUT AND OUTPUT FILES FOR 
# FAULT INFORMATION
# 	
# -----------------------------------------------------------
# subroutine: faults_from_poly3d_input 
# parses a poly3d Input file for fault vertices and elements
# creates an array of Poly3dFault objects, 
# with their respective Poly3dElement and Poly3dVertex objects
# returns an array of Poly3dFault objects
# useage eg:
# @faults = faults_from_poly3d_input( $filename );
sub faults_from_poly3d_input {

	my ( $filename ) = @_;

	# open the input file
	open( IN, $filename ) || die "Can't open $filename with Poly3dReader.pm";	

	# make a variable to represent a pointer to the filehandle
	my $fh = *IN;

	# find the faults sectioN
	#my $line = skip_to( $fh, "Section 4:" );

	# create some arrays to hold Faults, Vertices, and Elements
	my (@fault, @firstVertices, @vertices  );

	# indices: VERTICES AND ELEMENTS WILL BE INDEXED FROM 1..numElts
	# or 1..numVerts to correspond to the actual names of the vertices
	# and elements that usually start with 1
	# faults will be indexed from 0..n-1
	my $fIndex = 0;

	# $vIndex will be used for a temporary array that will be passed
	# into Poly3dFault via add_vertices( @array ); which takes a vertex
	# array indexed from 0..n-1
	my $vIndex = 0;

	# $elements will be created on-the-fly in Poly3dFault
	# using create_element( $Poly3dElement ); so we'll start
	# the index at 1 instead of 0
	my $eIndex = 1;

	# boolean to test whether we've found all of the vertices listed
	# at the beginning of the file, or whether they're listed along with
	# each fault (see the first elsif below for more info)
	my $first = 1;

	# read the whole file
	# THIS LOOP ASSUMES THAT THE VERTICES, OBJECTS AND ELEMENTS ARE LISTED
	# IN THAT ORDER, OR WITH ALL OF THE VERTICES LISTED FIRST
	while( !eof( $fh ) ) {
	
		# parse each input line to an array	
		my @p = readline_to_array( $fh );

		# if the line contains a vertex
		if( $p[0] eq "v" ) {
		
			# if this is the first time we have gone through the
			# vertices, add the vertex to the $firstVertices array
			# otherwise, add to the $vertices array
			$first ? $firstVertices[$vIndex] = 
						new Poly3dVertex( @p )
			: $vertices[$vIndex] = new Poly3dVertex( @p );
		
			++$vIndex;
		
		# otherwise, if the line is a fault object	
		} elsif ( $p[0] eq "o" ) {
		
			# create a new Poly3dFault object in the fault array
			$fault[ $fIndex ] = new Poly3dFault( @p );
		
			# at this point, we should be done reading the first
			# set of vertices, so $first will become false
			$first = 0;

			# at this point, we must evaluate whether ALL of the
			# vertices were listed at the beginning of the input
			# file, or if they are listed individually by fault
			# to do this, we'll "ask" whether @vertices
			#  is "true" (ie, if it's length is not 0 ), 
			#  if there are vertices in @vertices
			#  we'll add the @vertices array to the current fault, 
			#  otherwise, we'll add the @firstVertices array
			#   to the fault, which will contain all of the vertices
			#  TODO: write a method in Fault to determine 
			#  which vertices are needed 
			#  (by looking at the element connectivities)		
			@vertices ? $fault[ $fIndex]->add_vertices( @vertices )
			: $fault[ $fIndex ]->add_vertices( @firstVertices );
		
			# reset vertex index and clear the array of vertices
			$vIndex = 0;
			@vertices = ();

			# reset Element index so the next elements will start
			# with 1
			$eIndex = 1;

			# increment fault index
			$fIndex++;
	
		# otherwise, if the line is an element
		} elsif ( $p[0] eq "e" ) {
		
			# create a new Poly3dElement in the current fault
			# THIS ASSUMES THAT THE OBJECT IS 
			# LISTED BEFORE THE ELEMENTS	
			$fault[ $fIndex-1 ]->create_element( $eIndex, @p );
			$eIndex++;

		}	
			
	}	
	
	# close the input file
	close( IN );

	# return a reference to the fault array
	return @fault;
}
# -----------------------------------------------------------


# -----------------------------------------------------------
# subroutine: parse_fault_displacements
# parses a Poly3d out file for a given fault array and
# assigns the fault DISPLACEMENTS to the Elements of that fault
# returns true if successful or false if:
# 	1) a fault specified in the @fault array was not found
# 	2) no displacements were found in the output
# 	3) the number of elements in the inputfile doesn't match
# 	the number of elements read in the outputfile for a given fault
#       4) there are no dashed lines
# usage: parse_fault_displacements( $outputFileName, @faultArray )
# 				 || die "can't parse";
sub parse_fault_displacements {

	# inputs are ( $name of output file, @fault array )
	my ( $outputFileName, @f ) = @_;
	
	# for each fault in the array
	for( my $i = 0; $i < @f; ++$i ) {
		
		# abbreviate f[$i] because I'm lazy and hate typing []'s
		my $flt = $f[$i];
		
		# make sure there are displacements to be read for this
		# fault by checking the "outp" variable in the fault
		# which is read from the poly3d input file
		# if we don't find b (displacements output), 
		# skip to the next fault in the array
		if( $flt->outp !~ /b/ ) { next; }
		
		# open the outputfile
		open( OUT, $outputFileName ) || 
			die "Can't open outputfile with Poly3dReader.pm";
		# print "opened file for fault ".$f[$i]->name."\n"; #debugging

		# make a counter to be sure we read in all the elements
		my $nEltsRead = 0;
	
		# make a flag to look for the displacements
		my $flag = "OBJECT: ".$f[$i]->name;
			
		# skip to the DISPLACEMENTS section of the appropriate fault
		my $line = 1;
		my @p;
		# this is a bit tricky because there are no great flags for
		# each fault, and if we search for OBJECT: "faultname" on a 
		# line we could get the vertices or the elements, so we'll
		# search until we find OBJECT: "faultname", then search for
		# the DISPLACEMENTS section, then look for the dashed line.
		# The line below the dashed line should have 8 columns, if not
		# this method will keep looking, and likely return "false"
		# if it doesn't find the STRESSES section for the given fault
		# -> if we don't find the data objects, skip_to will reach
		# the end of the file and return "undef" (or false) which 
		# will exit the loop: if that's the case the next line below
		# the while loop will return 0 (false))
		while ( $line ) {
			
			# skip to the first flag (may be the vertices 
			# section or the fault displacements/stresses
			# section
			$line = skip_to( *OUT, $flag );
			$line = <OUT>;
			
			# make sure we're in the element section and 
			# not the vertex section	
			if( $line =~ /ELT CENTER COORD SYS/ ) {

				# find the DISPLACEMENTS section
				$line = skip_to( *OUT, "DISPLACEMENTS" );
			
				# skip to the line with dashes
				$line = skip_to( *OUT, "---" );

				# parse the first line after the dashes 
				# (which should be data with 14 columns)
				@p = readline_to_array( *OUT );
			
				# if we've found a line with 14 columns, we're
				# done, exit the loop
				if ( @p == 14 ) {
				
					# break out of the while loop
					last;
			
				}
			} # fi check for ELT CENTER COORD SYS
		} # end while 

		# if skip_to returns undef, we didn't find the line
		# something's way wrong, return false
		( $line ) || return 0;

		# read data lines (only lines with 14 columns) until there
		# are no lines with 14 columns
		while( @p == 14 ) {

			# assign the displacements to the appropriate element
			$flt->elt( $p[0] )->add_displacements( @p );
			
			# increment the counter
			$nEltsRead++;	
			
			# and read the next line
			@p = readline_to_array( *OUT );
	
		}

		# close the output file
		close( OUT );

		# debugging
		# print "nEltsRead: $nEltsRead, numElts: ".$f[$i]->numElts."\n";

		# check to make sure we read in all the elements
		# ( the number of elements in the input file = the
		#   number of elements in the output file)
		# if not return false
		( $nEltsRead == $flt->numElts ) || 
			print "Wrong number of elements parsed\n".
				"nEltsParsed: $nEltsRead, ".
			       	"numElts in input file: ".$flt->numElts."\n";
		( $nEltsRead == $flt->numElts ) || return 0;

	} # end for loop that loops through each fault

	# return true if successful
	return 1;

} # end sub parse_fault_displacements
# -----------------------------------------------------------
# 

# -----------------------------------------------------------
# subroutine: parse_fault_stresses: 
# parses an input file for a given fault array and
# assigns the fault STRESSES to the Elements of that fault
# returns true if successful or false if:
# 	1) a fault specified in the @fault array was not found
# 	2) no stresses were found in the output
# 	3) the number of elements in the inputfile doesn't match
# 	the number of elements read in the outputfile for a given fault
#       4) there are no dashed lines
# usage: parse_fault_stresses( $outputFileName, @faultArray )
# 				 || die "can't parse";
sub parse_fault_stresses {

	# inputs are ( $name of output file, @fault array )
	my ( $outputFileName, @f ) = @_;
	
	# for each fault in the array
	for( my $i = 0; $i < @f; ++$i ) {

		# abbreviate to make things easier
		my $flt = $f[$i];
		
		# check to be sure that TRACTION output was
		# specified (ie there was a t in the fault->outp variable
		# read from the poly3d input file
		# if not, return false
		if ( $flt->outp !~ /t/ ) { next; }
		
		# open the outputfile
		open( OUT, $outputFileName ) || 
			die "Can't open outputfile with Poly3dReader.pm";
		
		#debugging
		#print "opened file for fault ".$f[$i]->name."\n";

		# make a flag to look for the correct fault
		my $flag = "OBJECT: ".$flt->name;

		# skip to the STRESSES section of the appropriate fault
		my $line = 1;
		my @p;
		# this is a bit tricky because there are no great flags for
		# each fault, and if we search for OBJECT: "faultname" on a 
		# line we could get the vertices or the elements, so we'll
		# search until we find OBJECT: "faultname", then search for
		# the STRESSES section, then look for the dashed line.
		# The line below the dashed line should have 8 columns, if not
		# this method will keep looking, and likely return "false"
		# if it doesn't find the STRESSES section for the given fault
		# -> if we don't find the data objects, skip_to will reach
		# the end of the file and return "undef" (or false) which 
		# will exit the loop: if that's the case the next line below
		# the while loop will return 0 (false)
		while ( $line ) {
			
			# skip to the first flag (may be the vertices 
			# section or the fault displacements/stresses
			# section
			$line = skip_to( *OUT, $flag );
			$line = <OUT>;
			
			# make sure we're in the element section and 
			# not the vertex section	
			if( $line =~ /ELT CENTER COORD SYS/ ) {

				# find the STRESSES section
				$line = skip_to( *OUT, "STRESSES" );
			
				# skip to the line with dashes
				$line = skip_to( *OUT, "---" );
			

				# parse the first line after the dashes 
				# (which should be data with 8 columns)
				@p = readline_to_array( *OUT );
				
				# if we've found a line with 8 columns, we're
				# done, exit the loop
				if ( @p == 8 ) {
				
					# break out of the while loop
					last;
			
				}
			} # fi check for ELT CENTER COORD SYS
		} # end while 

		# if skip_to returns undef, we didn't find the line
		# return false
		( $line ) || return 0;
		
		# counter to find the number of elements read
		my $nEltsRead = 0;
		# read data lines (only lines with 8 columns) until there
		# are no lines with 8 columns
		while( @p == 8 ) {

			# assign the stresses to the appropriate element
			$flt->elt( $p[0] )->add_stresses( @p );
			
			# increment the counter
			$nEltsRead++;	
			
			# and read the next line
			@p = readline_to_array( *OUT );
	
		}


		
		# close the output file
		close( OUT );

		# debugging
		# print "nEltsRead: $nEltsRead, numElts: ".$f[$i]->numElts."\n";

		# check to make sure we read in all the elements
		# ( the number of elements in the input file = the
		#   number of elements in the output file)
		# if not return false
		( $nEltsRead == $f[$i]->numElts ) || 
			print "Wrong number of elements parsed\n".
				"nEltsParsed: $nEltsRead, ".
			       	"numElts in input file: ".$f[$i]->numElts."\n";
		( $nEltsRead == $f[$i]->numElts ) || return 0;

	} # end for loop that loops through each fault

	# return true if successful
	return 1;

} # end sub parse_fault_stresses
# -----------------------------------------------------------
#
#
# 
# -----------------------------------------------------------
# subroutine: renumber_and_remove_unused_vertices
# this subroutine takes an array of parsed Poly3dFault objects
# and calls Poly3dFault->clean_up_vertices, which removes any
# unused vertices and renumbers the vertices from 1 to n if there
# are unused vertices, or if there are no unused vertices, it
# renumbers any vertices that don't start at 1, from 1 to n.
sub renumber_and_remove_unused_vertices {

	my ( @f ) = @_;

	for( my $i = 0; $i < @f; ++$i ) {

		# get the name of the fault (in case of error)
		my $name = $f[$i]->name;

		# clean up the vertices in each fault or exit with
		# error message
		$f[$i]->clean_up_vertices ||
			die "Could not clean_up_vertices for fault: $name";

	}

	return @f;

}




# ----------------------------------------------------------
# ----------------------------------------------------------
# SUBROUTINES FOR PARSING POLY3D INPUT AND OUTPUT FILES FOR 
# OBSERVATION INFORMATION
# 
# -----------------------------------------------------------
# subroutine: obs_from_poly3d_input_output
# @obsPlanesPointsGrids = obs_from_poly3d_input_output( 
# 			$inputfilename, $outputfilename );
# READ ME CARFULLLY!!!!
# takes a poly3dInputFileName and a poly3dOutputFileName, and parses 
# the input and output files to create an array of Poly3dObs
# objects.  
#
# ORDER OF OBJECTS IN THE NEW ARRAY:
# Observation points will retain the same name in the new array,
# Observation lines/planes/grids will be converted to Poly3dObs point objects
# whose name will be OriginalName1, OriginalName2,...OriginalNameN
# Multiple points/lines/planes/grids are ok, but a SINGLE ARRAY of Poly3dObs
# point objects will be returned, so the Poly3dObs object array may look like:
# $obsPlanesPointsGrids[0] = nothing (DUMMY OBJECT),
# $obsPlanesPointsGrids[1] = ObsPLANE1,
# $obsPlanesPointsGrids[2] = ObsPLANE2,
#      ......
# $obsPlanesPointsGrids[N] = ObsPLANEN,
# 
# $obsPlanesPointsGrids[N+1] = ObsPOINTA,
# $obsPlanesPointsGrids[N+2] = ObsPOINTB,
# 
# # $obsPlanesPointsGrids[N+3] = ObsGRID1,
# $obsPlanesPointsGrids[N+4] = ObsGRID2,
# ......
# $obsPlanesPointsGrids[N+M] = ObsGRIDM
#  where "ObsPLANE, ObsPOINTA, ObsPOINTB, ObsGRID" were the names of the 
#  original observation objects
# 
# for more info, see obs_from_poly3d_input and obs_from_poly3d_output which
# are the methods that actually do the parsing
# 
sub obs_from_poly3d_input_output {
	
	my ( $inputFileName, $outputFileName ) = @_;
	
	# get the observation info from the inputfile
	my @obs = obs_from_poly3d_input( $inputFileName );


	# get the observation information from the output file
	# and replace the old @obs info with the new array of
	# observation points
	@obs = obs_from_poly3d_output( $outputFileName, @obs );

	return @obs;

} # end obs_from_poly3d_input_output
# ----------------------------------------------------------
#
# 
# -----------------------------------------------------------
# subroutine: obs_from_poly3d_input
# @obsPlanesPointsGrids = obs_from_poly3d_input( $fileName );
#
# takes a poly3d input file name, opens the file, and parses it for
# the observation point, plane, or grid data
# returns an array of Poly3dObs objects that contain only the information
# in the input file, points, planes, and grids are individual objects (for now)
sub obs_from_poly3d_input {
	my ( $fileName ) = @_;
	
	# array of Poly3dObs objects
	my @obs;
	
	open( IN, $fileName ) || 
	die "Can't open $fileName with Poly3dReader->obs_from_poly3d_input";
	
	# find the first observation grid line
	my $line = skip_to( *IN, "OBSERVATION GRIDS" );
     	my $line = skip_to( *IN, "---" );

	# parse the line to an array	
	my @p = readline_to_array( *IN );

	my $i = 1;
	while( @p > 8 ) {
		
		# add a new observation object to the array	
		$obs[$i] = new Poly3dObs( @p );
		
		# read the next line
		@p = readline_to_array( *IN );

		# increment the counter		
		++$i;
	}		
	close( IN );

	return @obs;
	
} # end obs_from_poly3d_input
# ----------------------------------------------------------


# ---------------------------------------------------------
# subroutine: obs_from_poly3d_output
# takes a poly3d output file name, opens the file, and parses it for
# the observation point, plane, or grid data in the specified @obs array
# creates and returns a new array of Poly3dObs objects by converting
# any lines/planes/grids to Poly3dObs points 
# and then reading add adding the proper
# DISPLACEMENTS, STRESSES, PRINCIPAL STRESSES, etc to each point
# points derived from new planes and grids will be named as follows:
# name = obsplane -> name = obsplane1,
# 				obsplane2, obsplane3, ...obsplaneN
# usage: my @newObsPoints = 
# 	obs_from_poly3d_output( $OUTPUTFILENAME, @obsObjectsFromInputFile ); 
sub obs_from_poly3d_output {
	
	# $filename, @observationPoint/Line/Plane/GridAarray are inputs
	# these should have only the information from the input file
	my ( $fn, @obs ) = @_;

	#open the output file
	open( OUT, $fn ) ||
	die "Can't open $fn with Poly3dReader->obs_from_poly3d_output";

	# typeglob (abbreviate) the location of OUT
	my $fh = *OUT;

	# find the next observation grid line
	my $line = skip_to( $fh, "OBSERVATION GRID:" );
		
	#parse the OBSERVATION GRID: line to an array
	# so we can get the name of the observation point/line/etc.
	my @p = line_to_array( $line );

	# the name of the observation point/grid/plane should be
	# the 4th column, so find the Poly3dObs object with
	# that name
	my $ob = obj_with_name( $p[3], @obs );
		
	# get the output string that will define what we will
	# look for in the output file (eg displacements, stresses,etc)
	#print "working on obs: ".$ob->name."\n";
	my $outp = $ob->outp;
	
	# while there is still an output string left to parse
	while( $outp ) {
				
		# we need to figure out what to look for, which could
		# be any of the following: DISPLACEMENTS (d),
		# STRAINS (e), PRINCIPAL STRAINS (pe),
		# STRESSES (s), or PRINCIPAL STRESSES (ps),
		# so we'll parse the input string "outp" to figure out
		# what to look for and how to deal with each case
	
		# we'll use perl's s/searchstring/replacestring/ method
		# to determine what to look for.  Since we might find
		# "e" if there is an "e" OR a "pe" in the string, or
		# an "s" if there is an "s" OR a "ps", we'll change
		# pe to PE and ps to PS in the string
		$outp =~ s/pe/PE/;
		$outp =~ s/ps/PS/;
	       
		# (NOTE: the order of each CASE shown here 
		# assumes that poly3d outputs the data in the
		#  order listed below, which the Windows version
		# does: (DISPLACEMENTS, STRAIN TENSOR, PRINCIPAL STRAINS
		#  STRESS TENSOR, PRINCIPAL STRESSES).  If they are
		#  listed in a different order, we might read past
		#  a given data set before we know what to look for)
		# 
		# DISPLACEMENTS CASE
		# if the output string contains d
		if( $outp =~ /d/ ){ 
			
			# remove the "d" from our output string
			$outp =~ s/d//;

			# parse and replace the new observation
			# objects with the new parsed data
			@obs = parse_obs_stuff( $fh, "DISPLACEMENTS",
			       	6, "add_displacements", $ob, @obs );
	       }
	       
		# STRAIN TENSOR CASE
	       # if the string contains e
	       if( $outp =~ /e/ ) {

			# remove the "e" from our output string
			$outp =~ s/e//;
				
			# parse and replace the new observation
			# objects with the new parsed data
			@obs = parse_obs_stuff( $fh, "E11", 9,
				"add_strain_tensor", $ob, @obs );	
		}
	       # PRINCIPAL STRAINS CASE
	       # if the string contains PE (capitalized)
	       if( $outp =~ /PE/ ) {

		       # remove the "pe" from our output string
		       $outp =~ s/PE//;
		       
			# parse and replace the new observation
			# objects with the new parsed data
		       @obs = parse_obs_stuff( $fh, 
			       "PRINCIPAL STRAINS", 15,
			       "add_principal_strains", $ob, @obs );
	       }
	       # STRESS TENSOR CASE
	       # if the output string contains s
	       if( $outp =~ /s/ ) {

		       # remove the "pe" from our output string
		       $outp =~ s/s//;
		       
			# parse and replace the new observation
			# objects with the new parsed data
		       @obs = parse_obs_stuff( $fh, "SIG11", 9,
			       "add_stress_tensor", $ob, @obs );
 
	       } 
	       # PRINCIPAL STRESSES CASE
	       # if the output string contains PS (capitalized)
	       if( $outp =~ /PS/ ) {

		       # remove the "pe" from our output string
		       $outp =~ s/PS//;
			# parse and replace the new observation
			# objects with the new parsed data			
		       @obs = parse_obs_stuff( $fh,
			       "PRINCIPAL STRESSES", 15,
			       "add_principal_stresses", $ob, @obs );
	       }
       } # end while

       #close the output file
       close( OUT );
      
       # return the new observation poitns
       return @obs;
	
} # end obs_from_poly3d_output
# ----------------------------------------------------------
#

#
# 
# ----------------------------------------------------------
# subroutine: parse_obs_stuff
# helper method for obs_from_poly3d_output
# my @newObsArray = parse_obs_stuff( $filehandle, $flag, $numberOfDataColumns,
# 		$subroutineToCallInPoly3dObs.pm, $oldObs, @newObsArray );
# crazy method that takes 1) a filehandle of a file in the middle of being read,
# 2) a $flag (such as DISPLACEMENTS in a poly3d output file)
# 3) the number of data colums that that section should have eg, 6 columns for 
#     DISPLACEMENTS output
# 4) the name of the proper subroutine to be called in Poly3dObs such as:
#       add_displacements, add_principal_stresses, add_strain_tensor, etc.
# 5) a reference to the old observation Poly3dObs object that contains
#     information from the input file
# 6) a reference to a new array of Poly3dObs objects that will be modified
#    and later returned
sub parse_obs_stuff {

	my ( $fh, $flag, $nCols, $subName, $old, @new ) = @_;
	
	# assumes that the filehandle we have has already
	# been read to the correct section (ie to: OBSERVATION GRID: Name)
	# skip to the output flag type (eg DISPLACEMENTS, STRESSES)
      	my $line = skip_to( $fh, $flag );

	# find the line with dashes below the flag
	$line = skip_to( $fh, "---" );
	
	# read the first input line to an array	
	my @p = readline_to_array( $fh );

	my $k = 1; #new name count for each obs object: eg Obsplane1, Obsplane2

	# while there are the correct number of columns on a given line
	while( @p == $nCols ){
		
		# abbreviate the length of @new to create new elements
		# at the end of the @new array (remember that $new[0]
		# is meaningless, so the length of @new is 1 more than
		# the number of obs objects
		my $i = @new;
		
		# if the observation object is a line/plane/grid
		if( $old->dim != 0 ) {
			
			# look in @new to see if the object we're looking
			# for has already been defined (if not, obj_with_name
			# will return 0 )
			my $foundObj = obj_with_name( $old->name.$k, @new );
			
			# if the value hasn't been defined yet,
			# create a new one using the info from the $old
			if( $foundObj == 0 ) {
				
				# make a new observation point with the 
				# same info as the old observation 
				# line/plane/grid
				my @a = line_to_array( 
					$old->inputLine_to_string );
				$new[$i] = new Poly3dObs( @a );
				
				# rename the new observation point to
				# oldName + $k (concatenated)
				$new[$i]->change_name(
					$old->name.$k );

				# change it's dimension to zero (point)
				$new[$i]->change_dim( 0 );

				# add the parsed displacements to the 
				# new obs object
				$new[$i]->$subName( @p );

			# otherwise, just add the displacements/stresses....
			# to the $foundObj
			} else {

				$foundObj->$subName( @p );
			}


			# increment the counter	
			$k++;

		# otherwise it's a previously defined point so we can 
		# need to find that point in the @new array and add 
		# the new variables to it
		} else {
			
			# find the object in the array
			my $foundObj = obj_with_name( $old->name, @new );

			# and add the displacements/stresses/prstresses...
			$foundObj->$subName( @p );

			# find the next observation grid line
			$line = skip_to( $fh, "OBSERVATION GRID:" );
				
			#parse the OBSERVATION GRID: line to an array
			# so we can get the name of the next observation 
			# point/line/etc.
			@p = line_to_array( $line );
		
			# the name of the observation point/grid/plane should be
			# the 4th column, so find the Poly3dObs object with
			# that name, if it exists in the array, redefine it as
			# $old in case there are line/plane/grid observation
			# objects after the point objects
			if( obj_with_name( $p[3], @new ) ) {
				$old = obj_with_name( $p[3], @new );
			}

			# because we've switched to a new observation point/
			# line/plane/grid, we will need to start the numbering
			# scheme over, so set k = 1
			$k = 1;

			# find the line with dashes below the flag
			$line = skip_to( $fh, "---" );
		
		} # end if

		# read the next line
		@p = readline_to_array( $fh );

	} #end while

	return @new;


} # end sub parse_obs_stuff
# ----------------------------------------------------------


# ----------------------------------------------------------
# subroutine: obj_with_name
# takes a $name string and an array of Poly3d* objects and
# searches through the array until it finds the object that
# matches the $name string, then returns that object or 0 if
# it doesn't find the name in the array
# usage: my $objRef = obj_with_name( $nameToFind, @arrayToFindNameIn );
sub obj_with_name {

	my ( $name, @obs ) = @_;

	# loop through the obs array
	for( my $i = 1; $i < @obs; ++$i ){

		# if we find the right name
		if( $obs[$i]->name eq $name ) {

			# return that object
			return $obs[$i];

		}
	}
	
	# if we made it here return false
	return 0;

}
# end obj_with_name
# ----------------------------------------------------------




# ----------------------------------------------------------
# ----------------------------------------------------------
# HELPER ROUTINES FOR PARSING POLY3D FILES
#
#
# QUICK SUMMARY:
#
#  @array = line_to_array( $line );
#  	Takes a line, removes the endline (\n) character and
#  	splits the $line to an array by whitespace
#  	
#  @array = readline_to_array ( $fileHandle );
#  	same as line to array except it takes a filhandle,
#  	where $fileHandle is an already open file or typeglob to a file
#  eg: open( IN, $filename );
#  my $fh = *IN; # typeglob of the filename basically says where the file is
#  @array = readline_to_array( $fh );
#  or just:
#  open( IN, $filename );
#  @array = readline_to_array( *IN );
#  
#  $pat = number_pattern();
#    Return a perl regular expression pattern that matches a
#    scientific notation number (e.g. -1 or -1.0 or -1.0e-00)
#
#  @array = read_numbers($line);
#    Fill up $array[0]..$array[n] with decimal numbers from input $line
#  
#  $line = skip_to_numbers(*FILEHANDLE, 8)
#    Keep reading lines from FILEHANDLE (e.g. STDIN) until you get
#    to a line with exactly 8 numbers on it.  Then return the line.
#
#  $line = skip_to(*FILEHANDLE, 'PATTERN STRING');
#    Keep reading lines from FILEHANDLE until you get a line matching
#    PATTERN STRING, which is a full Perl regular expression.
#    Quick info on Perl regular expressions:
#     'DATA'  matches any line containing the letters DATA
#     '^DATA' matches a line BEGINNING with DATA 
#             (^ means the beginning of the line)
#     '^DATA$' matches a line that has ONLY 'DATA' on it-- ^ means
#          the beginning of a line, $ means the end.
#    For more info, do a 'man perlrequick' at a Unix command prompt.
#
#  $lines = read_through(*FILEHANDLE, 'PATTERN STRING');
#    Keep reading lines from FILEHANDLE until you get a line matching
#    PATTERN STRING, which is a full Perl regular expression.
#    Returns all the lines read.
#
## -----------------------------------------------------------
# subroutine: line_to_array
# @p = line_to_array( $line );
# takes a series of strings and parses it to an array (removes endline)
sub line_to_array {
	my ( $line ) = @_;
	
	chomp $line;

	my @parsed = split( " ", $line );

	return @parsed;

} # end line_to_array
# ----------------------------------------------------------

# -----------------------------------------------------------
# subroutine: readline_to_array
# takes a filehandle, reads the current line, removes the endline, 
# and splits the line to an array
#   returns an array with the contents of the line
sub readline_to_array {
	( my $fh ) = @_;

	my $line;
	my @parsed;

	$line = <$fh>;
	chomp $line;
	@parsed = split( " ", $line );

	return @parsed;

} # end readline_to_array
# -----------------------------------------------------------
#
#
# Useful pattern string: IEEE floating point number
#  (without Inf/NaN):
#
$ieee_num = '([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?';

sub number_pattern()
{
	return $ieee_num;
}

#
# Read a bunch of numbers from an input line.
#  Example:   @numbers = read_numbers($line);
#
sub read_numbers {
    use POSIX qw(strtod);

	my ($line) = @_;

	my @array;

	my $number;
	my $index = 0;

	while ($line =~ /$ieee_num/g) { # /g means keep matching...
		my ($num, $rest) = strtod($&);
		$array[$index] = $num;
		$index++;
	}
	return @array;
}

#
# Skip ahead to a line matching a given pattern (and return that line).
#  Example:  $line = skip_to(*STDIN, "START OF DATA");
# If the end of the file is reached, undef is returned.
#
sub skip_to {
	my ($fh, $patternString) = @_;

	my $line;
    do {
		if (eof($fh)) {
			return undef;
		}
		$line = <$fh>;
		chomp $line;
	} while ($line !~ /$patternString/);

	return $line; # Got a match
}


#
# Skip ahead to a line with EXACTLY N numbers on it.
#  Example: $line = skip_to_numbers(*STDIN, 8)
# Returns undef if no such line could be found.
#
sub skip_to_numbers {
	my ($fh, $n) = @_;

	my $line;
	my @array;
    do {
		if (eof($fh)) {
			return undef;
		}
		$line = <$fh>;
		chomp $line;
	} while ($line !~ /^(\s*($ieee_num)\s*){$n}$/);

	return $line;
}

#
# Read and return a bunch of lines until a given pattern.
#  Example:  $lines = read_through(*STDIN, "END OF SECTION");
# If the end of the file is reached, what's read so far is returned.
#
sub read_through {
	my ($fh, $patternString) = @_;

	my $lines, $line;
    do {
		if (eof($fh)) {
			return $lines;
		}
		$line = <$fh>;
		$lines .= $line;
	} while ($line !~ /$patternString/);

	return $lines; # Got a match
}


1;
