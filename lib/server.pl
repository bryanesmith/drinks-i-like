#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use File::Basename;
use lib dirname (__FILE__);
use MyConfig;

# Documentation browser under "/perldoc" (this plugin requires Perl 5.10)
plugin 'pod_renderer';

# Set public/ directory path to project root
app->static->root( app->home->rel_dir('../public') );

get '/' => sub {
  my $self = shift;

  $self->render('index');
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<p>Foo.</p>

@@ layouts/default.html.ep
<!doctype html>
<html>
  <head>
    <title><%= title %></title>
    <script src="http://code.jquery.com/jquery-1.7.2.min.js"></script>
    <script src="/js/library.js"></script>
    <link rel="stylesheet" type="text/css" media="screen" href="/css/screen.css"/>
  </head>
  <body><%= content %></body>
</html>
