package NGS::Tools::Pindel::Role::Preprocessing;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Basename;

=head1 NAME

NGS::Tools::Pindel::Role::Preprocessing

=head1 SYNOPSIS

Preprocess data in preparation for the Pindel pipeline.

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->create_pindel_bam_config_file()

Create the Pindel BAM config file by parsing the Picard
CollectInsertSizeMetrics.jar output and outputting a Pindel
compatible config file.  The BAM config file is a tab-separated
text file containing:

* Full path to BAM file
* Mean insert size
* sample name

=head3 Arguments:

=over 2

=item * bam: name of input BAM file (required)

=item * insertsize: Full path to the insert size metrics file (required)

=item * output: name of output file

=item * sample_name: name of sample being processed (required)

=back

=cut

sub create_pindel_bam_config_file {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		bam => {
			isa			=> 'Str',
			required	=> 1
			},
		insertsize => {
			isa			=> 'Int',
			required    => 1
			},
		output => {
			isa			=> 'Str',
			required	=> 0,
			default		=> ''
			},
		sample_name => {
			isa			=> 'Str',
			required	=> 1
			}
		);

	my $output_file;
	if ($args{'output'} eq '') {
		$output_file = join('.',
			File::Basename::basename($args{'bam'}, qw(.bam)),
			'pindel',
			'config'
			);
		}
	else {
		$output_file = $args{'output'}
		}

	my %output_pindel_config = (
		file		=> $args{'bam'},
		insertsize	=> $args{'insertsize'},
		sample		=> $args{'sample_name'}
		);
	open(my $output_fh, '>', $output_file);
	print {$output_fh} join("\t",
		$output_pindel_config{'file'},
		$output_pindel_config{'insertsize'},
		$output_pindel_config{'sample'}
		), "\n";
	close($output_fh);

	my %return_values = (
		output => $output_file
		);

	return(\%return_values);
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

    perldoc NGS::Tools::Pindel::Role::Preprocessing

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

Dr. Adam Shlien, PI - The Hospital for Sick Children

Dr. Roland Arnold - The Hospital for Sick Children

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

1; # End of NGS::Tools::Pindel::Role::Preprocessing
