#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::Mojo';

use Mojolicious::Lite;

get '/' => sub {
  shift->render(
    json => {
      scalar => 'value',
      array  => [qw/item1 item2/],
      hash   => {key1 => 'value1', key2 => 'value2'}
    }
  );
};

my $t = Test2::Mojo->new;
my $events;

## json_has

$events = intercept {
  $t->get_ok('/')->json_has('/scalar');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'has value for JSON Pointer "/scalar"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->json_has('/unknown');
};
is @$events, 3;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'has value for JSON Pointer "/unknown"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';

## json_hasnt

$events = intercept {
  $t->get_ok('/')->json_hasnt('/unknown');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'has no value for JSON Pointer "/unknown"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->json_hasnt('/scalar');
};
is @$events, 3;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'has no value for JSON Pointer "/scalar"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';

## json_is

$events = intercept {
  $t->get_ok('/')->json_is('/scalar' => 'value');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'exact match for JSON Pointer "/scalar"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->json_is(hash {
    field scalar => 'value';
    field array  => array {
      item 'item1';
      item 'item2';
      end;
    };
    field hash => hash {
      field key1 => 'value1';
      field key2 => 'value2';
      end;
    };
    end;
  });
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'exact match for JSON Pointer ""';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->json_is('/unknown' => 'value');
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'exact match for JSON Pointer "/unknown"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

## json_like

$events = intercept {
  $t->get_ok('/')->json_like('/scalar' => qr/val/);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'similar match for JSON Pointer "/scalar"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->json_like(hash {
    field scalar => 'value';
    field array  => array {
      all_items match qr/^item/;
    };
  });
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'similar match for JSON Pointer ""';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->json_like('/scalar' => qr/false/);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'similar match for JSON Pointer "/scalar"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

## json_unlike

$events = intercept {
  $t->get_ok('/')->json_unlike('/scalar' => qr/false/);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no similar match for JSON Pointer "/scalar"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->json_unlike(hash {
    field scalar => 'false';
    field array  => array {
      all_items match qr/^field/;
    };
  });
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no similar match for JSON Pointer ""';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->json_unlike('/scalar' => qr/value/);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no similar match for JSON Pointer "/scalar"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

done_testing;
