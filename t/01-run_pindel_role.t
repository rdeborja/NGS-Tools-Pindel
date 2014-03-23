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

# setup a few variable
my $config = 'bam_config.txt';
my $fasta = 'hg19.fa';
my $chromosome = 'chr22';
my $pindel_tool = '/usr/local/bin/pindel';
my $threads = 8;
my $output = 'pindel.output';

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::Pindel::Role::Pipeline');

# instantiate the test class based on the given role
my $pindel;
lives_ok
	{
		$pindel = $test_class->new();
		}
	'Class instantiated';

my $pindel_run = $pindel->run_pindel(
	fasta => $fasta,
	bam_config => $config,
	chromosome => $chromosome,
	threads => $threads,
	pindel => $pindel_tool,
	output => $output
	);

my $expected_cmd = join(' ',
	'/usr/local/bin/pindel',
	'-f hg19.fa',
	'-i bam_config.txt',
	'-o pindel.output',
	'-c chr22',
	'-T 8'
	);
is($pindel_run->{'cmd'}, $expected_cmd, "Pindel command matches expected.");
