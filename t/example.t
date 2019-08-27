#!/usr/bin/env perl
use Mojo::Base -strict, -signatures;

use Test2::Mojo;
use Test2::V0;

my $t = Test2::Mojo->new;
$t->get_ok('/');

done_testing;
