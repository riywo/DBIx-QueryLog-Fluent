package t::Util;
use strict;
use warnings;
use DBI;
use File::Temp qw/tempfile/;
use Exporter 'import';
our @EXPORT = qw/streaming_decode_mp/;

BEGIN {
    # cleanup environment
    for my $key (keys %ENV) {
        next unless $key =~ /^DBIX_QUERYLOG_/;
        delete $ENV{$key};
    }
}

sub streaming_decode_mp {
    my $sock   = shift;
    my $offset = 0;
    my $up     = Data::MessagePack::Unpacker->new;
    while( read($sock, my $buf, 1024) ) {
        $offset = $up->execute($buf, $offset);
        if ($up->is_finished) {
            return $up->data;
        }
    }
}

sub new_dbh {
    my ($fh, $file) = tempfile;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$file",'','', {
        AutoCommit => 1,
        RaiseError => 1,
    });
    return $dbh;
}

1;
