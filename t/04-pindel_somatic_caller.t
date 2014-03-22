use Test::More tests => 2;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;
use File::Slurp;

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
	{ class_basename => 'Test' }
	);

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::Pindel::Role::Postprocessing');

# instantiate the test class based on the given role
my $pindel;
lives_ok
	{
		$pindel = $test_class->new();
		}
	'Class instantiated';

my $tempdir = File::Temp::tempdir(
	CLEANUP => 1,
	DIR => '.'
	);
my (undef, $tempfile) = File::Temp::tempfile(
	UNLINK => 1,
	DIR => $tempdir
	);
my (undef, $tempout) = File::Temp::tempfile(
	UNLINK => 1,
	DIR => $tempdir
	);
my $tumour = "$Bin/example/D1119.pindel.tab";
my $normal = "$Bin/example/BT2012029.pindel.tab";
my $sample = 'D1119';
my $somatic = $pindel->call_pindel_somatic(
	tumour => $tumour,
	normal => $normal,
	sample => $sample,
	output => $tempout
	);
my $expected_file = "$Bin/example/04-pindel_somatic_expected.tab";
compare_ok(
	$somatic->{'output'},
	$expected_file,
	'Somatic output matches expected file'
	);
