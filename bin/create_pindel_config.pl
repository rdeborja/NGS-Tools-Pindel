#!/usr/bin/perl

### create_pindel_config.pl ##############################################################################
# Create a Pindel config file.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-04-28      rdeborja            initial development

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use NGS::Tools::Picard;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
	file => undef,
	bam => undef,
	sample => undef,
	output => 'config'
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
        "file|f=s",
        "bam|b=s",
        "sample|s=s",
        "output|c:s"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument \n";
            pod2usage(128);
            }
        }

    my $picard = NGS::Tools::Picard->new();
    my $insert_size_stats = $picard->get_insert_size_summary_statistics(
    	file => $opts{'file'}
    	);
    
    my $output_line = join("\t",
    	$opts{'bam'},
    	int($insert_size_stats->{'MEAN_INSERT_SIZE'}),
    	$opts{'sample'}
    	);
    open(my $ofh, '>', $opts{'output'});
    print {$ofh} $output_line, "\n";
    close($ofh);

    return 0;
    }


__END__


=head1 NAME

create_pindel_config.pl

=head1 SYNOPSIS

B<create_pindel_config.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --file          Picard insert size metrics file
    --bam           full path to BAM file to process
    --sample        name of sample to be processed
    --output        config data is written to this file

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--file>

Picard insert size metrics file.

=item B<--bam>

Full path to the BAM file to be run through Pindel.

=item B<--sample>

Name of sample to be processed, this must start with an alpha character.

=item B<--output>

Data is written to this file.

=back

=head1 DESCRIPTION

B<create_pindel_config.pl> Create a Pindel config file.

=head1 EXAMPLE

create_pindel_config.pl --file test.picard.insertsizemetrics.txt --bam /tmp/file.bam -- sample sample1

=head1 AUTHOR

Richard de Borja -- Molecular Genetics

The Hospital for Sick Children

=head1 SEE ALSO

=cut

