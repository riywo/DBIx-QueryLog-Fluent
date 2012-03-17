#!perl -w
use strict;
use Test::More tests => 1;

BEGIN {
    use_ok 'DBIx::QueryLog::Fluent';
}

diag "Testing DBIx::QueryLog::Fluent/$DBIx::QueryLog::Fluent::VERSION";
