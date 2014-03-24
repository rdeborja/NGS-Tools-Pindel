#!/usr/bin/perl

### call_pindel_filtered_somatics.pl ##############################################################
# Filter and call somatics on the Pindel tabular data.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-03-24      rdeborja            initial development

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
	tumour => undef,
	normal => undef,
	sample => undef
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
        "tumour|t=s",
        "normal|n=s",
        "sample|s=s"
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
    my $somatic = $pindel->call_pindel_somatic(
    	tumour => $opts{'tumour'},
    	normal => $opts{'normal'},
    	sample => $opts{'sample'}
    	);

    return 0;
    }


__END__


=head1 NAME

call_pindel_filtered_somatics.pl

=head1 SYNOPSIS

B<call_pindel_filtered_somatics.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --tumour        tumour pindel tabular file
    --normal        normal pindel tabular file
    --sample        name of sample being processed

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--tumour>

Path and name of Pindel tabular file for tumour (required).

=item B<--normal>

Path and name of Pindel tabular file for normal (required).

=item B<--sample>

Name of sample being processed (required).

=back

=head1 DESCRIPTION

B<call_pindel_filtered_somatics.pl> Filter and call somatics on the Pindel tabular data.

=head1 EXAMPLE

call_pindel_filtered_somatics.pl --tumour tumour.pindel.tab --normal normal.pindel.tab --sample D1119

=head1 AUTHOR

Richard de Borja -- Molecular Genetics

The Hospital for Sick Children

=head1 SEE ALSO

=cut

