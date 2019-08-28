#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::Mojo';

use Mojolicious::Lite;

my $t = Test2::Mojo->new;

my $events;

## status_is

$events = intercept {
  $t->get_ok('/')->status_is(404);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, '404 Not Found';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->status_is(200);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, '200 OK';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

## status_isnt

$events = intercept {
  $t->get_ok('/')->status_isnt(200);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'not 200 OK';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->status_isnt(404);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'not 404 Not Found';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

done_testing;
