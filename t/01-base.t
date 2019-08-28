#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::Mojo';

ok $CLASS, 'Test2::Mojo';

use Mojolicious::Lite;

get '/' => sub {
  my $c = shift;
  $c->render(text => 'Bender');
};

my $t = Test2::Mojo->new;
isa_ok $t, 'Test2::Mojo';
isa_ok $t->app, 'Mojolicious';

my $events;

my @methods = qw(delete get head options patch post put);

$events = intercept {
  for my $method (@methods) {
    my $sub_name = "${method}_ok";
    $t->$sub_name('/');
  }
};

is @$events, 7;
for my $i (0 .. 6) {
  my $method = $methods[$i];
  my $event  = $events->[$i];

  isa_ok $event, 'Test2::Event::Ok';
  is $event->name, uc $method . ' /';
  is $event->pass, 1;
}

is $t->success, 1;
isa_ok $t->ua,  'Mojo::UserAgent';
ok $t->ua->insecure;

# Request with custom method
my $tx = $t->ua->build_tx(FOO => '/test.json' => json => {foo => 1});
$events = intercept {
  $t->request_ok($tx);
};
isa_ok $events->[0], 'Test2::Event::Ok';
is $events->[0]->name, 'FOO /test.json';
is $events->[0]->pass, 1;

done_testing;
