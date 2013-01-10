#!/usr/bin/env perl

use strict;
use FindBin;
use lib $FindBin::Bin . "/../t/lib";
use MyData;
use Test::More tests => 1;
ok(MyData->new->database->drop);


