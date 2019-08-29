#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::MojoX';

use Mojolicious::Lite;

my $t = Test2::MojoX->new;
my $events;

## content_type_is
$events = intercept {
  $t->get_ok('/')->content_type_is('text/html;charset=UTF-8');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'Content-Type: text/html;charset=UTF-8';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->content_type_is('text/html');
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'Content-Type: text/html';
ok !$events->[1]->pass;

## content_type_isnt
$events = intercept {
  $t->get_ok('/')->content_type_isnt('text/html');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'not Content-Type: text/html';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->content_type_isnt('text/html;charset=UTF-8');
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'not Content-Type: text/html;charset=UTF-8';
ok !$events->[1]->pass;

## content_type_like
$events = intercept {
  $t->get_ok('/')->content_type_like(qr[text/html]);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'Content-Type is similar';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->content_type_like(qr[application/json]);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'Content-Type is similar';
ok !$events->[1]->pass;

## content_type_unlike
$events = intercept {
  $t->get_ok('/')->content_type_unlike(qr[application/json]);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'Content-Type is not similar';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->content_type_unlike(qr[text/html]);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'Content-Type is not similar';
ok !$events->[1]->pass;

done_testing;
