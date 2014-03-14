package NGS::Tools::Pindel::Role;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;

=head1 NAME

NGS::Tools::Pindel::Role

=head1 SYNOPSIS

A Perl Moose Role to wrap Pindel

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->run_pindel()

Run the Pindel INDEL caller.

=head3 Arguments:

=over 2

=item * fasta: Reference file in FASTA format.

=item * bam_config: BAM configuration file, contains BAM file, expected insert size and label

=item * chromosome: Chromsome/contig name in FASTA reference to process (default: ALL)

=item * threads: Number of threads to use (default: 4)

=item * pindel: Full path to the Pindel application (required)

=item * output: Prefix to prepend to Pindel output (default: pindel.output)

=back

=cut

sub run_pindel {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		fasta => {
			isa         => 'Str',
			required    => 0,
			default     => ''
			},
		bam_config => {
			isa			=> 'Str',
			required	=> 0,
			default		=> ''
			},
		chromosome => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'ALL'
			},
		threads => {
			isa			=> 'Int',
			required	=> 0,
			default		=> 4
			},
		pindel => {
			isa			=> 'Str',
			required	=> 1
			},
		output => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'pindel.output'
			}
		);

	my $program = $args{'pindel'};

	my $options = join(' ',
		'-f', $args{'fasta'},
		'-i', $args{'bam_config'},
		'-o', $args{'output'},
		'-c', $args{'chromosome'},
		'-T', $args{'threads'} 
		);

	my $cmd = join(' ',
		$program,
		$options
		);

	my %return_values = (
		cmd => $cmd
		);

	return(\%return_values);
	}

=head2 $obj->convert_pindel_output_to_vcf()

Convert the output from a Pindel run to a VCF file.

=head3 Arguments:

=over 2

=item * pindel_file: Name of Pindel file to process (required)

=item * vcf: Name of output VCF file (default: none)

=item * reference: FASTA reference genome (default: hg19.fa)

=item * reference_name: formal name of reference genome defined in "referemce" (default: GRCh37)

=item * reference_date: Release date of reference genome defined in "reference" (default: 200902)

=item * chromosome: Name of chromosome to be processed, if none is provided all the chromosomes will be processed

=item * pindel2vcf: full path to the pindel2vcf program (default: pindel2vcf, assumes pindel2vcf is in the path)

=back

=cut

sub convert_pindel_output_to_vcf {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		pindel_file => {
			isa         => 'Str',
			required    => 1
			},
		vcf => {
			isa			=> 'Str',
			required	=> 0,
			default		=> ''
			},
		reference => {
			isa			=> 'Str',
			required	=> 0,
			default		=> '/hpf/largeprojects/adam/ref_data/homosapiens/ucsc/GRCh37/fasta/genome.fa'
			},
		reference_name => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'GRCh37'
			},
		reference_date => {
			isa			=> 'Str',
			required	=> 0,
			default		=> '200902'
			},
		chromosome => {
			isa			=> 'Str',
			required	=> 0,
			default		=> ''
			},
		pindel2vcf => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'pindel2vcf'
			}
		);

	my $output;
	my $params = join(' ',
		'--pindel_output', $args{'pindel_file'},
		'--reference', $args{'reference'},
		'--reference_name', $args{'reference_name'},
		'--reference_date', $args{'reference_date'}
		);

	# if there is no vcf output file provided, Pindel appends '.vcf' to the input file provided
	if ('' ne $args{'vcf'}) {
		$params = join(' ',
			'--vcf',
			$args{'vcf'}
			);
		$output = $args{'vcf'};
		}
	else {
		$output = join('.',
			$args{'pindel_file'},
			'vcf'
			);
		}

	# if there is no chromosome, Pindel will process all chromosomes
	if ('' ne $args{'chromosome'}) {
		$params = join(' ',
			'--chromosome',
			$args{'chromosome'}
			);
		}

	my $cmd = join(' ',
		$args{'pindel2vcf'},
		$params
		);

	my %return_values = (
		cmd => $cmd,
		output => $output
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

    perldoc NGS::Tools::Pindel::Role

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

1; # End of NGS::Tools::Pindel::Role
