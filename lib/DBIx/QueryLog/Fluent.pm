package DBIx::QueryLog::Fluent;
use 5.008_001;
use strict;
use warnings;
use Fluent::Logger;
use DBIx::QueryLog;

our $VERSION = '0.01';

my $logger;

sub logger {
    my $self = shift;
    my %params = @_;
    $logger = Fluent::Logger->new(%params);
};

$DBIx::QueryLog::OUTPUT = sub {
    my %params = @_;
    $logger = Fluent::Logger->new unless $logger;

    my $level = $params{level};
    map { delete $params{$_} } qw/level dbh message localtime bind_params/;
    $logger->post("query.$level" => \%params);
};

1;
__END__

=head1 NAME

DBIx::QueryLog::Fluent - Perl extention to do something

=head1 VERSION

This document describes DBIx::QueryLog::Fluent version 0.01.

=head1 SYNOPSIS

    use DBIx::QueryLog::Fluent;
    DBIx::QueryLog::Fluent->logger(
        host => '127.0.0.1',
        port => 24224,
    );

=head1 DESCRIPTION

DBIx::QueryLog::Fluent is a query log module sending to fluentd

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

riywo E<lt>riywo.jp@gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, riywo. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
