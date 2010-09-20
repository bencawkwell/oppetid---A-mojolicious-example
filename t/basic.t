use Test::More tests => 8;
use Test::Mojo;

use FindBin;
$ENV{MOJO_HOME} = "$FindBin::Bin/../";
require "$ENV{MOJO_HOME}/opptid.pl";

my $t = Test::Mojo->new;
$t->app->log->level('error');

$t->get_ok('/')
  ->status_is(302)
  ->header_like(Location => qr/^http:\/\/(.+)(:\d*)?\/99\.9$/);
$t->get_ok('/welcome')
  ->status_is(404);
$t->get_ok('/99.9')
  ->status_is(200)
  ->content_like(qr/99.9/);
