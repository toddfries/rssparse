package FDC::CleanText;

sub
recode
{
	my ($input) = @_;
	my $text = $$input;

	my $utfdebug = 0;

	foreach my $debugline ((
		#'Springing.*New Shopping.*Google',
		'Kyle came in second and Bristol',
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
