use strict;
use warnings;

use Test::More tests => 6;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../lib/server.pl";

#my $ua = Mojo::UserAgent->new;
#my $host = 'http://127.0.0.1:3000';

my $t = Test::Mojo->new;

my ( $response, $expect );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$expect = {
  'id' => 1,
  'title' => 'milk',
  'description' => '"Milk is for babies. When you grow up you have to drink beer." - Arnold Schwarzenegger',
};

$t->get_ok('/api/drink')->status_is(200)->json_content_is( $expect );

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

$t->post_form_ok('/api/drink', $drink )->status_is(200)->json_content_is( $expect );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Get drinks

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete drink

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update drink

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add another drink, and make sure has id of 2

