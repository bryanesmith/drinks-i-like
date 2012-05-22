use strict;
use warnings;

use Test::More tests => 2;
use Mojo::UserAgent;
use Data::Dumper;

my $ua = Mojo::UserAgent->new;
my $host = 'http://127.0.0.1:3000';

my ( $response, $expect );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$expect = {
  'id' => 1,
  'title' => 'milk',
  'description' => '"Milk is for babies. When you grow up you have to drink beer." - Arnold Schwarzenegger',
};

$response = $ua->get($host . '/api/drink' )->res->json;

is_deeply( $response, $expect, 'Should be 1 drink - the default.' );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add drink
my $drink = {
  'title' => 'espresso',
  'description' => '"It is inhumane, in my opinion, to force people who have a genuine medical need for coffee to wait in line behind people who apparently view it as some kind of recreational activity." - Dave Barry',
};

$expect = {
  'id' => 2,
  'title' => $drink->{'title'},
  'description' => $drink->{'description'},
};

$response = $ua->post_form( $host . '/api/drink', $drink )->res->json;

is_deeply( $response, $expect, 'Should be drink just added.' );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Get drinks

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete drink

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update drink

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add another drink, and make sure has id of 2

