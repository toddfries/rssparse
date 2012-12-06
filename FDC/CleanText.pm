# Copyright (c) 2011,2012 Todd T. Fries <todd@fries.net>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

package FDC::CleanText;

sub
recode
{
	my ($input) = @_;
	my $text = $$input;

	my $utfdebug = 0;

	foreach my $debugline ((
		#'Springing.*New Shopping.*Google',
		#'Kyle came in second and Bristol',
	)) {
		if ($text =~ /$debugline/) {
			$utfdebug = 1;
		}
	}
	if ($utfdebug) {
		printf STDERR "\nInput\n%s\n",$text;
	}

	$text =~ s/\x13//;
	$text =~ s/ï¿½\x1//;

	# 4 char sequences
	#$text =~ s/\xc3\x83\c2\a9/e/g;
	$text =~ s/\xc3\x83\xc2\xa9/e/g;
	$text =~ s/\xc3\x83\xc2\xa0/a/g;
	# 3 char sequences
	$text =~ s/\x{ef}\x{bf}\x{bd}//g;
	$text =~ s/â\x80\x93/-/g; 
	$text =~ s/â\x80\x99/'/g; 
	$text =~ s/â\x80\x9c/"/g; 
	$text =~ s/â\x80\x9d/"/g; 
	$text =~ s/â\x80¦/.../g;
	$text =~ s/\xc3¢Â//g;
	$text =~ s/\x80Â¦//g;
	$text =~ s/\x80Â\x93/-/g;
	$text =~ s/\x80Â\x94/--/g;
	$text =~ s/\x80Â\x99/'/g;
	$text =~ s/\x80Â\x9d/"/g;
	$text =~ s/Ã\x82Â//g;
	# 2 char sequences
	$text =~ s/\xA0\xAD/ /g;
	$text =~ s/\xc3(\x82|\x83)//g;
	$text =~ s/Â£/EUR/g;
	# 1 char sequences
	$text =~ s/\x94/"/g;
	$text =~ s/\x94/"/g; 
	$text =~ s/\x85/ /g;
	$text =~ s/\x92/'/g;
	$text =~ s/\x93/"/g; 
	$text =~ s/\x96/-/g; 
	$text =~ s/Â//g;
	$text =~ s/\xa0/ /g;
	if ($utfdebug) {
		printf STDERR "Output\n%s\n",$text;
	}
	return $text;
}

1;
