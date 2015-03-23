#
# ROUTINES FOR PARSING INPUT FILES
#
#
# QUICK SUMMARY:
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

package ParserHelper;

use Exporter;
@ISA = ('Exporter');
@EXPORT = qw(number_pattern read_numbers skip_to skip_to_numbers read_through);

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
