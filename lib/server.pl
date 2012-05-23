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
get '/'               => \&handle_home;

# Add a drink
post '/api/drink'     => \&handle_post_drink;

# Get all drinks
get '/api/drink'      => \&handle_get_drinks;

# Get drink
get '/api/drink/:id'  => \&handle_get_drink;

# Update a drink
put '/api/drink/:id'  => \&handle_put_drink;

# Delete a drink
del '/api/drink/:id'   => \&handle_delete_drink;

app->start;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Controller
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_home {
  my $self = shift;

  $self->render('index');
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_get_drink {
  my $self = shift;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_get_drinks {
  my $self = shift;
  return $self->render_json( @{ get_drinks() } );
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_post_drink {
  my $self = shift;

  my $title = $self->param( 'title' );
  my $description = $self->param( 'description' );

  # Return error if missing parameter (400)
  if ( !defined($title) || !defined( $description ) ) {
    return $self->render_json( [], status => 400 );
  }

  # Return error if not add drink
  if( ! add_drink( $title, $description ) ) {
    return $self->render_json( [], status => 400 );
  }

  # Return 201 & id
  return $self->render_json( get_drink( $title ) );
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_put_drink {
  my $self = shift;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_delete_drink {
  my $self = shift;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub add_drink {
  my ( $title, $description ) = @_;

  my $dbh = get_dbh();

  my $sql = 'INSERT INTO `drink`(`title`, `description`) VALUES (?, ?)';

  my $sth;

  eval {
    $sth = $dbh->prepare($sql) or die $dbh->errstr;
    my $success = $sth->execute( $title, $description );
  };
  if ($@) {
    print "ERROR: $@ (while adding drink)" . "\n";
    return 0;
  }

  return 1;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub get_drinks {
  my $dbh = get_dbh();

  my $sql = 'SELECT * FROM `drink`';

  my $sth = $dbh->prepare($sql) or die $dbh->errstr;
  $sth->execute() or die $dbh->errstr;

  my ($rows, $row);
  push @$rows, $row while ( $row = $sth->fetchrow_hashref );

  return $rows;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub get_drink {

  my( $title ) = @_;

  my $dbh = get_dbh();

  my $sql = 'SELECT * FROM `drink` WHERE `title` = ?';

  my $sth = $dbh->prepare($sql) or die $dbh->errstr;
  $sth->execute( $title ) or die $dbh->errstr;

  # Return 201 & id
  return $sth->fetchrow_hashref;

}

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
