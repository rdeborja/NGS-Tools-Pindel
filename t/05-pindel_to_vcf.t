use Test::More tests => 1;
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
lives_ok
    {
        $pindel = $test_class->new();
        }
    'Class instantiated';

my $pindel_vcf = $pindel->convert_pindel_to_vcf(
    pindel => 'test',
    output => 'test_output'
    );
print Dumper($pindel_vcf);