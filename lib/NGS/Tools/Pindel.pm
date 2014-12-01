package NGS::Tools::Pindel;
use Moose;
use MooseX::Params::Validate;

with 'NGS::Tools::Pindel::Role::Pipeline';
with 'NGS::Tools::Pindel::Role::PindelParser';
with 'NGS::Tools::Pindel::Role::Postprocessing';
with 'NGS::Tools::Picard::CollectInsertSizeMetrics';
with 'NGS::Tools::Picard::MetricsParser';

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;

=head1 NAME

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

=head1 SYNOPSIS

A Perl Moose wrapper for Pindel.

	use NGS::Tools::Pindel;

	my  = NGS::Tools::Pindel->new();

	...

=head1 ATTRIBUTES AND DELEGATES

=cut

=head2 $obj->java

Full path to Java engine, required for Picard suite of tools.

=cut

has 'java' => (
    is          => 'rw',
    isa         => 'Str',
    reader		=> 'get_java',
    writer		=> 'set_java',
    required	=> 0,
    default		=> '/hpf/tools/centos/java/1.6.0'
    );

=head2 $obj->picard

Full path to the directory containing the Picard suite of tools.

=cut

has 'picard' => (
    is          => 'rw',
    isa         => 'Str',
    reader		=> 'get_picard',
    writer		=> 'set_picard',
    required	=> 0,
    default		=> '/hpf/tools/centos/picard-tools/1.103'
    );


=head1 SUBROUTINES/METHODS

=head2 ->BUILD()

Post-constructor initialization (called automatically as part of new())

=head3 Arguments:

=over2

=item * : reference to hash of arguments

=back

=cut

sub BUILD {
	my $self = shift;
	my $args = shift;
	}

=head2 $obj->generate_pindel_config_file()

Description

=head3 Arguments:

=over 2

=item * bam: full path to the BAM file for processing

=back

=cut

sub generate_pindel_config_file {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		bam => {
			isa         => 'Str',
			required    => 1
			},
		sample => {
            isa         => 'Str',
            required    => 1
			},
		java => {
			isa			=> 'Str',
			required	=> 0,
			default		=> $self->get_java()
			},
		picard => {
			isa			=> 'Str',
			required	=> 0,
			default		=> $self->get_picard()
			}
		);

	my $output = join('.',
		$args{'sample'},
		'config'
		);

	my $insert_size_run = $self->CollectInsertSizeMetrics(
		input => $args{'bam'},
		java => $args{'java'},
		picard => $args{'picard'}
		);

	my $insert_size_stats = $self->get_insert_size_summary_statistics(

		);

	my %return_values = (
		insert_run => $insert_size_run,
		insert_stats => $insert_size_stats
		);

	return(\%return_values);
	}

=head1 AUTHOR

Richard de Borja, C<< <richard.deborja at sickkids.ca> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-test at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=test-test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc NGS::Tools::Pindel

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

no Moose;

__PACKAGE__->meta->make_immutable;

1; # End of NGS::Tools::Pindel
