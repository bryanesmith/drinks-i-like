use strict;
use warnings;

use Test::More tests => 39;
use Test::Mojo;
use JSON;
use FindBin;
require "$FindBin::Bin/../lib/server.pl";

#my $ua = Mojo::UserAgent->new;
#my $host = 'http://127.0.0.1:3000';

my $t = Test::Mojo->new;

my ( $response, $expect, $drink );

# Keep track of drinks
my @drinks = ();
my $initial_drink = {
  'id'          => 1,
  'title'       => 'milk',
  'description' => '"Milk is for babies. When you grow up you have to drink beer." - Arnold Schwarzenegger',
};
push @drinks, $initial_drink;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test get drinks matches our running list
$t->get_ok('/api/drink')->status_is(200)->json_content_is( @drinks );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add drink
$drink = {
  'title'       => 'espresso',
  'description' => '"It is inhumane, in my opinion, to force people who have a genuine medical need for coffee to wait in line behind people who apparently view it as some kind of recreational activity." - Dave Barry',
};

$expect = {
  'id'          => 2,
  'title'       => $drink->{'title'},
  'description' => $drink->{'description'},
};
push @drinks, $expect;

$t->post_form_ok('/api/drink', $drink )->status_is(201)->json_content_is( $expect );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Try to add a drink missing description, title
$drink = {
  'title'       => "Bell's Porter"
};

$t->post_form_ok('/api/drink', $drink )->status_is(400)->json_content_is( [] );

$drink = {
  'description' => "A darn good porter."
};

$t->post_form_ok('/api/drink', $drink )->status_is(400)->json_content_is( [] );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Try to add milk again
$drink = {
  'title'       => "milk",
  'description' => 'It does a body good.'
};

$t->post_form_ok('/api/drink', $drink )->status_is(409)->json_content_is( [] );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test get drinks matches our running list
$t->get_ok('/api/drink')->status_is(200)->json_content_is( @drinks );

# Test get individual drinks
for my $drink ( @drinks ) {
  $t->get_ok( '/api/drink/' . $drink->{'id'} )->status_is(200)->json_content_is( $drink );
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete drink
$drink = pop @drinks;
$t->delete_ok( '/api/drink/' . $drink->{'id'} )->status_is(200)->json_content_is( $drink ); 

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test get drinks matches our running list
$t->get_ok('/api/drink')->status_is(200)->json_content_is( @drinks );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update drink
$drink = {
  'title'       => "milk",
  'description' => '"Baby mammals drink milk, and you sir, are a baby mammal." - Mark Rippetoe'
};
$expect = $drinks[0]; # Expect the old milk to be returned 

$t->put_ok( '/api/drink/1' => encode_json( $drink ) )->status_is(200)->json_content_is( $expect );

# Update the current drinks array
$drinks[0]->{'description'} = $drink->{'description'};

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add another drink
$drink = {
  'title'       => "Bell's Porter",
  'description' => "Hints of dark chocolate and freshly roasted coffee provide the focus, while hops remain in the background."
};
$expect = {
  'id'          => 3,
  'title'       => $drink->{'title'},
  'description' => $drink->{'description'},
};
push @drinks, $expect;

$t->post_form_ok('/api/drink', $drink )->status_is(201)->json_content_is( $expect );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test get drinks matches our running list
$t->get_ok('/api/drink')->status_is(200)->json_content_is( @drinks );


