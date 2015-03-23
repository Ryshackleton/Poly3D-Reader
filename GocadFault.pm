# OOP perl code for creating fault objects 
#
package GocadFault;
use strict;
use GocadVertex;
use GocadElement;

# constructor
# to contstruct: my $fault = new Fault( "name" );
#
# Fault objects are made to hold and reference GocadVertex and GocadElement
# objects which can be added to the fault as follows:
# eg:
# $fault = new Fault( $name );
# 
# $vertex = new GocadVertex( @parsedVertexLine );
# $element = new GocadElement( $indexNumber, @parsedElementLine );
#
# $fault->add_vertex( $vertex );
# $fault->add_element( $element );
# 
sub new {

	my ( $class ) = $_[0];

	# create arrays for vertices (XYZ's)
	# and vertex numbers
	my $self = {

		name => $_[1],
		numVerts => 0,
		numElts => 0,
		colorline => undef
				
	};

	bless ( $self, $class );

	return $self;

}

# GETTER METHODS
sub name {  return $_[0]->{ name };       }
sub colorline { return $_[0]->{ colorline };       }
sub vert { return $_[0]->{ vert }->[$_[1] ];        }
sub elt {  return $_[0]->{ elt }->[$_[1] ];        }
sub numVerts { return $_[0]->{numVerts};        }
sub numElts {  return $_[0]->{numElts};         }

# subroutine: element_sizes_array 
# returns an array of element sizes in the fault
# indexed from 1 to n
sub element_sizes_array {

	my ( $s ) = @_;

	# biggest distance between vertices
	my @size;

	# loop through the elements in the fault
	for( my $i = 1; $i <= $s->numElts; ++$i ) {
	
		# define the connectivities	
		my @e = $s->elt( $i )->connectivity_array();

		my $eltSize;

		# loop through the connectivities (each vertex)
		for( my $j=0; $j < @e; ++$j ) {

			# define the index of the next vertex
			my $k = $j + 1;
		
			# if we are at the end of the connectivity
			# array, change the next vertex to the
			# zeroth vertex	(to compare the first
			# and last vertices)
			if( $k == @e ) {
					
				$k = 0;
			}

			# define the vertices
			my $v1 = $s->vert( $e[$j] );
			my $v2 = $s->vert( $e[$k] );

			# find the distance between the vertices
			my $dist = distance_between( $v1, $v2 );
				
			# if that distance is larger than the
			# largest we've found, redefine	
			if( $dist > $eltSize ) { 
			       $eltSize = $dist;
		       }
	       }  # end within element for

		# add that size to the element size array
		$size[$i] = $eltSize;

    	} # end all elements in fault loop

	return @size;
} # end sub element_sizes_array
# -----------------------------------------------------------

# -----------------------------------------------------------
# subroutine: largest_element 
# returns the size of the largest element the fault
# (ie the greatest distance between two vertices found
# in the elements in the fault)
sub largest_element {

	my ( $s ) = @_;

	# biggest distance between vertices
	my $size = 0;

	# loop through the elements in the fault
	for( my $i = 1; $i < $s->numElts; ++$i ) {
	
		# define the connectivities	
		my @e = $s->elt( $i )->connectivity_array();

		# loop through the connectivities (each vertex)
		for( my $j=0; $j < @e; ++$j ) {

			# define the index of the next vertex
			my $k = $j + 1;
		
			# if we are at the end of the connectivity
			# array, change the next vertex to the
			# zeroth vertex	(to compare the first
			# and last vertices)
			if( $k == @e ) {
					
				$k = 0;
			}

			# define the vertices
			my $v1 = $s->vert( $e[$j] );
			my $v2 = $s->vert( $e[$k] );

			# find the distance between the vertices
			my $dist = distance_between( $v1, $v2 );
		
			# if that distance is larger than the
			# largest we've found, redefine	
			if( $dist > $size ) { 
			       $size = $dist;
		       }

	       }  # end within element for
    	} # end all elements in fault loop

	return $size;
}
# -----------------------------------------------------------



# -----------------------------------------------------------
# subroutine: smallest_element 
# returns the size of the smallest element the fault
# (ie the smallest distance between two vertices found
# in the elements in the fault)
sub smallest_element {

	my ( $s ) = @_;

	# smallest distance between vertices
	my $size = 9999999999;

	# loop through the elements in the fault
	for( my $i = 1; $i < $s->numElts; ++$i ) {
	
		# define the connectivities	
		my @e = $s->elt( $i )->connectivity_array();

		# loop through the connectivities (each vertex)
		for( my $j=0; $j < @e; ++$j ) {

			# define the index of the next vertex
			my $k = $j + 1;
		
			# if we are at the end of the connectivity
			# array, change the next vertex to the
			# zeroth vertex	(to compare the first
			# and last vertices)
			if( $k == @e ) {
					
				$k = 0;
			}

			# define the vertices
			my $v1 = $s->vert( $e[$j] );
			my $v2 = $s->vert( $e[$k] );

			# find the distance between the vertices
			my $dist = distance_between( $v1, $v2 );
		
			# if that distance is smaller than the
			# smallest we've found, redefine	
			if( $dist < $size ) { 
			       $size = $dist;
		       }

	       }  # end within element for
    	} # end all elements in fault loop

	return $size;
}
# -----------------------------------------------------------



# -----------------------------------------------------------
# subroutine: average_element_size 
# returns the average element size in the fault
sub average_element_size {

	my ( $s ) = @_;

	my $total = 0;

	# loop through the elements in the fault
	for( my $i = 1; $i < $s->numElts; ++$i ) {
	
		# define the connectivities	
		my @e = $s->elt( $i )->connectivity_array();

		# current element size
		my $thisEltSize = 0;

		# loop through the connectivities (each vertex)
		for( my $j=0; $j < @e; ++$j ) {

			# define the index of the next vertex
			my $k = $j + 1;
		
			# if we are at the end of the connectivity
			# array, change the next vertex to the
			# zeroth vertex	(to compare the first
			# and last vertices)
			if( $k == @e ) {
					
				$k = 0;
			}

			# define the vertices
			my $v1 = $s->vert( $e[$j] );
			my $v2 = $s->vert( $e[$k] );

			# find the distance between the vertices
			my $dist = distance_between( $v1, $v2 );
	
			# make sure this is the largest side of the
			# element	
			if( $dist > $thisEltSize ) {
				$thisEltSize = $dist;
			}
		}  # end within element for

		# add the current element size to the total
		$total += $thisEltSize;
    	} # end all elements in fault loop

	return $total/$s->numElts;

} #end sub average_element_size
# -----------------------------------------------------------



# -----------------------------------------------------------
# subroutine: distance_between
# takes two vertices and returns the distance between them
sub distance_between {
      
	my ( $v1, $v2 ) = @_;
      
        my $d1 = $v1->x1 - $v2->x1;
        my $d2 = $v1->x2 - $v2->x2;
        my $d3 = $v1->x3 - $v2->x3;
      
       return sqrt( $d1*$d1 + $d2*$d2 + $d3*$d3 );
}       
# -----------------------------------------------------------

       
# SETTER METHODS
# adds an array of vertices to the fault:
# $faultReference->add_vertices( @newArrayOfVertices );
# where @newArrayOfVertices is an array of GocadVertex objects
# ***THE { vert } ARRAY IS INDEXED FROM 1 TO numVerts*****
sub add_vertices {

	my ( $self, @vertices ) = @_;

	for( my $i = 0; $i < @vertices; ++$i ) {
		
		$self->{vert}->[$i] = $vertices[$i];
		$self->{numVerts}++;
	}
}

# adds a single vertex to the fault
# $faultReference->add_vertex( $newGocadVertexToAdd );
sub add_vertex {

	my ( $self, $vertex ) = @_;

	# assign $n to be the number of vertices
	# already present in the fault + 1, which
	# will be the new vertex incrementer (not 
	# necessarily the vertex "name")
	my $n = $self->{numVerts}+1;
	$self->{ vert }->[ $n ] = $vertex;
	$self->{numVerts}++;

}

# creates a new vertex in the fault using referenced inputs
# $faultReference->create_vertex( @parsedGocadElementArray );
sub create_vertex {

	my ($self, @parsedArray ) = @_; 

	# my $n = $self->{numVerts}+1;
	$self->{ vert }->[ $self->{numVerts} + 1 ] = 
		new GocadVertex( @parsedArray );
	$self->{numVerts}++;
			                 
}
		

# # adds an array of elements to the fault:
# # $faultReference->add_elements( @newArrayOfGocadElements );
# # where @newArrayOfGocadElements is an array of Element objects
# # ***THE { elt } ARRAY IS INDEXED FROM 1 TO numElts*****
sub add_elements {

	my( $self, @elements ) = @_;

	for( my $i = 0; $i < @elements; ++$i ) {
		
		$self->{ elt }->[$i+1] = $elements[$i];
		$self->{ numElts }++;

	}
}

# adds a single element to the fault
# $faultReference->add_element( $newGocadElementToAdd );
sub add_element {

	my( $self, $element ) = @_;

	my $n = $self->{numElts}+1;
	$self->{ elt }->[ $n ] = $element;
	$self->{ numElts }++;

}

# creates a new element in the fault using referenced inputs
# $faultReference->create_element( $elementIndex, @parsedGocadElementArray );
sub create_element {

	my ($self, @parsedArray ) = @_;

	my $n = $self->{numElts}+1;
	$self->{ elt }->[ $n ] = new GocadElement( @parsedArray );
	$self->{numElts}++;
	
}

sub add_color_line {
	my ( $s, $line ) = @_;

	$s->{ colorline } = $line;

}

# TO STRING METHODS
# general format is ATTRIBUTE_to_string()
# #to call: $string = xyz_to_string();
sub header_to_string {
	my ($s) = @_;
	
	my $header = "GOCAD TSurf 1\nHEADER {\nname:"
	.$s->{ name }."\n".$s->{ colorline }.
	"\n}\nTFACE\n";
	
	return $header;	

}

# VERTEX MANIPULATION METHODS
# these methods work internally on the verices of a given fault
#
# usage: $removedString = $fault->remove_duplicate_vertices( $criticalDistance );
#  where $removedString is a string to hold info on which vertices were removed and
#        $criticalDistance is the smallest distance between vertices
#  	that is acceptable (so vertices with X,Y,and Z within 1 meter of each other
#  	will be considered to be duplicates
#
# RETURNS a string (which can be printed to a log file) of the vertices
# it removed in a given fault
sub remove_duplicate_vertices {

	# $criticalDistance is the distance between vertices that is
	# acceptable in METERS.  This assumes the vertices are
	# also defined in METERS
	my ($s, $criticalDistance ) = @_;

	# create a string with ONLY the XYZ's of removed vertices
	my $xyzs;

	# create information for a logfile
	my $nameIs = $s->name;
	my $logString = "==========================================================\n";
	$logString .= "REMOVED VERTICES FROM FAULT: $nameIs\n";
	$logString .= "with critical distance: $criticalDistance meters\n";
	$logString .= "---------------------------\n";
	# boolean to determine how many vertices were removed
	my $removed = 0;

	# loop through all the vertices
	#  (ending at the second to last vertex in the fault array)
	for( my $i = 1; $i < $s->numVerts - 1; ++$i ) {
		
		# define the current vertex being tested 
		my $active = $s->{vert}->[$i];
	
		# loop through all of the rest of the vertices 
		#  in the fault array
		for( my $j = $i+1; $j <= $s->numVerts; ++$j ){

			# define the vertex to be tested
			#  ( is it a duplicate? )
			my $isDup = $s->{vert}->[$j];
			
                        # get the name of the active vertex
			# and the duplicate vertex (for printing to a logfile)
                        my $activeName = $active->name;
		        my $isDupName = $isDup->name;
			
			# subtract the two vertices to determine
			# how far apart the vertices are
			my $x1diff = $active->x1 - $isDup->x1;
			my $x2diff = $active->x2 - $isDup->x2;
			my $x3diff = $active->x3 - $isDup->x3;
			
			# calculate the distance between the vertices
			my $absoluteDistance = 
				sqrt( $x1diff*$x1diff + $x2diff*$x2diff
					+ $x3diff*$x3diff );
				
			# then if the distance between vertices is
			#   less than the critical distance
			if( $absoluteDistance < $criticalDistance ) {
				
				# increment removed	
				$removed++;	
				
				# add to the logfile string
				$logString .= "removed: ".
					$isDup->inputLine_to_string.
					"\nduplicate of: ".
					$active->inputLine_to_string."\n";
				$logString .= "diffX1 = $x1diff  ".
					      "diffX2 = $x2diff  ".
			      	      		"diffX3 = $x3diff  ".
						"absolute distance = ".
						$absoluteDistance."\n\n";
				
				# add to the raw xyz string
				$xyzs .= "REMVERT".$isDup->x1."  ".$isDup->x2."  ".
					$isDup->x3."\n";

				# change the connectivity between elements
				# from the duplicate vertex to the active vertex
				$s->change_element_connectivity( $isDupName, 
							$activeName );
					
				# actually remove the vertex from the 
				# fault's vertex array
				$s->remove_vertex( $j );
				
			} # end inner if (checks for similarity of vertex xyz's
			 # a vertex to itself
		} # end inner for
	} #end outer for

	# add the number of points removed to the logstring
	$logString .= "Number of Vertices Removed: $removed\n";

	# formatting
	$logString .=  "==========================================================\n";

	#add the xyzs to the logstring
	$logString .= $xyzs;

	return $logString."\n\n";
	
} # end remove_duplicate_vertices

# removes a specified vertex from the list, shifts the rest of the vertices
# "up" in the list, and decrements the number of vertices present in the fault
# usage $self->remove_vertex( $vertexIndes );
# NOTE: $vertexIndex is the number in the array of the vertex, NOT the "name"
# of the vertex (although these should be the same for faults with vertices
# that start with 1)
sub remove_vertex {

	# vertex index in the fault array is the passed variable
	#  (not the vertex name)
	my ( $s, $vIndex ) = @_;

	# loop through the vertices starting one vertex ahead of the
	#  vertex to be removed 
	for( my $i = $vIndex + 1; $i <= $s->numVerts; ++$i ) {

		# decrement the name of the current vertex by one
		$s->{vert}->[$i]->change_name( 
			                $s->{vert}->[$i]->name - 1  );
		
		# replace the current vertex with the previous vertex
		$s->{vert}->[$i-1] = $s->{vert}->[$i];
	
		# modify the element connectivities to reflect
		#  the change in indexing of the vertices
		$s->change_element_connectivity( $i, $i - 1 );

	}
	
	# remove the last vertex which is no longer needed
	$s->{vert}->[ $s->numVerts ] = undef;
	
	# decrement the number of vertices
	$s->{numVerts}--;

} # end sub remove_vertex


# ELEMENT MANIPULATION METHODS
# 
# subroutine remove_elements_with_duplicate_vertices
# searches the element array in a given fault and if there are elements
# that have two vertices connected to one another, it removes them and
# returns a string representing the elements removed
sub remove_elements_with_duplicate_vertices {

	my ( $s, $vIndex ) = @_;

	my $output = "elements removed:\n";

	for( my $i = 1; $i <= $s->numElts; ++$i ) {

		my @conn = $s->elt( $i )->connectivity_array;
		
		@conn = sort { $a <=> $b } @conn;
		
		for( my $j = 0; $j < @conn - 2; ++$j ) {

			# if there are two like vertex numbers
			# in the array, remove the element
			if( $conn[$j] == $conn[ $j + 1 ] ) {

				# add that info to the removed string
				$output .= $s->elt( $i )->inputLine_to_string;
				$output .= "\n";

				$s->remove_element( $i );
			} # end if
		} # end connectivity searching for
	} # end element searching for

	return $output."\n\n";
}

# removes a given element from the fault
sub remove_element {

	my ($s, $elt ) = @_;

	# loop through the elements starting at the specified element
	for( my $i = $elt; $i <= $s->numElts-1; ++$i ) {

		# get the inputLine for the NEXT element in the list
		my $str = $s->elt( $i+1 )->inputLine_to_string;
		
		# make the input into an array
		my @input = split( " ", $str );
		
		# REPLACE the current element with a new element
		# identical to the next element
		$s->{ elt }->[ $i ] = new GocadElement( @input );	

	}

	# decrement the number of elements	
	$s->{ numElts }--;

} # end sub remove_element
		

		

		
# subroutine change_element_connectivity
# searches through the elements of the fault and replaces a vertex number
#  in the element connectivity array with a number specified
#  $self->change_element_connectivity( $from, $to );
#  (change the vertex name in the connectivity array from $from, to $to )
sub change_element_connectivity {

	my ( $s, $from, $to ) = @_;

	# loop through all the elements in the fault
	for( my $i = 1; $i < $s->numElts+1; ++$i ){

		# assign the connectivity array for the current
		# element that we'll be examining, and loop through that array
		my @connArray = $s->{elt}->[$i]->connectivity_array;
		for( my $j = 0; $j < @connArray; ++$j ) {

			# if you find a vertex that is named $from
			if( $connArray[$j] eq $from ) {

				# change that vertex name to $to
				$connArray[$j] = $to;

				# and reassign the connectivity array
				$s->{elt}->[$i]->
					change_connectivity_array( @connArray );

			} # end if
		} # end inner for that searches through connectivity array
	}# end outer for that searches through elements
} # end sub change_element_connectivity

# subroutine remove_duplicate_elements
# searches for duplicate elements, ie: elements with the same vertex numbers in
# the connectivity array
# $self->remove_duplicate_elements
sub remove_duplicate_elements {

	my ( $s, $index ) = @_;

	# log string to hold the indices of removed elements
	my $log = "Elements removed from ".$s->name.": ";
	
	# "boolean" to determine if any elements were removed
	# (if we find elements to remove, this will get undefined)
	my $none = "none";

	# loop through the elements in this fault
	for( my $i = 1; $i <= $s->numElts-1; ++$i ) {
		
		# get the connectivity array for this element
		my @pro = $s->{elt}->[$i]->connectivity_array;
	
		# sort the array ascending
		@pro = sort  { $a <=> $b } @pro;
		
		# loop through the rest of the elements
		for( my $j = $i+1; $j <= $s->numElts; ++$j ) {

			# get the connectivity array for this element
			my @conn = $s->{elt}->[$j]->connectivity_array;	
		
			# make a string to represent the current element
			my $proString = "TRGL ";
			$proString .= join( " ", @pro );
		
			# sort this array too
			@conn = sort { $a <=> $b } @conn;

			# loop through the first connectivity array
			for( my $k = 0; $k < @pro; ++$k ) {
				
				# if the connectiity arrays don't
				# have the same values, exit the loop
				if( $pro[$k] != $conn[$k] ) {
					
					last;
				
				# otherwise, if they do and we
				# have gotten to the end of the
				# connectivity array
				} elsif ( $k == @pro - 1 ) {
					
					# print that index to the log string
					$log .= "#$j <$proString>     ";

					# remove that element
					$s->remove_element( $j );
					
					#undefine the $none variable
					$none = undef;

				} # end if
			} # end connectivity array for loop
		} # end rest of elements loop
	} # end loop through elements loop

	# if we didn't find any vertices, add "$none" to the log string
	if( defined( $none ) ) {
		$log .= $none;
	}
	
	$log .= "\n";

	return $log;

} # end sub remove_duplicate_elements

1;
