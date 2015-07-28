#!/usr/bin/perl

### convert_pindel_to_table.pl ####################################################################
# Convert Pindel output (currently supports small insertion and deletion files).


### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-03-13      rdeborja            Initial development.

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use NGS::Tools::Pindel;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
	output => 'pindel.tab',
	dir => '.',
	sample => undef,
    );

### MAIN CALLER ###################################################################################
my $result = main();
exit($result);

### FUNCTIONS #####################################################################################

### main ##########################################################################################
# Description:
#   Main subroutine for program
# Input Variables:
#   %opts = command line arguments
# Output Variables:
#   N/A

sub main {
    # get the command line arguments
    GetOptions(
        \%opts,
        "help|?",
        "man",
        "sample|s=s",
        "output|o:s",
        "dir|d:s"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument \n";
            pod2usage(128);
            }
        }

    my $pindel = NGS::Tools::Pindel->new();

    # get the small insertion (_SI) and deletion (_D) files from the
    # directory in the provided arguments
    opendir(my $pindel_dh, $opts{'dir'});
    my @files = readdir($pindel_dh);
    my @pindel_files;
    foreach my $file (@files) {
        next unless($file =~ m/_D$/ | $file =~ m/_SI$/);
        next unless($file =~ m/$opts{'sample'}/);
        push(@pindel_files, join('/', $opts{'dir'}, $file));
        }
    $pindel->create_pindel_tabular_file(
        files => \@pindel_files,
        output => $opts{'output'},
        sample => $opts{'sample'}
        );


    return 0;
    }


__END__


=head1 NAME

convert_pindel_to_table.pl

=head1 SYNOPSIS

B<convert_pindel_to_table.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --output        output file name (required)
    --dir           directory containing all the Pindel output files (required)
    --sample        sample name  to be processed (required)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--sample>

Name of sample to be processed

=back

=head1 DESCRIPTION

B<convert_pindel_to_table.pl> Convert Pindel output (currently supports small insertion and deletion files).


=head1 EXAMPLE

convert_pindel_to_table.pl

=head1 AUTHOR

Richard de Borja -- Molecular Genetics

The Hospital for Sick Children

=head1 SEE ALSO

=cut

