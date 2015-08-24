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
my $test_class = $test_class_factory->class_for('NGS::Tools::Pindel::Role::Postprocessing');

# instantiate the test class based on the given role
my $pindel;
my $pindel_prefix = "$Bin/example/example";
lives_ok
    {
        $pindel = $test_class->new();
        }
    'Class instantiated';

my $pindel_vcf = $pindel->convert_pindel_to_vcf(
    pindel => $pindel_prefix,
    output => 'test_output'
    );

my $expected_cmd = join(' ',
    'pindel2vcf',
    "-P $Bin/example/example",
    '-r /hpf/largeprojects/adam/local/reference/homosapiens/ucsc/hs37d5/fasta/hs37d5.fa',
    '-R hs37d5',
    '-d 2011-07-11',
    '--vcf test_output.vcf'
    );
is($expected_cmd, $pindel_vcf->{'cmd'}, 'Command matches expected');
