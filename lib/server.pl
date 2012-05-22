#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use DBI;
use File::Basename;
use lib dirname (__FILE__);
use MyConfig;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub get_dbh {
        
  my $db = MyConfig::db_name();
  my $data_source = "dbi:mysql:database=${db};host=localhost";
        
  my $dbh = DBI->connect(
                   $data_source,
                   MyConfig::db_username(),
                   MyConfig::db_password(),
                   {
                    RaiseError => 1,
                    mysql_enable_utf8 => 1,
                   });

  return $dbh;
};

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Documentation browser under "/perldoc" (this plugin requires Perl 5.10)
plugin 'pod_renderer';

# Set public/ directory path to project root
app->static->root( app->home->rel_dir('../public') );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Routes
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

# Home page
get '/' => sub {
  my $self = shift;

  $self->render('index');
};

# Add a drink
post '/api/drink' => sub {
  my $self = shift;

  # Return error if missing parameter (400)

  my $dbh = get_dbh();

  my $sql = 'INSERT INTO `drink`(`title`, `description`) VALUES (?, ?)';

  my $sth = $dbh->prepare($sql) or die $dbh->errstr;
  $sth->execute( 
    $self->param('title'), 
    $self->param('description') );

  # Return error if failed to add (401)


  $sql = 'SELECT * FROM `drink` WHERE `title` = ? AND `description` = ?';

  $sth = $dbh->prepare($sql) or die $dbh->errstr;
  $sth->execute( 
    $self->param('title'), 
    $self->param('description') ) or die $dbh->errstr;

  # Return 201 & id
  return $self->render_json( $sth->fetchrow_hashref );
};

# Get all drinks
get '/api/drink' => sub {
  my $self = shift;

  my $dbh = get_dbh();

  my $sql = 'SELECT * FROM `drink`';

  my $sth = $dbh->prepare($sql) or die $dbh->errstr;
  $sth->execute() or die $dbh->errstr;

  my (@rows, $row);
  push @rows, $row while ( $row = $sth->fetchrow_hashref );

  return $self->render_json( @rows );
};

# Get drink
get '/api/drink/:id' => sub {
  my $self = shift;

};

# Update a drink
put '/api/drink/:id' => sub {
  my $self = shift;

};

# Delete a drink
del '/api/drink/:id' => sub {
  my $self = shift;

};

app->start;
__DATA__

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Inline templates
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
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
