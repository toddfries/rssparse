# Copyright (c) 2010 Todd T. Fries <todd@fries.net>
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

package HTML::FormatText::WithImgLinks;

use strict;
use warnings;

sub
new
{
	my ($class) = @_;

	my $self = { };

	bless $self,$class;
}

sub
parse
{
	my ($self,$text) = @_;

	my $p = HTML::TokeParser->new( \$text );
	$p->xml_mode(1);
	my $c = "";
	my $a = "";
	my $i = 0;
	my $f = "";
	my @urls;
	my @imgs;
	while (my $t = $p->get_token()) {
		if ($t->[0] eq "T") { # Text
			my $tt = $t->[1];
			if (!($tt =~ /^[[:space:]]*$/)) {
				$tt .= " ";
			}
			$tt =~ s/[[:space::]][[:space:]]+/ /g;
			$c .= $tt;
			next;
		}
		if ($t->[0] eq "S") { # Start tag
			if ($t->[1] eq "a" && defined(${$t->[2]}{'href'})) {
				push @urls,${$t->[2]}{'href'};
				next;
			}
			if ($t->[1] eq "img" && defined(${$t->[2]}{'src'})) {
				push @imgs,${$t->[2]}{'src'};
				$c .= "%%img$#imgs%%";
				next;
			}
			if ($t->[1] =~ /^(div|span|p)/) {
				next;
			}
			if ($t->[1] eq "br") {
				$c .= "\n";
				next;
			}
		}
		if ($t->[0] eq "E") { # End tag
			if ($t->[1] eq "a") {
				$c .= "%%url$#urls%%";
				next;
			}
			if ($t->[1] eq "img") {
				next;
			}
			if ($t->[1] =~ /^(br|div|span)/) {
				next;
			}
			if ($t->[1] eq "p") {
				$c .= "\n";
				next;
			}
		}
		if ($t->[0] eq "C") { # Comment
			next;
		}
		if (0) {
		printf "{";
		$i=0;
		foreach my $subt (@{$t}) {
			printf " %d=%s",$i++,$subt;
			if (ref $subt eq "HASH") {
				printf "{";
				foreach my $key (keys %{$subt}) {
					printf "%s=>%s,",$key,${$subt}{$key};
				}
				printf "}";
			}
			if (ref $subt eq "ARRAY") {
				printf "[";
				foreach my $key (@{$subt}) {
					printf "%s,",$key;
				}
				printf "]";
			}
		}
		printf " }\n";
		}
	}
	my $cache;
	my $footnotefmt;
	if (@urls) {
		$f .= "\n";
		$i = 0;
		@{$cache} = ();
		foreach my $u (@urls) {
			$self->getoffset($u,$cache);
		}
		$footnotefmt = sprintf " %%%dd. %%s\n",$self->poweroften($#{$cache});
		@{$cache} = ();
		foreach my $u (@urls) {
			my $ucount = $#{$cache};
			my $offset = $self->getoffset($u,$cache);
			my $urlstr = sprintf "[%x]",$offset;
			$c =~ s/%%url${i}%%/$urlstr/g;
			if ($ucount < $#{$cache}) {
				$f .= sprintf "${footnotefmt}",$offset,$u;
			}
			$i++;
		}
	}
	if (@imgs) {
		$f .= "\n";
		@{$cache} = ();
		foreach my $img (@imgs) {
			$self->getoffset($img,$cache);
		}
		$footnotefmt = sprintf " IMG%%%dd. %%s\n",$self->poweroften($#{$cache});
		$i = 0;
		@{$cache} = ();
		foreach my $img (@imgs) {
			my $icount = $#{$cache};
			my $offset = $self->getoffset($img,$cache);
			my $imgstr = sprintf "IMG%x",$offset;
			$c =~ s/%%img${i}%%/$imgstr/g;
			if ($icount < $#{$cache}) {
				$f .= sprintf ${footnotefmt},${offset},$img;
			}
			$i++;
		}
	}
	@{$cache} = ();
	$text = $c;
	$text =~ s/[ \t]+/ /g;
	$text =~ s/(IMG[0-9]+|\[[0-9]+\])[[:space:]]+(IMG[0-9]+|\[[0-9]+\])/$1 $2/g;

	my $out="";
	my $lm=0;
	my $rm=72;
	my $pos=0;
	foreach my $line (split(/\n/,$text)) {
		foreach my $word (split(/[ \t]/,$line)) {
			if (($pos+length($word)+1) > $rm && length($word) < $rm) {
				$out.="\n";
				$pos=0;
			}
			$out .= $word." ";
			$pos += length($word)+1;
		}
		if ($pos > 0 ) {
			$out.="\n";
		}
	}
	$out =~ s/[ \t]*$//g;
	# add footnotes
	$out .= $f;
	return $out;
}

sub
getoffset
{
	my ($self,$item,$list) = @_;

	my $i = 0;
	foreach my $li (@{$list}) {
		if ($li eq $item) {
			return $i;
		}
		$i++;
	}
	push @{$list},$item;
	return $i;
}
sub
poweroften
{
	my ($self,$num) = @_;
	my $pow = 1;
	while ($num > 10) {
		$num = $num/10;
		$pow++;
	}
	return $pow;
}

1;
