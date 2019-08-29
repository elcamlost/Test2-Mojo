#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::MojoX';

use Mojolicious::Lite;
websocket '/' => sub {
  my $c = shift;
  $c->on(json => sub { shift->send({json => shift}) });
};

my $t = Test2::MojoX->new;
my $events;

## json_message_is
$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_is(hash {
    field test    => 23;
    field snowman => '☃';
    end;
    });
};
is @$events, 4;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'exact match for JSON Pointer ""';
ok $events->[3]->pass;

$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_is(hash {
    field test => 23;
    end;
    });
};
is @$events, 6;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'exact match for JSON Pointer ""';
ok !$events->[3]->pass;
isa_ok $events->[4], 'Test2::Event::Diag';
isa_ok $events->[5], 'Test2::Event::Diag';

## json_message_like
$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_like(hash { field test => 23; });
};
is @$events, 4;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'similar match for JSON Pointer ""';
ok $events->[3]->pass;

$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_like(hash { field test => 24; });
};
is @$events, 6;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'similar match for JSON Pointer ""';
ok !$events->[3]->pass;
isa_ok $events->[4], 'Test2::Event::Diag';
isa_ok $events->[5], 'Test2::Event::Diag';

## json_message_unlike
$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_unlike(hash { field test => 24; });
};
is @$events, 4;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'no similar match for JSON Pointer ""';
ok $events->[3]->pass;

$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_unlike(hash { field test => 23; });
};
is @$events, 6;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'no similar match for JSON Pointer ""';
ok !$events->[3]->pass;
isa_ok $events->[4], 'Test2::Event::Diag';
isa_ok $events->[5], 'Test2::Event::Diag';

## json_message_has
$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_has('/test');
};
is @$events, 4;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'has value for JSON Pointer "/test"';
ok $events->[3]->pass;

$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_has('/non-existent');
};
is @$events, 5;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'has value for JSON Pointer "/non-existent"';
ok !$events->[3]->pass;
isa_ok $events->[4], 'Test2::Event::Diag';

## json_message_hasnt
$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_hasnt('/non-existent');
};
is @$events, 4;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'has no value for JSON Pointer "/non-existent"';
ok $events->[3]->pass;

$events = intercept {
  $t->websocket_ok('/')->send_ok({json => {test => 23, snowman => '☃'}})
    ->message_ok->json_message_hasnt('/test');
};
is @$events, 5;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'has no value for JSON Pointer "/test"';
ok !$events->[3]->pass;
isa_ok $events->[4], 'Test2::Event::Diag';

done_testing;
