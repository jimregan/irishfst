#!/usr/bin/perl

use warnings;
use strict;
use utf8;

# This crappy script does the replacement
# The output is then sorted - unix sort is best
# The second script generates XML.

my %ind = (
	'1P' => 'p3',
	'2P' => 'p2',
	'3P' => 'p1',
#	'?' => '',
	'Adj' => 'adj',
	'Adv' => 'adv',
	'Art' => 'det.def',
	'Auto' => 'aut',
#	'Bar' => '',
	'Base' => '',
	'CM' => '',
	'CU' => '',
	'CC' => '',
	'Voc' => 'voc',
	'Dat' => 'dat',
	'Guess' => '',
	'English' => '',
	'Foreign' => '',
	'Subst' => 'n',
	'Vow' => '',
	'Ref' => 'ref',
	'Rel' => 'rel',
	'Pers' => 'pers',
	'PresImp' => 'imp',
	'PresInd' => 'pri',
	'PresSubj' => 'prs',
	'PastInd' => 'pii', # ifi?
	'PastSubj' => 'pis', # ifs?
	'PastImp' => 'pih',
	'Verbal' => 'vblex',
	'Pp' => 'pp',
	'Filler' => '',
	'NotSlen' => '', # default
	'Slender' => 'slender',
	'Det' => 'det',
	'Ord' => 'ord',
	'Masc' => 'm',
	'Fem' => 'f',
	'Noun' => 'n',
	'Num' => 'num',
	'Prep' => 'pr',
	'Pron' => 'prn',
	'VF' => '',
	'Verb' => 'vblex',
	'VI' => '',
	'VT' => '',
	'VTI' => '',
	'VD' => '',
	'Art' => 'det.def',
	'Sg' => 'sg',
	'Pl' => 'pl',
	'Comp' => 'comp',
	'Def' => 'def',
	'FutInd' => 'fti',
	'Gen' => 'gen',
	'Gn' => '',
	'Idf' => 'ind',
	'Imp' => 'imp',
	'Imper' => 'imp',
	'Com' => 'nom',
	'hPref' => 'hpref',
	'Emph' => 'emph',
	'Qty' => 'qnt',
	'Q' => 'itg',
	'NegQ' => 'itg.neg',
	'Itj' => 'ij',
	'Ecl' => 'ecl',
	'Dem' => 'dem',
	'Cop' => 'cop',
	'Neg' => 'neg',
	'Len' => 'len',
	'Subj' => 'subj',
	'Pres' => 'pres',
	'Temp' => 'temp',
	'DefArt' => 'defart',
	'Cond' => 'cni',
	'Strong' => 'strong',
	'Weak' => '',
	'Dep' => 'dep',
	'Its' => '',
	'Simp' => '',
	'Cmc' => 'ij',
	'Card' => '',
	'Cmpd' => '',
	'Part' => 'part',
	'Poss' => 'pos',
	'Loc' => '',
	'Dir' => '',
	'Sbj' => 'subj',
	'Suf' => 'suf', # rel?
	'CmpdNoGen' => '',
	'Direct' => 'dir',
	'Indirect' => 'ind',
	'Conj' => 'cnjadv',
	'Var' => '',
	'Inf' => 'inf',
	'Deg' => 'deg',
	'Pro' => 'pro',
	'Obj' => 'obj',
	'RelInd' => 'rel.ind',
	'Pat' => 'pat',
	'Sup' => 'sup',
	'Ad' => 'adv',
	'Nm' => 'num',
	'Cmpl' => 'cmpl',
	'Op' => 'op',
	'Cp' => 'cop',
#	'Abr' => 'abr',

	# Fake tags, for multitag substitutions
	'PropNoun' => 'np',
	'CnjCoo' => 'cnjcoo',
	'CnjSub' => 'cnjsub',
	'VPart' => 'vpart',
	'Past' => 'past',
);

my %toconv = ();
my $lr = 0;

sub tagify {
	my $tag = shift;

	if (exists $ind{$tag}) {
		return "<$ind{$tag}>";
	} elsif ($tag ne '') {
		return "+$tag";
		$toconv{$tag} = 1;
	} else {
		return "";
	}
}

while (<>) {
	chomp;
	next if (/^:/);
	next if (/\+Filler/);
	next if (/\+DeNom/);
	next if (/\+Event/);
	next if (/\+XMLTag/);
	next if (/\+NStem/);
	next if (/\+Xxx/);
	next if (/\+Punct/);
	next if (/\+Abr/);
	my $reason = "";
	if (/\+(C[MCU])/) {
		$reason = $1;
		$lr = 1;
	}
	if (/\+Var/) {
		$lr = 1;
	}
	if (/\+Typo/) {
		$lr = 1;
		next;
	}
	s/\+Part\+Vb/+VPart/;
	s/\+Com\+Sg/+Sg+Com/;
	s/\+Com\+Pl/+Pl+Com/;
	s/\+Gen\+Sg/+Sg+Gen/;
	s/\+Gen\+Pl/+Pl+Gen/;
	s/\+Voc\+Sg/+Sg+Voc/;
	s/\+Voc\+Pl/+Pl+Voc/;
	s/\+Verbal\+Noun/+Verb+Subst/;
	s/\+Verbal\+Adj/+Verb+Pp/;
	s/\+Conj\+Subord/\+CnjSub/;
	s/\+Conj\+Coord/\+CnjCoo/;
	s/\+Prop\+Noun/\+PropNoun/;
	s/\+Fem\+Com\+Pl\+Strong/+Fem+Strong+Pl+Com/;
	s/\+Masc\+Gen\+Weak\+Pl/+Masc+Pl+Gen/;
	s/\+Masc\+Gen\+Strong\+Pl/+Strong+Masc+Pl+Gen/;
	s/\+Fem\+Gen\+Weak\+Pl/+Fem+Pl+Gen/;
	s/\+Fem\+Gen\+Strong\+Pl/+Strong+Fem+Pl+Gen/;
	my ($an, $sf) = split /:/;
	my ($lm, @tags) = split /\+/, $an;
	my @ptags = map { local $_ = $_; tagify $_ } @tags;
	my @otags = grep (!/<>/, @ptags);

#	print "LEM: $lm\nSFC: $sf\nTAGS: @otags\n";
#	print "@otags\n";
	my $tmp = join("", @otags);
	$tmp =~ s/^<//;
	$tmp =~ s/>$//;
	my @ftags = split/></, $tmp;
	my $first = shift @ftags;
	if ($tmp !~ /></) {
		$first = $tmp;
	}
	print "$lm ; $sf ; " . join(".", @ftags) . " ; $first";
	print "; # $reason" if ($lr == 1);
	print "\n";
	$lr = 0;
}
