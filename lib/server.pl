#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use File::Basename;
use lib dirname (__FILE__);
use MyConfig;

# Documentation browser under "/perldoc" (this plugin requires Perl 5.10)
plugin 'pod_renderer';

get '/welcome' => sub {
  my $self = shift;
  $self->render('index');
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
Welcome to Mojolicious! Foo!

@@ layouts/default.html.ep
<!doctype html><html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
