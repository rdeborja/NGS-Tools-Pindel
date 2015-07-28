package NGS::Tools::Pindel::Role::PindelParser;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use Data::Dumper;

=head1 NAME

NGS::Tools::Pindel::Role::PindelParser

=head1 SYNOPSIS

A Pindel parser role.

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->create_pindel_tabular_file()

Convert Pindel output files to a tabular format.

=head3 Arguments:

=over 2

=item * files: Array reference containing Pindel files for processing.

=item * output: Name of output file (defualt: pindel.tab)

=item * sample: Name of sample being processed, this will be appended to the data

=back

=cut

sub create_pindel_tabular_file {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		files => {
			isa         => 'ArrayRef',
			required    => 1
			},
		output => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'pindel.tab'
			},
		sample => {
			isa			=> 'Str',
			required	=> 1
			}
		);

	open(my $output_fh, '>', $args{'output'});
	$self->print_header(output => $output_fh);
	foreach my $file (@{ $args{'files'} }) {
		$self->parse_pindel_output(
			file => $file,
			output => $output_fh,
			sample => $args{'sample'}
			);
		}
	close($output_fh);

	return 0;
	}

=head2 $obj->parse_pindel_output()

Parse the Pindel generated file.  At this point, we're only interestedin the short insertions
(_SI) and deletions (_D) files.

=head3 Arguments:

=over 2

=item * file: Pindel file to process (required)

=item * output: File handle for output file (required)

=item * sample: Name of sample being processed (required)

=back

=cut

sub parse_pindel_output {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		file => {
			isa         => 'Str',
			required    => 1
			},
		output => {
			isa			=> 'FileHandle',
			required	=> 1
			},
		sample => {
			isa			=> 'Str',
			required	=> 1
			}
		);
	my $is_deletion;
	my $is_insertion;
	if ($args{'file'} =~ m/_D$/) {
		$is_deletion = 'TRUE';
		}
	elsif ($args{'file'} =~ m/_SI$/) {
		$is_insertion = 'TRUE';
		}
	else {
		die("Invalid filename, must end in either _SI or _D");
		}
	my $ofh = $args{'output'};
	open(my $fh, '<', $args{'file'});
	while(my $line = <$fh>) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;

		# the line of interest is below the #### line, this contains all the
		# metadata from the Pindel output
		if ($line =~ /^#/) {
			$line = <$fh>;
			$line =~ s/^\s+//;
			$line =~ s/\s+$//;
			my @data_array = split(/\s+/, $line);

			# also get the reference line, any characters that are lowercase will
			# provide information on the deleted bases from the reference since
			# these are not reported in the meta data line
			$line = <$fh>;
			$line =~ s/^\s+//;
			$line =~ s/\s+$//;
			my @ref_array = split(//, $line);
			my $bases = '';
			if ($data_array[1] eq 'D') {
				foreach my $base (@ref_array) {
					# check if the base is lowercase
					if ($base eq lc($base)) {
						$bases = join('', $bases, $base);
						}
					}
				}
			elsif ($data_array[1] eq 'I') {
				$bases = lc($data_array[5]);
				$bases =~ s/\"//g;
				}
			my %pindel_table = (
				'PINDEL_ID'					=> $data_array[0],
				'VARIANT_TYPE'				=> $data_array[1],
				'LENGTH'					=> $data_array[2],
				'CHR'						=> $data_array[7],
				'START'						=> $data_array[9],
				'END'						=> $data_array[10],
				'RANGE_START'				=> $data_array[12],
				'RANGE_END'					=> $data_array[13],
				'SV_SUPPORT_READS'			=> $data_array[15],
				'SV_UNIQUE_SUPPORT_READS'	=> $data_array[16],
				'S1_SCORE'					=> $data_array[24],
				'SUM_MS'					=> $data_array[26],
				'BASES'						=> $bases,
				'SAMPLE'					=> $args{'sample'},
				);
			# the Pindel output is slightly offset, we need to add 1 to the start
			# position and subtract 1 from the end for deletions only
			if ($pindel_table{'VARIANT_TYPE'} eq 'D') {
				$pindel_table{'START'} = $pindel_table{'START'} + 1;
				$pindel_table{'END'} = $pindel_table{'END'} - 1;
				}
			$self->_print_tabular_pindel_output(
				data => \%pindel_table,
				output => $ofh
				);
			}
		}
	close($fh);

	return 0;
	}


=head2 $obj->get_reference_sequence()

Obtain the reference sequence.  For insertions, get the preceeding base and for deletions
get the lowercase sequence in the below the main line.

=head3 Arguments:

=over 2

=item * arg: argument

=back

=cut

sub get_reference_sequence {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		arg => {
			isa         => 'Str',
			required    => 0,
			default     => ''
			}
		);

	my %return_values = (

		);

	return(\%return_values);
	}

=head2 $obj->print_header()

Print the header for the tabular data output from Pindel

=head3 Arguments:

=over 2

=item * output: file handle to output data (required)

=back

=cut

sub print_header {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		output => {
			isa			=> 'FileHandle',
			required	=> 1
			}
		);

	print {$args{'output'}} join("\t",
		'PINDEL_ID',
		'SAMPLE',
		'VARIANT_TYPE',
		'VARIANT_LENGTH',
		'CHR',
		'START',
		'END',
		'RANGE_START',
		'RANGE_END',
		'S1_SCORE',
		'BASES',
		'SUM_MS',
		'SV_SUPPORT_READS',
		'SV_UNIQUE_SUPPORT_READS'
		), "\n";

	return 0;
	}

=head2 $obj->_print_tabular_pindel_output()

Print the tabular form of Pindel output.

=head3 Arguments:

=over 2

=item * data: Hash reference the Pindel output.

=item * output: Write output to this filehandle.

=back

=cut

sub _print_tabular_pindel_output {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		data => {
			isa         => 'HashRef',
			required    => 1
			},
		output => {
			isa			=> 'FileHandle',
			required	=> 1
			}
		);

	print {$args{'output'}} join("\t",
		$args{'data'}->{'PINDEL_ID'},
		$args{'data'}->{'SAMPLE'},
		$args{'data'}->{'VARIANT_TYPE'},
		$args{'data'}->{'LENGTH'},
		$args{'data'}->{'CHR'},
		$args{'data'}->{'START'},
		$args{'data'}->{'END'},
		$args{'data'}->{'RANGE_START'},
		$args{'data'}->{'RANGE_END'},
		$args{'data'}->{'S1_SCORE'},
		$args{'data'}->{'BASES'},
		$args{'data'}->{'SUM_MS'},
		$args{'data'}->{'SV_SUPPORT_READS'},
		$args{'data'}->{'SV_UNIQUE_SUPPORT_READS'}
		), "\n";

	return 0;
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

    perldoc NGS::Tools::Pindel::Role::PindelParser

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

1; # End of NGS::Tools::Pindel::Role::PindelParser
