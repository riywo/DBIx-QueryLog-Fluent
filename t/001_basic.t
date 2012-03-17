#!perl -w
use strict;
use Test::Requires 'DBD::SQLite';
use Test::More;
use Test::TCP;
use Test::SharedFork;
use IO::Socket::INET;
use t::Util;

use DBIx::QueryLog::Fluent;

my $port = Test::TCP::empty_port;
note "port: $port";

my $pid = fork();
if ($pid == 0) {
    Test::SharedFork->child;
    sleep 1;

    DBIx::QueryLog::Fluent->logger(
        host => "127.0.0.1",
        port => $port,
    );

    my $dbh = t::Util->new_dbh;
    $dbh->selectrow_hashref('SELECT * FROM sqlite_master WHERE type = ?', undef, qw/table/);
}
elsif (defined $pid) {
    Test::SharedFork->parent;
    my $sock = IO::Socket::INET->new(
        LocalPort => $port,
        LocalAddr => "127.0.0.1",
        Listen    => 5,
    ) or die "Cannot open server socket: $!";

    while (my $cs = $sock->accept) {
        my $data = streaming_decode_mp($cs);
        note explain $data;
        isa_ok $data         => "ARRAY";
        is $data->[0]        => "query.debug";
        my $log = $data->[2];
        ok exists $log->{time}, 'time is exists';
        is $log->{line}, 26, 'line ok';
        like $log->{file}, qr/001_basic\.t/, 'file ok';
        is $log->{pkg}, 'main', 'pkg ok';
        is $log->{sql}, 'SELECT * FROM sqlite_master WHERE type = \'table\'', 'query ok';
        last;
    }
    done_testing;
};
