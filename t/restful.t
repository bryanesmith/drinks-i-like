use strict;
use warnings;

use Test::More tests => 15;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../lib/server.pl";

#my $ua = Mojo::UserAgent->new;
#my $host = 'http://127.0.0.1:3000';

my $t = Test::Mojo->new;

my ( $response, $expect, $drink );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$expect = {
  'id' => 1,
  'title' => 'milk',
  'description' => '"Milk is for babies. When you grow up you have to drink beer." - Arnold Schwarzenegger',
};

$t->get_ok('/api/drink')->status_is(200)->json_content_is( $expect );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add drink
$drink = {
  'title' => 'espresso',
  'description' => '"It is inhumane, in my opinion, to force people who have a genuine medical need for coffee to wait in line behind people who apparently view it as some kind of recreational activity." - Dave Barry',
};

$expect = {
  'id' => 2,
  'title' => $drink->{'title'},
  'description' => $drink->{'description'},
};

$t->post_form_ok('/api/drink', $drink )->status_is(201)->json_content_is( $expect );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Try to add a drink missing description, title
$drink = {
  'title' => "Bell's Porter"
};

$t->post_form_ok('/api/drink', $drink )->status_is(400)->json_content_is( [] );

$drink = {
  'description' => "A darn good porter."
};

$t->post_form_ok('/api/drink', $drink )->status_is(400)->json_content_is( [] );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Try to add milk again
$drink = {
  'title' => "milk",
  'description' => 'It does a body good.'
};

$t->post_form_ok('/api/drink', $drink )->status_is(409)->json_content_is( [] );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Get drinks

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete drink

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update drink

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add another drink, and make sure has id of 2

