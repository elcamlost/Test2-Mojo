#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::Mojo';

use Mojolicious::Lite;

my $t = Test2::Mojo->new;

my $events;

## header_exists

$events = intercept {
  $t->get_ok('/')->header_exists('server');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'header "server" exists';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->header_exists('unknown');
};
is @$events, 3;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'header "unknown" exists';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';

## header_exists_not

$events = intercept {
  $t->get_ok('/')->header_exists_not('unknown');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no "unknown" header';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->header_exists_not('server');
};
is @$events, 3;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no "server" header';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';

## header_is

$events = intercept {
  $t->get_ok('/')->header_is('server' => 'Mojolicious (Perl)');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'server: Mojolicious (Perl)';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->header_is('server' => 'Django (Python)');
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'server: Django (Python)';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

## header_isnt

$events = intercept {
  $t->get_ok('/')->header_isnt('server' => 'Django (Python)');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'not server: Django (Python)';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->header_isnt('server' => 'Mojolicious (Perl)');
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'not server: Mojolicious (Perl)';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

## header_like

$events = intercept {
  $t->get_ok('/')->header_like('server' => qr/Mojo/);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'server is similar';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->header_like('server' => qr/Django/);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'server is similar';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

## header_unlike

$events = intercept {
  $t->get_ok('/')->header_unlike('server' => qr/Django/);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'server is not similar';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->header_unlike('server' => qr/Mojo/);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'server is not similar';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

done_testing;
