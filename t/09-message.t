#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::MojoX';

use Mojolicious::Lite;
websocket '/' => sub {
  my $c = shift;
  $c->tx->max_websocket_size(65538)->with_compression;
  $c->on(binary => sub { shift->send({binary => shift}) });
  $c->on(text   => sub { shift->send('text: ' . shift) });
};

my $t = Test2::MojoX->new;
my $events;

## websocket_ok
$events = intercept {
  $t->websocket_ok('/')->status_is(101)->send_ok('hello')
    ->message_ok->message_is('text: hello')->finish_ok(1000)->finished_ok(1000);
};
is @$events, 7;
isa_ok $events->[0], 'Test2::Event::Ok';
is $events->[0]->name, 'WebSocket handshake with /';
ok $events->[0]->pass;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, '101 Switching Protocols';
ok $events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Ok';
is $events->[2]->name, 'send message';
ok $events->[2]->pass;
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'message received';
ok $events->[3]->pass;
isa_ok $events->[4], 'Test2::Event::Ok';
is $events->[4]->name, 'exact match for message';
ok $events->[4]->pass;
isa_ok $events->[5], 'Test2::Event::Ok';
is $events->[5]->name, 'closed WebSocket';
ok $events->[5]->pass;
isa_ok $events->[6], 'Test2::Event::Ok';
is $events->[6]->name, 'WebSocket closed with out 1000';
ok $events->[6]->pass;

## failed websocket_ok
$events = intercept {
  $t->websocket_ok('/404');
};
is @$events, 2;
isa_ok $events->[0], 'Test2::Event::Ok';
is $events->[0]->name, 'WebSocket handshake with /404';
ok !$events->[0]->pass;

## failed send_ok
$events = intercept {
  $t->get_ok('/')->send_ok(0);
};
is @$events, 3;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'send message';
ok !$events->[1]->pass;

## failed message_ok
my $mock = mock 'Test2::MojoX' => (override => [_wait => sub {0}]);
$events = intercept {
  $t->websocket_ok('/')->send_ok(0)->message_ok;
};
is @$events, 4;
isa_ok $events->[2], 'Test2::Event::Ok';
is $events->[2]->name, 'message received';
ok !$events->[2]->pass;
isa_ok $events->[3], 'Test2::Event::Diag';
undef $mock;

## failed message_is
$events = intercept {
  $t->websocket_ok('/')->send_ok('hello')->message_is('text: bye');
};
is @$events, 5;
isa_ok $events->[2], 'Test2::Event::Ok';
is $events->[2]->name, 'exact match for message';
ok !$events->[2]->pass;
isa_ok $events->[3], 'Test2::Event::Diag';
isa_ok $events->[4], 'Test2::Event::Diag';

## failed finish_ok
$events = intercept {
  $t->get_ok('/')->finish_ok;
};
is @$events, 3;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'connection is not WebSocket';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';

# failed finished_ok
$events = intercept {
  $t->websocket_ok('/')->finish_ok->finished_ok(0);
};
is @$events, 5;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Ok';
is $events->[3]->name, 'WebSocket closed with out 0';
ok !$events->[3]->pass;
isa_ok $events->[4], 'Test2::Event::Diag';

done_testing;
