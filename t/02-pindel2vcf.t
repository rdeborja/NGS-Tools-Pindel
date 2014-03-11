use Test::More tests => 3;
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
my $test_class = $test_class_factory->class_for('NGS::Tools::Pindel::Role');

# instantiate the test class based on the given role
my $pindel;
lives_ok
	{
		$pindel = $test_class->new();
		}
	'Class instantiated';

my $pindel_short_insertion = 'file_SI';
my $pindel_deletion = 'file_D';
my $pindel_run = $pindel->convert_pindel_output_to_vcf(
	pindel_file => $pindel_short_insertion
	);
my $expected_command = join(' ',
	'pindel2vcf',
	'--pindel_output', 'file_SI',
	'--reference', '/hpf/largeprojects/adam/ref_data/homosapiens/ucsc/GRCh37/fasta/genome.fa',
	'--reference_name', 'GRCh37',
	'--reference_date', '200902'
	);
is ($pindel_run->{'cmd'}, $expected_command, 'Pindel short insertion command matches expected');
$pindel_run = $pindel->convert_pindel_output_to_vcf(
	pindel_file => $pindel_deletion
	);
my $expected_command = join(' ',
	'pindel2vcf',
	'--pindel_output', 'file_D',
	'--reference', '/hpf/largeprojects/adam/ref_data/homosapiens/ucsc/GRCh37/fasta/genome.fa',
	'--reference_name', 'GRCh37',
	'--reference_date', '200902'
	);
is($pindel_run->{'cmd'}, $expected_command, 'Pindel deletion command matches expected');
