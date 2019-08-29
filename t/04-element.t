#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::MojoX';

use Mojolicious::Lite;
get '/' => 'index';

my $t = Test2::MojoX->new;
my $events;

## element_count_is
$events = intercept {
  $t->get_ok('/')->element_count_is('ul>li', 2);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'element count for selector "ul>li"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->element_count_is('div>span', 2);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'element count for selector "div>span"';
ok !$events->[1]->pass;

## element_exists
$events = intercept {
  $t->get_ok('/')->element_exists('ul>li');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'element for selector "ul>li" exists';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->element_exists('div>span');
};
is @$events, 3, 'two ok events and one diag';
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'element for selector "div>span" exists';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';

## element_exists_not
$events = intercept {
  $t->get_ok('/')->element_exists_not('div>span');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no element for selector "div>span"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->element_exists_not('ul>li');
};
is @$events, 3, 'two ok events and one diag';
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no element for selector "ul>li"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';


done_testing;

__DATA__
@@ index.html.ep
<ul>
<li>Item 1</li>
<li>Item 2</li>
</ul>
