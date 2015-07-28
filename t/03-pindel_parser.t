use Test::More tests => 2;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
	{ class_basename => 'Test' }
	);

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::Pindel::Role::PindelParser');

# instantiate the test class based on the given role
my $pindel;
lives_ok
	{
		$pindel = $test_class->new();
		}
	'Class instantiated';

# create a temporary output file
my $tempdir = File::Temp::tempdir(CLEANUP => 0, DIR => '.');
my (undef, $tempfile) = File::Temp::tempfile(UNLINK => 0, DIR => $tempdir);
my $sample = 'test-sample';
my @files = ("$Bin/example/example_D", "$Bin/example/example_SI");
$pindel->create_pindel_tabular_file(
	files => \@files,
	output => $tempfile,
	sample => $sample
	);

# compare output files
my $expected_file = "$Bin/example/03-expected_tab_file.txt";
compare_ok(
	$tempfile,
	$expected_file,
	'Output matches expected output file'
	);
