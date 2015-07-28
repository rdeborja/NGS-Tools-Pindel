package NGS::Tools::Pindel::Role::Postprocessing;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Slurp;

=head1 NAME

NGS::Tools::Pindel::Role::PindelPostprocessing

=head1 SYNOPSIS

A Perl Moose role for postprocessing Pindel tabular output.

=head1 ATTRIBUTES AND DELEGATES

=cut

our %pindel_tab = (
    PINDEL_ID => 0,
    SAMPLE_NAME => 1,
    VARIANT_TYPE => 2,
    VARIANT_LENGTH => 3,
    CHR => 4, 
    START => 5, 
    END => 6,
    RANGE_START => 7,
    RANGE_END => 8,
    S1_SCORE => 9,
    BASES => 10, 
    SUM_MS => 11,
    SV_SUPPORT_READS => 12,
    SV_UNIQUE_SUPPORT_READS => 13
    );

=head1 SUBROUTINES/METHODS

=head2 $obj->call_pindel_somatic()

After Pindel has been used on a tumour and its matched normal and the output files
have been converted to the tabular format, remove any germline indels from the
tumour.

=head3 Arguments:

=over 2

=item * tumour: Pindel tabular file for the tumour

=item * normal: Pindel tabular file for the matched normal

=item * sample: name of sample being processed, this will be prepended to the output filename if no output is provided.

=item * output: name of output file

=back

=cut

sub call_pindel_somatic {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        tumour => {
            isa         => 'Str',
            required    => 1
            },
        normal => {
            isa         => 'Str',
            required    => 1
            },
        sample => {
            isa         => 'Str',
            required    => 1,
            },
        output => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            },
        filter => {
            isa         => 'Str',
            required    => 0,
            default     => 'FALSE'
            }
        );

    my $output;
    if ('' eq $args{'output'}) {
        $output = join('.',
            $args{'sample'},
            'pindel',
            'somatic',
            'tab'
            );
        }
    else {
        $output = $args{'output'};
        }
    open(my $output_fh, '>', $output);

    # build a hash for the normal file with keys as varianttype_chr_start_end_bases
    my %normal_pindel;
    open(my $normal_fh, '<', $args{'normal'});
    while(my $line = <$normal_fh>) {
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        # skip the header line
        next if ($line =~ m/^PINDEL_ID/);
        my @input_line = split(/\t/, $line);
        my $key = join('_',
            $input_line[$pindel_tab{'VARIANT_TYPE'}],
            $input_line[$pindel_tab{'CHR'}],
            $input_line[$pindel_tab{'START'}],
            $input_line[$pindel_tab{'END'}],
            $input_line[$pindel_tab{'BASES'}]
            );
        $normal_pindel{$key} = '';
        }
    close($normal_fh);

    # open the tumour file and build the same type of key (i.e. varianttype_chr_start_end_bases)
    # and compare this key to the a key in the normal file, if the key exists,
    # then skip it as this is a germline mutation.  If not then it's a somatic mutation
    # and include it in the output file
    open(my $tumour_fh, '<', $args{'tumour'});
    while(my $line = <$tumour_fh>) {
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        # skip the header line
        if ($line =~ m/^PINDEL_ID/) {
            print {$output_fh} "$line\n";
            next;
            }
        my @input_line = split(/\t/, $line);

        # if filter is set to TRUE, run the filter method on the data
        if ($args{'filter'} eq 'TRUE') {
            next if ('reject' eq $self->filter_indel(indel => \@input_line));
            }
        my $key = join('_',
            $input_line[$pindel_tab{'VARIANT_TYPE'}],
            $input_line[$pindel_tab{'CHR'}],
            $input_line[$pindel_tab{'START'}],
            $input_line[$pindel_tab{'END'}],
            $input_line[$pindel_tab{'BASES'}]
            );

        if (!exists($normal_pindel{$key})) {
            print {$output_fh} "$line\n";
            }
        }
    close($tumour_fh);
    close($output_fh);
    my %return_values = (
        output => $output
        );
    
    return(\%return_values);
    }


=head2 $obj->filter_indel()

Filter a Pindel indel call.

=head3 Arguments:

=over 2

=item * indel: Pindel call in tabular format

=item * tissue: Normal or tumour tissue

=back

=cut

sub filter_indel {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        indel => {
            isa         => 'ArrayRef',
            required    => 1
            },
        filter_length => {
            isa         => 'Int',
            required    => 0,
            default     => 1
            },
        filter_sum_ms => {
            isa         => 'Int',
            required    => 0,
            default     => 250
            }
        );
    
    my $indel = $args{'indel'};
    my $filter_status;
    if (($indel->[$pindel_tab{'VARIANT_LENGTH'}] <= $args{'filter_length'}) && ($indel->[$pindel_tab{'SUM_MS'}] >= $args{'filter_sum_ms'})) {
        $filter_status = 'pass'
        }
    else {
        $filter_status = 'reject';
        }
    return($filter_status);
    }

=head1 AUTHOR

Richard de Borja, C<< <richard.deborja at sickkids.ca> >>

=head1 ACKNOWLEDGEMENT

Dr. Adam Shlien, PI -- The Hospital for Sick Children

Dr. Roland Arnold -- The Hospital for Sick Children

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-test at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=test-test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc NGS::Tools::Pindel::Role::PindelPostprocessing

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=test-test>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/test-test>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/test-test>

=item * Search CPAN

L<http://search.cpan.org/dist/test-test/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Richard de Borja.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

no Moose::Role;

1; # End of NGS::Tools::Pindel::Role::PindelPostprocessing
