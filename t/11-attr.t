#!/usr/bin/env perl
use Mojo::Base -strict;
use Test2::API qw(intercept);
use Test2::V0 -target => 'Test2::MojoX';
use Test2::Tools::Tester qw/facets/;

use Mojolicious::Lite;
get '/' => 'index';

my $t = Test2::MojoX->new;
my $assert_facets;

## attr_is
$assert_facets = facets assert => intercept {
  $t->get_ok('/')->attr_is('#hobbit', 'name', 'bilbo')
    ->attr_is('#hobbit', 'surname', match qr/bag/, 'from bag-end')
    ->attr_is('#hobbit', 'name', D());
};
is @$assert_facets, 4;
is $assert_facets->[1]->details,
  'exact match for attribute "name" at selector "#hobbit"';
ok $assert_facets->[1]->pass;
is $assert_facets->[2]->details, 'from bag-end';
ok $assert_facets->[2]->pass;
is $assert_facets->[3]->details,
  'exact match for attribute "name" at selector "#hobbit"';
ok $assert_facets->[3]->pass;

$assert_facets = facets assert => intercept {
  $t->get_ok('/')->attr_is('#author', 'name', 'bilbo')
    ->attr_is('#author', 'surname', match qr/bag/, 'from bag-end')
    ->attr_is('#author', 'name', U());
};
is @$assert_facets, 4, 'four tests done';
is $assert_facets->[1]->details,
  'exact match for attribute "name" at selector "#author"';
ok !$assert_facets->[1]->pass;
is $assert_facets->[2]->details, 'from bag-end';
ok !$assert_facets->[2]->pass;
is $assert_facets->[3]->details,
  'exact match for attribute "name" at selector "#author"';
ok !$assert_facets->[3]->pass;

## attr_isnt
$assert_facets = facets assert => intercept {
  $t->get_ok('/')->attr_isnt('#author', 'name', 'bilbo')
    ->attr_isnt('#author', 'surname', match qr/bag/, 'not from bag-end')
    ->attr_isnt('#author', 'name', U());
};
is @$assert_facets, 4;
is $assert_facets->[1]->details,
  'no match for attribute "name" at selector "#author"';
ok $assert_facets->[1]->pass;

$assert_facets = facets assert => intercept {
  $t->get_ok('/')->attr_isnt('#hobbit', 'name', 'bilbo')
    ->attr_isnt('#hobbit', 'surname', match qr/bag/, 'not from bag-end')
    ->attr_isnt('#hobbit', 'name', D());
};
is @$assert_facets, 4, 'four tests done';
is $assert_facets->[1]->details,
  'no match for attribute "name" at selector "#hobbit"';
ok !$assert_facets->[1]->pass;
is $assert_facets->[2]->details, 'not from bag-end';
ok !$assert_facets->[2]->pass;
is $assert_facets->[3]->details,
  'no match for attribute "name" at selector "#hobbit"';
ok !$assert_facets->[3]->pass;

## attr_like
$assert_facets = facets assert => intercept {
  $t->get_ok('/')->attr_like('#hobbit', 'name', 'bilbo')
    ->attr_like('#hobbit', 'surname', qr/bag/, 'from bag-end')
    ->attr_like('#hobbit', 'name', D());
};
is @$assert_facets, 4;
is $assert_facets->[1]->details,
  'similar match for attribute "name" at selector "#hobbit"';
ok $assert_facets->[1]->pass;
is $assert_facets->[2]->details, 'from bag-end';
ok $assert_facets->[2]->pass;
is $assert_facets->[3]->details,
  'similar match for attribute "name" at selector "#hobbit"';
ok $assert_facets->[3]->pass;


$assert_facets = facets assert => intercept {
  $t->get_ok('/')->attr_like('#author', 'name', 'bilbo')
    ->attr_like('#author', 'surname', qr/bag/, 'from bag-end')
    ->attr_like('#author', 'name', U());
};
is @$assert_facets, 4;
is $assert_facets->[1]->details,
  'similar match for attribute "name" at selector "#author"';
ok !$assert_facets->[1]->pass;
is $assert_facets->[2]->details, 'from bag-end';
ok !$assert_facets->[2]->pass;
is $assert_facets->[3]->details,
  'similar match for attribute "name" at selector "#author"';
ok !$assert_facets->[3]->pass;

## attr_unlike
$assert_facets = facets assert => intercept {
  $t->get_ok('/')->attr_unlike('#author', 'name', 'bilbo')
    ->attr_unlike('#author', 'surname', qr/bag/, 'not from bag-end')
    ->attr_unlike('#author', 'name', U());
};
is @$assert_facets, 4;
is $assert_facets->[1]->details,
  'no similar match for attribute "name" at selector "#author"';
ok $assert_facets->[1]->pass;
is $assert_facets->[2]->details, 'not from bag-end';
ok $assert_facets->[2]->pass;
is $assert_facets->[3]->details,
  'no similar match for attribute "name" at selector "#author"';
ok $assert_facets->[3]->pass;


$assert_facets = facets assert => intercept {
  $t->get_ok('/')->attr_unlike('#hobbit', 'name', 'bilbo')
    ->attr_unlike('#hobbit', 'surname', qr/bag/, 'not from bag-end')
    ->attr_unlike('#hobbit', 'name', D());
};
is @$assert_facets, 4;
is $assert_facets->[1]->details,
  'no similar match for attribute "name" at selector "#hobbit"';
ok !$assert_facets->[1]->pass;
is $assert_facets->[2]->details, 'not from bag-end';
ok !$assert_facets->[2]->pass;
is $assert_facets->[3]->details,
  'no similar match for attribute "name" at selector "#hobbit"';
ok !$assert_facets->[3]->pass;

done_testing;

__DATA__
@@ index.html.epl
<div>
<span id="hobbit" name="bilbo" surname="baggins">Bilbo Baggins</li>
<span id="author" name"john" surname="tolkien">John R. R. Tolkien</li>
</div>
