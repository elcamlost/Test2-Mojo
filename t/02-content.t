#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::Mojo';

use Mojolicious::Lite;

my $t = Test2::Mojo->new;

my $events;

## content_is

$events = intercept {
  $t->get_ok('/')->content_is("Oops!\n");
};

is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'exact match for content';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->content_is('Oops!');
};

is @$events, 4, 'exactly two events and two diag messages';
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'exact match for content';
ok !$events->[1]->pass;

## content_isnt

$events = intercept {
  $t->get_ok('/')->content_isnt('Oops!');
};

is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no match for content';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->content_isnt("Oops!\n");
};

is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no match for content';
ok !$events->[1]->pass;

## content_like

$events = intercept {
  $t->get_ok('/')->content_like(qr/Oops/);
};

is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'content is similar';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->content_like(qr/Oops$/);
};

is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'content is similar';
ok !$events->[1]->pass;

## content_unlike

$events = intercept {
  $t->get_ok('/')->content_unlike(qr/Oops$/);
};

is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'content is not similar';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->content_unlike(qr/Oops/);
};

is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'content is not similar';
ok !$events->[1]->pass;

done_testing;

__DATA__
@@ not_found.html.epl
Oops!
