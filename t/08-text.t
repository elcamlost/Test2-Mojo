#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::MojoX';

use Mojolicious::Lite;
get '/' => 'index';

my $t = Test2::MojoX->new;
my $events;

## text_is
$events = intercept {
  $t->get_ok('/')->text_is('#sam' => 'Gamgee');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'exact match for selector "#sam"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->text_is('#frodo' => 'Baggins');
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'exact match for selector "#frodo"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

## text_isnt
$events = intercept {
  $t->get_ok('/')->text_isnt('#frodo' => 'Baggins');
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no match for selector "#frodo"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->text_isnt('#sam' => 'Gamgee');
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no match for selector "#sam"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

## text_like
$events = intercept {
  $t->get_ok('/')->text_like('#sam' => qr/Gamgee/);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'similar match for selector "#sam"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->text_like('#sam' => qr/Baggins/);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'similar match for selector "#sam"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

## text_unlike
$events = intercept {
  $t->get_ok('/')->text_unlike('#sam' => qr/Baggins/);
};
is @$events, 2;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no similar match for selector "#sam"';
ok $events->[1]->pass;

$events = intercept {
  $t->get_ok('/')->text_unlike('#sam' => qr/Gamgee/);
};
is @$events, 4;
isa_ok $events->[1], 'Test2::Event::Ok';
is $events->[1]->name, 'no similar match for selector "#sam"';
ok !$events->[1]->pass;
isa_ok $events->[2], 'Test2::Event::Diag';
isa_ok $events->[3], 'Test2::Event::Diag';

done_testing;

__DATA__
@@ index.html.epl
<div>
<span id='sam'>Gamgee</span>
</div>
