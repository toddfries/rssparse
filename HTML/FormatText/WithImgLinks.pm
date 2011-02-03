# Copyright (c) 2010,2011 Todd T. Fries <todd@fries.net>
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

use MIME::Charset;
use HTML::TokeParser;

use Encode;

use FDC::CleanText;

sub
new
{
	my ($class,$cset,$wordwrap) = @_;

	my $self = { };

	my $ret = bless $self,$class;
	$self->{cset} = $cset;
	if (defined($wordwrap)) {
		$self->{wordwrap}=$wordwrap;
	} else {
		$self->{wordwrap}=0;
	}
	@{$self->{filters}}=();
	$self->init;
	return $ret;
}

our %entity2char = (
 # Some normal chars that have special meaning in SGML context
'amp;'    => '&',  # ampersand 
'gt;'    => '>',  # greater than
'lt;'    => '<',  # less than
'quot;'   => '"',  # double quote
'apos;'   => "'",  # single quote

 # PUBLIC ISO 8879-1986//ENTITIES Added Latin 1//EN//HTML
'AElig;'	=> chr(198),  # capital AE diphthong (ligature)
'Aacute;'	=> chr(193),  # capital A, acute accent
'Acirc;'	=> chr(194),  # capital A, circumflex accent
'Agrave;'	=> chr(192),  # capital A, grave accent
'Aring;'	=> chr(197),  # capital A, ring
'Atilde;'	=> chr(195),  # capital A, tilde
'Auml;'	=> chr(196),  # capital A, dieresis or umlaut mark
'Ccedil;'	=> chr(199),  # capital C, cedilla
'ETH;'	=> chr(208),  # capital Eth, Icelandic
'Eacute;'	=> chr(201),  # capital E, acute accent
'Ecirc;'	=> chr(202),  # capital E, circumflex accent
'Egrave;'	=> chr(200),  # capital E, grave accent
'Euml;'	=> chr(203),  # capital E, dieresis or umlaut mark
'Iacute;'	=> chr(205),  # capital I, acute accent
'Icirc;'	=> chr(206),  # capital I, circumflex accent
'Igrave;'	=> chr(204),  # capital I, grave accent
'Iuml;'	=> chr(207),  # capital I, dieresis or umlaut mark
'Ntilde;'	=> chr(209),  # capital N, tilde
'Oacute;'	=> chr(211),  # capital O, acute accent
'Ocirc;'	=> chr(212),  # capital O, circumflex accent
'Ograve;'	=> chr(210),  # capital O, grave accent
'Oslash;'	=> chr(216),  # capital O, slash
'Otilde;'	=> chr(213),  # capital O, tilde
'Ouml;'	=> chr(214),  # capital O, dieresis or umlaut mark
'THORN;'	=> chr(222),  # capital THORN, Icelandic
'Uacute;'	=> chr(218),  # capital U, acute accent
'Ucirc;'	=> chr(219),  # capital U, circumflex accent
'Ugrave;'	=> chr(217),  # capital U, grave accent
'Uuml;'	=> chr(220),  # capital U, dieresis or umlaut mark
'Yacute;'	=> chr(221),  # capital Y, acute accent
'aacute;'	=> chr(225),  # small a, acute accent
'acirc;'	=> chr(226),  # small a, circumflex accent
'aelig;'	=> chr(230),  # small ae diphthong (ligature)
'agrave;'	=> chr(224),  # small a, grave accent
'aring;'	=> chr(229),  # small a, ring
'atilde;'	=> chr(227),  # small a, tilde
'auml;'	=> chr(228),  # small a, dieresis or umlaut mark
'ccedil;'	=> chr(231),  # small c, cedilla
'eacute;'	=> chr(233),  # small e, acute accent
'ecirc;'	=> chr(234),  # small e, circumflex accent
'egrave;'	=> chr(232),  # small e, grave accent
'eth;'	=> chr(240),  # small eth, Icelandic
'euml;'	=> chr(235),  # small e, dieresis or umlaut mark
'iacute;'	=> chr(237),  # small i, acute accent
'icirc;'	=> chr(238),  # small i, circumflex accent
'igrave;'	=> chr(236),  # small i, grave accent
'iuml;'	=> chr(239),  # small i, dieresis or umlaut mark
'ntilde;'	=> chr(241),  # small n, tilde
'oacute;'	=> chr(243),  # small o, acute accent
'ocirc;'	=> chr(244),  # small o, circumflex accent
'ograve;'	=> chr(242),  # small o, grave accent
'oslash;'	=> chr(248),  # small o, slash
'otilde;'	=> chr(245),  # small o, tilde
'ouml;'	=> chr(246),  # small o, dieresis or umlaut mark
'szlig;'	=> chr(223),  # small sharp s, German (sz ligature)
'thorn;'	=> chr(254),  # small thorn, Icelandic
'uacute;'	=> chr(250),  # small u, acute accent
'ucirc;'	=> chr(251),  # small u, circumflex accent
'ugrave;'	=> chr(249),  # small u, grave accent
'uuml;'	=> chr(252),  # small u, dieresis or umlaut mark
'yacute;'	=> chr(253),  # small y, acute accent
'yuml;'	=> chr(255),  # small y, dieresis or umlaut mark

 # Some extra Latin 1 chars that are listed in the HTML3.2 draft (21-May-96)
'copy;'   => chr(169),  # copyright sign
'reg;'    => chr(174),  # registered sign
'nbsp;'   => chr(160),  # non breaking space

 # Additional ISO-8859/1 entities listed in rfc1866 (section 14)
'iexcl;'  => chr(161),
'cent;'   => chr(162),
'pound;'  => chr(163),
'curren;' => chr(164),
'yen;'    => chr(165),
'brvbar;' => chr(166),
'sect;'   => chr(167),
'uml;'    => chr(168),
'ordf;'   => chr(170),
'laquo;'  => chr(171),
'not;'   => chr(172),    # not is a keyword in perl
'shy;'    => chr(173),
'macr;'   => chr(175),
'deg;'    => chr(176),
'plusmn;' => chr(177),
'sup1;'   => chr(185),
'sup2;'   => chr(178),
'sup3;'   => chr(179),
'acute;'  => chr(180),
'micro;'  => chr(181),
'para;'   => chr(182),
'middot;' => chr(183),
'cedil;'  => chr(184),
'ordm;'   => chr(186),
'raquo;'  => chr(187),
'frac14;' => chr(188),
'frac12;' => chr(189),
'frac34;' => chr(190),
'iquest;' => chr(191),
'times;' => chr(215),    # times is a keyword in perl
'divide;' => chr(247),
  'OElig;'    => chr(338),
  'oelig;'    => chr(339),
  'Scaron;'   => chr(352),
  'scaron;'   => chr(353),
  'Yuml;'     => chr(376),
  'fnof;'     => chr(402),
  'circ;'     => chr(710),
  'tilde;'    => chr(732),
  'Alpha;'    => chr(913),
  'Beta;'     => chr(914),
  'Gamma;'    => chr(915),
  'Delta;'    => chr(916),
  'Epsilon;'  => chr(917),
  'Zeta;'     => chr(918),
  'Eta;'      => chr(919),
  'Theta;'    => chr(920),
  'Iota;'     => chr(921),
  'Kappa;'    => chr(922),
  'Lambda;'   => chr(923),
  'Mu;'       => chr(924),
  'Nu;'       => chr(925),
  'Xi;'       => chr(926),
  'Omicron;'  => chr(927),
  'Pi;'       => chr(928),
  'Rho;'      => chr(929),
  'Sigma;'    => chr(931),
  'Tau;'      => chr(932),
  'Upsilon;'  => chr(933),
  'Phi;'      => chr(934),
  'Chi;'      => chr(935),
  'Psi;'      => chr(936),
  'Omega;'    => chr(937),
  'alpha;'    => chr(945),
  'beta;'     => chr(946),
  'gamma;'    => chr(947),
  'delta;'    => chr(948),
  'epsilon;'  => chr(949),
  'zeta;'     => chr(950),
  'eta;'      => chr(951),
  'theta;'    => chr(952),
  'iota;'     => chr(953),
  'kappa;'    => chr(954),
  'lambda;'   => chr(955),
  'mu;'       => chr(956),
  'nu;'       => chr(957),
  'xi;'       => chr(958),
  'omicron;'  => chr(959),
  'pi;'       => chr(960),
  'rho;'      => chr(961),
  'sigmaf;'   => chr(962),
  'sigma;'    => chr(963),
  'tau;'      => chr(964),
  'upsilon;'  => chr(965),
  'phi;'      => chr(966),
  'chi;'      => chr(967),
  'psi;'      => chr(968),
  'omega;'    => chr(969),
  'thetasym;' => chr(977),
  'upsih;'    => chr(978),
  'piv;'      => chr(982),
  'ensp;'     => chr(8194),
  'emsp;'     => chr(8195),
  'thinsp;'   => chr(8201),
  'zwnj;'     => chr(8204),
  'zwj;'      => chr(8205),
  'lrm;'      => chr(8206),
  'rlm;'      => chr(8207),
  'ndash;'    => chr(8211),
  'mdash;'    => chr(8212),
  'lsquo;'    => chr(8216),
  'rsquo;'    => chr(8217),
  'sbquo;'    => chr(8218),
  'ldquo;'    => chr(8220),
  'rdquo;'    => chr(8221),
  'bdquo;'    => chr(8222),
  'dagger;'   => chr(8224),
  'Dagger;'   => chr(8225),
  'bull;'     => chr(8226),
  'hellip;'   => chr(8230),
  'permil;'   => chr(8240),
  'prime;'    => chr(8242),
  'Prime;'    => chr(8243),
  'lsaquo;'   => chr(8249),
  'rsaquo;'   => chr(8250),
  'oline;'    => chr(8254),
  'frasl;'    => chr(8260),
  'euro;'     => chr(8364),
  'image;'    => chr(8465),
  'weierp;'   => chr(8472),
  'real;'     => chr(8476),
  'trade;'    => chr(8482),
  'alefsym;'  => chr(8501),
  'larr;'     => chr(8592),
  'uarr;'     => chr(8593),
  'rarr;'     => chr(8594),
  'darr;'     => chr(8595),
  'harr;'     => chr(8596),
  'crarr;'    => chr(8629),
  'lArr;'     => chr(8656),
  'uArr;'     => chr(8657),
  'rArr;'     => chr(8658),
  'dArr;'     => chr(8659),
  'hArr;'     => chr(8660),
  'forall;'   => chr(8704),
  'part;'     => chr(8706),
  'exist;'    => chr(8707),
  'empty;'    => chr(8709),
  'nabla;'    => chr(8711),
  'isin;'     => chr(8712),
  'notin;'    => chr(8713),
  'ni;'       => chr(8715),
  'prod;'     => chr(8719),
  'sum;'      => chr(8721),
  'minus;'    => chr(8722),
  'lowast;'   => chr(8727),
  'radic;'    => chr(8730),
  'prop;'     => chr(8733),
  'infin;'    => chr(8734),
  'ang;'      => chr(8736),
  'and;'      => chr(8743),
  'or;'       => chr(8744),
  'cap;'      => chr(8745),
  'cup;'      => chr(8746),
  'int;'      => chr(8747),
  'there4;'   => chr(8756),
  'sim;'      => chr(8764),
  'cong;'     => chr(8773),
  'asymp;'    => chr(8776),
  'ne;'       => chr(8800),
  'equiv;'    => chr(8801),
  'le;'       => chr(8804),
  'ge;'       => chr(8805),
  'sub;'      => chr(8834),
  'sup;'      => chr(8835),
  'nsub;'     => chr(8836),
  'sube;'     => chr(8838),
  'supe;'     => chr(8839),
  'oplus;'    => chr(8853),
  'otimes;'   => chr(8855),
  'perp;'     => chr(8869),
  'sdot;'     => chr(8901),
  'lceil;'    => chr(8968),
  'rceil;'    => chr(8969),
  'lfloor;'   => chr(8970),
  'rfloor;'   => chr(8971),
  'lang;'     => chr(9001),
  'rang;'     => chr(9002),
  'loz;'      => chr(9674),
  'spades;'   => chr(9824),
  'clubs;'    => chr(9827),
  'hearts;'   => chr(9829),
  'diams;'    => chr(9830),
);

my %charmap = (
	338 => 'OE',
	339 => 'oe',
	352 => 'S',
	353 => 's',
	376 => 'Y',
	402 => 'f',
	710 => '^',
	732 => '~',
	913 => 'A',
	914 => 'B',
	915 => 'G',
	916 => 'D',
	917 => 'E',
	918 => 'Z',
	919 => 'Y',
	920 => 'TH',
	921 => 'I',
	922 => 'K',
	923 => 'L',
	924 => 'M',
	925 => 'N',
	926 => 'C',
	927 => 'O',
	928 => 'P',
	929 => 'R',
	931 => 'S',
	932 => 'T',
	933 => 'U',
	934 => 'F',
	935 => 'X',
	936 => 'Q',
	937 => 'W*',
	945 => 'a',
	946 => 'b',
	947 => 'g',
	948 => 'd',
	949 => 'e',
	950 => 'z',
	951 => 'y',
	952 => 'th',
	953 => 'i',
	954 => 'k',
	955 => 'l',
	956 => 'µ',
	957 => 'n',
	958 => 'c',
	959 => 'o',
	960 => 'p',
	961 => 'r',
	962 => '*s',
	963 => 's',
	964 => 't',
	965 => 'u',
	966 => 'f',
	967 => 'x',
	968 => 'q',
	969 => 'w',
	977 => 'theta',
	978 => 'upsi',
	982 => 'pi',
	8194 => '',
	8195 => '',
	8201 => '',
	8204 => '',
	8205 => '',
	8206 => '',
	8207 => '',
	8211 => '-',
	8212 => '--',
	8216 => '`',
	8217 => "'",
	8218 => "'",
	8220 => '"',
	8221 => '"',
	8222 => '"',
	8224 => '/-',
	8225 => '/=',
	8226 => 'o',
	8230 => '...',
	8240 => '0/00',
	8242 => "'",
	8243 => "''",
	8249 => '<',
	8250 => '>',
	8254 => "'-",
	8260 => '/',
	8364 => 'EUR', # '£',
	8465 => 'Im',
	8472 => 'P',
	8476 => 'Re',
	8482 => '(TM)',
	8501 => 'Aleph',
	8592 => '<-',
	8593 => '-^',
	8594 => '->',
	8595 => '-v',
	8596 => '<->',
	8629 => 'RET',
	8656 => '<=',
	8657 => '^^',
	8658 => '=>',
	8659 => 'vv',
	8660 => '<=>',
	8704 => 'FA',
	8706 => '\partial',
	8707 => 'TE',
	8709 => '{}',
	8711 => 'Nabla',
	8712 => '(-',
	8713 => '!(-',
	8715 => '-)',
	8719 => '\prod',
	8721 => '\sum',
	8722 => '-',
	8727 => '*',
	8730 => 'SQRT',
	8733 => '0(',
	8734 => 'infty',
	8736 => '-V',
	8743 => 'AND',
	8744 => 'OR',
	8745 => '(U',
	8746 => ')U',
	8747 => '\int',
	8756 => '.:',
	8764 => '?1',
	8773 => '?=',
	8776 => '~=',
	8800 => '!=',
	8801 => '=3',
	8804 => '<=',
	8805 => '>=',
	8834 => '(C',
	8835 => ')C',
	8836 => '!(C',
	8838 => '(_',
	8839 => ')_',
	8853 => '(+)',
	8855 => '(×)',
	8869 => '-T',
	8901 => '·',
	8968 => '<7',
	8969 => '>7',
	8970 => '7<',
	8971 => '7>',
	9001 => '</',
	9002 => '/>',
	9674 => 'LZ',
	9824 => 'cS',
	9827 => 'cC',
	9829 => 'cH-',
	9830 => 'cD-',
);

sub
init
{
	my ($self) = @_;

	foreach my $key (keys %entity2char) {
		my $str = $entity2char{$key};
		my $num = ord($str);
		my $newentity = "#$num;";
		my $cmapstr = $charmap{$num};
		if (defined($cmapstr)) {
			${$self->{entity2char}}{$newentity} = $cmapstr;
			${$self->{entity2char}}{$key} = $cmapstr;
			${$self->{charsubst}}{$str} = $cmapstr;
			next;
		}
		${$self->{entity2char}}{$newentity} = $str;
		${$self->{entity2char}}{$key} = $str;
	}
	#foreach my $key (keys %{$self->{entity2char}}) {
	#	printf STDERR "init e2c '%s' => '%s'\n",$key,${$self->{entity2char}}{$key};
	#}
}

sub
parse
{
	my ($self,$text) = @_;

	my $p = HTML::TokeParser->new( \$text );
	$p->xml_mode(1);
	my $cols = $ENV{'COLUMNS'};
	if (defined($cols)) {
		if ($cols<1) {
			$cols=80;
		}
	} else {
		$cols=80;
	}
	$cols -= 2;
			
	my $c = "";
	my $astate = 0;
	my $titlestate = 0;
	my $ignorestate = 0;
	my $i = 0;
	my $f = "";
	my @urls;
	my @imgs;
	while (my $t = $p->get_token()) {
		if ($t->[0] eq "T") { # Text
			my $tt = $t->[1];
			$tt =~ s/&nbsp;/ /g;
			if (!($tt =~ /^[[:space:]]*$/)) {
				$tt .= " ";
			}
			$tt =~ s/[[:space:]]{1,}/ /g;
			if ($astate) {
				$tt =~ s/[ ]+$//;
				if (length($tt)>0) {
					my $url = $urls[$#urls];
					$self->strip_compare($tt,$url);
					if ($tt =~ m/ / && ref_filter($url)) {
						$tt = "($tt)";
					}
				}
			}
			if ($titlestate) {
				$tt =~ s/[ ]+$//;
				if (length($tt)>0) {
					$tt = "TITLE: $tt\n\n";
				}
			}
			if ($ignorestate) {
				# not printable!
				next;
			}
			$c .= $tt;
			next;
		}
		if ($t->[0] eq "S") { # Start tag
			if ($t->[1] =~ m/^(a|link)$/i) {
				my $type = $self->getsub($t,"type");
				if (defined($type)) {
					if ($type eq "text/css") {
						next;
					}
				}
				my $href=$self->getsub($t,'href');
				if (defined($href)) {
					push @urls,$href;
					$astate++;
					next;
				}
				my $name=$self->getsub($t,'name');
				if (defined($name)) {
					push @urls,$name;
					$astate++;
					next;
				}
				my $rel=$self->getsub($t,'rel');
				if (defined($rel)) {
					next;
				}
				printf STDERR "parse:S:(a|link): Unhandled\n";
			}
			if ($t->[1] =~ m/^img$/i) {
				my $img = $self->getsub($t,'src');
				if (defined($img)) {
					if (ref_filter($img)) {
						push @imgs,$img;
						$c .= "%%img$#imgs%%";
					}
					next;
				}
			}
			if ($t->[1] =~ m/^(pre|code|abbr)$/i) {
				next;
			}
			if ($t->[1] =~ m/^title$/i) {
				$titlestate++;
				next;
			}
			if ($t->[1] =~ m/^(script|style|map)$/i) {
				$ignorestate++;
				next;
			}
			if ($t->[1] =~ /^(div|span|p|input|form)/i) {
				next;
			}
			if ($t->[1] =~ m/^br$/i) {
				$c .= "\n";
				next;
			}
			if ($t->[1] =~ m/^hr$/i) {
				$c .= "\n" . "-" x $cols . "\n \n";
				next;
			}
			if ($t->[1] =~ m/^(font|b|st1:.*|o:.*|html|head|body|meta|u)$/i) {
				next;
			}
			if ($t->[1] =~ m/^(table|tbody|tr|td|object|param|embed|iframe)$/i) {
				next;
			}
			if ($t->[1] =~ m/^(xml|small|ul|ol|li|em|strong|i|sup|center|h[0-9]|big|th)$/i) {
				next;
			}
			if ($t->[1] =~ m/^MailScanner/i) {
				next;
			}
			printf STDERR "parse: unhandled start tag: %s\n",
			    $t->[1];
		}
		if ($t->[0] eq "E") { # End tag
			if ($t->[1] =~ m/^(a|link)$/i) {
				my $type = $self->getsub($t,'type');
				if (defined($type)) {
					if ($type eq "text/css") {
						next;
					}
				}
				$c .= "%%url$#urls%%";
				$astate--;
				next;
			}
			if ($t->[1] =~ m/^img$/i) {
				next;
			}
			if ($t->[1] =~ m/^(pre|code|abbr)$/i) {
				next;
			}
			if ($t->[1] =~ /^(br|div|span|input|form)/i) {
				next;
			}
			if ($t->[1] =~ m/^p$/i) {
				$c .= "\n";
				next;
			}
			if ($t->[1] =~ m/^(font|b|st1:.*|o:.*|html|head|body|meta|u)$/i) {
				next;
			}
			if ($t->[1] =~ m/^(table|tbody|tr|td|object|param|embed|iframe)$/i) {
				next;
			}
			if ($t->[1] =~ m/^(xml|small|ul|ol|li|em|strong|i|sup|center|h[0-9]|big|th)$/i) {
				next;
			}
			if ($t->[1] =~ m/^title$/i) {
				$titlestate--;
				next;
			}
			if ($t->[1] =~ m/^(script|style|map)$/i) {
				$ignorestate--;
				next;
			}
			if ($t->[1] =~ m/^MailScanner/i) {
				next;
			}
			printf STDERR "parse: unhandled end tag: %s\n",
			    $t->[1];
		}
		if ($t->[0] eq "C") { # Comment
			next;
		}
		if ($t->[0] eq "D") { # Doctype
			next;
		}
		if (1) {
		printf STDERR "{";
		$i=0;
		foreach my $subt (@{$t}) {
			printf STDERR " %d=%s",$i++,$subt;
			if (ref $subt eq "HASH") {
				printf STDERR "{";
				foreach my $key (keys %{$subt}) {
					printf STDERR "%s=>%s,",$key,${$subt}{$key};
				}
				printf STDERR "}";
			}
			if (ref $subt eq "ARRAY") {
				printf STDERR "[";
				foreach my $key (@{$subt}) {
					printf STDERR "%s,",$key;
				}
				printf STDERR "]";
			}
		}
		printf STDERR " }\n";
		}
	}
	my $cache;
	my $footnotefmt;
	if (@urls) {
		$i = 0;
		@{$cache} = ();
		foreach my $u (@urls) {
			if ($self->ref_filter($u)) {
				$self->getoffset($u,$cache);
			}
		}
		$f .= "\nReferences:\n" if $#{$cache} > -1;
		$footnotefmt = sprintf " %%%dx. %%s\n",$self->powerofsixteen($#{$cache});
		@{$cache} = ();
		foreach my $u (@urls) {
			my $ucount = $#{$cache};
			my $urlstr = "";
			my $offset;
			if ($self->ref_filter($u)) {
				$offset = $self->getoffset($u,$cache);
				$urlstr = sprintf "[%x] ",$offset;
			}
			$c =~ s/%%url${i}%%/$urlstr/g;
			if ($ucount < $#{$cache} && length($urlstr) > 0) {
				$f .= sprintf "${footnotefmt}",$offset,$u;
			}
			$i++;
		}
	}
	if (@imgs) {
		@{$cache} = ();
		foreach my $img (@imgs) {
			if ($self->ref_filter($img)) {
				$self->getoffset($img,$cache);
			}
		}
		$f .= "\nImages:\n" if $#{$cache} > -1;
		$footnotefmt = sprintf " %%%dx. %%s\n",$self->powerofsixteen($#{$cache});
		$i = 0;
		@{$cache} = ();
		foreach my $img (@imgs) {
			my $icount = $#{$cache};
			my $offset;
			my $imgstr = "";
			if ($self->ref_filter($img)) {
				$offset = $self->getoffset($img,$cache);
				$imgstr = sprintf "{%x} ",$offset;
			}
			$c =~ s/%%img${i}%%/$imgstr/g;
			if ($icount < $#{$cache} && length($imgstr) > 0) {
				$f .= sprintf ${footnotefmt},${offset},$img;
			}
			$i++;
		}
	}
	
	@{$cache} = ();
	$text = $c;
	$text =~ s/[ \t]+/ /g;
	$text =~ s/({[0-9]+}|\[[0-9]+\])[[:space:]][[:space:]]*({[0-9]+}|\[[0-9]+\])/$1 $2/g;
	$text =~ s/[[:space:]][[:space:]]*(\[[0-9]+\])/$1/g;
	$text =~ s/^[ \t]+//g;
	$text =~ s/^\s+$//g;
	#$text =~ s/\n\n/\n/mg;

	# clean [mailto:foo@example.com] uglyness to <foo@example.com>
	$text =~ s/\[mailto:([^\]]+)\]/<$1>/g;

	#my $cset = MIME::Charset->new("ISO-8859-1");
	#my $cset = MIME::Charset->new("US-ASCII");
	#if (Encode::is_utf8($text)) {
	#	$text = Encode::decode('utf8',$text);
	#	$text = Encode::decode('ascii',$text);
	#}
	#my ($output, $charset, $encoding) = $cset->body_encode($text,
	#		Charset => $self->{cset} );
	my $output = $text;

	# Interesting things listed at:
	# http://www.htmlcodetutorial.com/characterentities_famsupp_69.html
	#$output = encode('utf-8',$output);
	while (my($entity,$char)=each(%{$self->{entity2char}})) {
		$output =~ s/&$entity/$char/g;
		#if ($entity =~ m/gt/) {
		#	printf STDERR "{entity='%s',char='%s'}\n",$entity,$char;
		#}
	}
	#$output = HTML::Entities::decode($output, \%{$self->{entity2char}});
	#my $text_string = decode('UTF-8', $output);
	#my $output = encode('us-ascii', $text_string);
	my $utfdebug = 0;
	foreach my $debugline ((
		#'odd to complain of a sense',
		#'bid to compete with Apple',
	)) {
		if ($output =~ /$debugline/) {
			$utfdebug = 1;
		}
	}
	if ($utfdebug) {
		printf STDERR "\noutput: before(plain vs utf-8) vs after(plain vs utf8):\n'%s'\n'%s'\n",$output,encode('utf-8',$output);
	}

	$output = FDC::CleanText::recode(\$output);
	if ($utfdebug) {
		printf STDERR "'%s'\n'%s'\n",$output,encode('utf-8',$output);
	}

	$output =~ s/[[:space:]]$//g;
	$output =~ s/^"[ \t]+/"/g;

	my $out="";
	my $lm=0;
	my $rm=79;
	my $finalcr=0;
	if ($self->{wordwrap}) {
	if ($output =~ m/\n/s) {
		$finalcr=1;
	}
	foreach my $line (split(/\n/,$output)) {
		my $pos=0;
		if (length($line)<1) {
			next;
		}
		foreach my $word (split(/[ \t]/,$line)) {
			if (length($word)<1) {
				next;
			}
			my $wl = length($word)+1;
			if (($pos+$wl) > $rm) {
				$out .= "\n";
				$pos  = 0;
			}
			$out .= $word." ";
			$pos += $wl;
		}
		if ($finalcr) {
			$out.="\n";
		}
	}
	} else {
		$out = $output;
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
sub
powerofsixteen
{
	my ($self,$num) = @_;
	my $pow = 1;
	while ($num > 16) {
		$num = $num/16;
		$pow++;
	}
	return $pow;
}
sub
ref_filter
{
	my ($self,$reference) = @_;
	if (!defined($reference)) {
		return 0;
	}
	$reference = lc($reference);
	foreach my $filter (("doubleclick.net")) {
		if ($reference =~ m/(http|https|ftp):\/\/[^\/]+$filter\//) {
			return 0;
		}
	}
	if (! ($reference =~ m/^[a-z]+:/)) {
		return 0;
	}
	if ($reference =~ m/(javascript|cid):/) {
		return 0;
	}
	foreach my $filter (@{$self->{filters}}) {
		if ($reference =~ m/${filter}/) {
			return 0;
		}
	}
	return 1;
}

sub
strip_compare
{
	my ($self,$t1,$t2) = @_;

	if (!defined($t1) && defined($t2)) {
		return 1;
	}
	if (!defined($t2) && defined($t1)) {
		return 1;
	}
	if (!defined($t2) && !defined($t1)) {
		return 1;
	}
	$t1 = lc($t1);
	$t2 = lc($t2);
	$t1 =~ s/^\s*(.*)\s*$/$1/;
	$t1 =~ s/^(https|http|ftp|mailto)://;
	$t1 =~ s/^\/\///;
	$t1 =~ s/\/$//;
	$t2 =~ s/^\s*(.*)\s*$/$1/;
	$t2 =~ s/^(https|http|ftp|mailto)://;
	$t2 =~ s/^\/\///;
	$t2 =~ s/\/$//;
	if ($t1 eq $t2) {
		push @{$self->{filters}},$t1;
		return 0;
	}
	#printf STDERR "\$t1(%s)!=\$t2(%s)\n",$t1,$t2;
	return 1;
}
sub
getsub
{
	my ($self,$t,$var) = @_;
	if (!defined($t)) {
		printf STDERR "getsub: \$t = undef\n";
		return "";
	}
	if (!defined($var)) {
		printf STDERR "getsub: \$var = undef\n";
		return "";
	}
	if (length($var) < 1) {
		printf STDERR "getsub: \$var is empty\n";
		return "";
	}
	my $val;
	eval {
		my $lc = lc($var);
		if (ref($t->[2]) eq "HASH") {
			$val = ${$t->[2]}{$lc};
		} else {
			return "";
		}
		if (defined($val)) {
			return $val;
		}
		$val = ${$t->[2]}{uc("$var")};
	};
	if ($@) {
		printf STDERR "getsub: failed to get \$var(%s) from \$t: $@\n",
				$var;
		return "";
	}
	return $val;
}

1;
