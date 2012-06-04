#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use DBI;
use File::Basename;
use lib dirname (__FILE__);
use MyConfig;
use JSON;

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
  
  my $id          = $self->param( 'id' );

  # Return error if missing parameter (400)
  if ( !defined($id) ) {
    return $self->render_json( [], status => 400 );
  }

  return $self->render_json( get_drink_by_id( $id ), status => 200 );
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_get_drinks {
  my $self = shift;
  return $self->render_json( get_drinks() );
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_post_drink {

  my $self = shift;

  my $title       = $self->param( 'title' );
  my $description = $self->param( 'description' );


  # Use JSON content if parameter not defined
  if ( defined( $self->req->content ) ) {

    our $drink;

    eval {
     $drink = decode_json( $self->req->content->asset->{'content'} );
    };

    if ( defined( $drink ) ) {

      $title = $drink->{'title'} if !defined($title) && defined($drink->{'title'});

      $description = $drink->{'description'} if !defined($description) && defined($drink->{'description'});

    }

  }

  # Return error if missing parameter (400)
  if ( !defined($title) || !defined( $description ) ) {
    return $self->render_json( [], status => 400 );
  }

  # Return error if not add drink (conflict, 409)
  if( ! add_drink( $title, $description ) ) {
    return $self->render_json( [], status => 409 );
  }

  # Return 201 & id
  return $self->render_json( get_drink_by_title( $title ), status => 201 );
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_put_drink {
  my $self = shift;
  my $id          = $self->param( 'id' );
  my $drink       = decode_json( $self->req->content->asset->{'content'} );

  # Return error if missing parameter (400)
  if ( !defined($id) || !defined( $drink ) || !defined($drink->{'title'}) || !defined($drink->{'description'}) ) {
    return $self->render_json( [], status => 400 );
  }

  $drink = update_drink( $id, $drink->{'title'}, $drink->{'description'} );

  if ( ! defined( $drink ) ) {
    return $self->render_json( [], status => 400 );
  }

  return $self->render_json( $drink, status => 200 );

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
sub handle_delete_drink {
  my $self = shift;

  my $id          = $self->param( 'id' );

  # Return error if missing parameter (400)
  if ( ! defined($id) ) {
    return $self->render_json( [], status => 400 );
  }

  my $drink = delete_drink( $id );

  if ( ! defined( $drink ) ) {
    return $self->render_json( [], status => 400 );
  }

  return $self->render_json( $drink, status => 200 );
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
    # Conflict
    print "ERROR: $@ (while adding drink)" . "\n";
    return 0;
  }

  return 1;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub delete_drink {
  my ( $id ) = @_;

  my $drink = get_drink_by_id( $id );

  return undef if ! defined( $drink );

  my $dbh = get_dbh();

  my $sql = 'DELETE FROM `drink` WHERE `id` = ?';

  my $sth;

  eval {
    $sth = $dbh->prepare($sql) or die $dbh->errstr;
    my $success = $sth->execute( $id );
  };
  if ($@) {
    # Conflict
    print "ERROR: $@ (while deleting drink)" . "\n";
    return undef;
  }

  return $drink;

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub update_drink {
  my ( $id, $title, $description ) = @_;

  my $drink = get_drink_by_id( $id );

  return undef if ! defined( $drink );

  my $dbh = get_dbh();

  my $sql = 'UPDATE `drink` SET `title` = ?, `description` = ? WHERE `id` = ?';

  my $sth;

  eval {
    $sth = $dbh->prepare($sql) or die $dbh->errstr;
    my $success = $sth->execute( $title, $description, $id );
  };
  if ($@) {
    # Conflict
    print "ERROR: $@ (while updating drink)" . "\n";
    return undef;
  }

  return $drink;

}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub get_drinks {
  my $dbh = get_dbh();

  my $sql = 'SELECT * FROM `drink`';

  my $sth = $dbh->prepare($sql) or die $dbh->errstr;
  $sth->execute() or die $dbh->errstr;

  my ($rows, $row);
  $rows = [];
  push @$rows, $row while ( $row = $sth->fetchrow_hashref );

  return $rows;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub get_drink_by_title {

  my( $title ) = @_;

  my $dbh = get_dbh();

  my $sql = 'SELECT * FROM `drink` WHERE `title` = ?';

  my $sth = $dbh->prepare($sql) or die $dbh->errstr;
  $sth->execute( $title ) or die $dbh->errstr;

  return $sth->fetchrow_hashref;

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub get_drink_by_id {

  my( $id ) = @_;

  my $dbh = get_dbh();

  my $sql = 'SELECT * FROM `drink` WHERE `id` = ?';

  my $sth = $dbh->prepare($sql) or die $dbh->errstr;
  $sth->execute( $id ) or die $dbh->errstr;

  return $sth->fetchrow_hashref;

}


__DATA__

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Inline templates
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
@@ index.html.ep
% layout 'default';
% title 'Drinks I Like';
<aside>
  <form name="">
    <h1>New Drink</h1>
    <label for="title">Name</label>
    <input type="text" name="title" />
    <label for="description">Description</label>
    <textarea name="description"></textarea>
    <input type="submit" value="Add drink" />
  </form>
</aside>
<% my $rows = [
    { title => 'Test #1', description => 'Testing a description #1' },
    { title => 'Test #2', description => 'Testing a description #2' },
    { title => 'Test #3', description => 'Testing a description #3' },  
  ]; %>
<section>
  <table>
    <tr>
      <th>Name</th>
      <th>Description</th>
      <th>&nbsp;</th>
    </tr>
    <% for my $row ( @$rows ) { %>
      <tr>
        <td><input class="title" name="" value="<%= $row->{'title'} %>" /></td>
        <td><input class="description" name="" value="<%= $row->{'description'} %>" /></td>
        <td><a href="#">x</a></td>
      </tr>
    <% } %>
  </table>
</section>
 
@@ layouts/default.html.ep
<!doctype html>
<html>
  <head>
    <title><%= title %></title>
    <script src="/js/jquery.js"></script>
    <script src="/js/json2.js"></script>
    <script src="/js/underscore.js"></script>
    <script src="/js/backbone.js"></script>
    <script src="/js/modernizr.custom.76020.js"></script>
    <script src="/js/library.js"></script>
    <link rel="stylesheet" type="text/css" media="screen" href="/css/bootstrap.min.css"/>
    <link rel="stylesheet" type="text/css" media="screen" href="/css/screen.css"/>
  </head>
  <body>
    <header>
      <h1><%= title %></h1>
    </header>
    <div role="main">
      <%= content %>
    </div>
  </body>
</html>
