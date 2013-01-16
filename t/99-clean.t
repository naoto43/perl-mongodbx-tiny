#!/usr/bin/env perl

use strict;
use FindBin;
use lib $FindBin::Bin . "/../t/lib";
use MyData;
use Test::More tests => 1;

my $tiny = MyData->new;

if ($tiny) {
    ok($tiny->database->drop);
} else {
    ok(1);
}


