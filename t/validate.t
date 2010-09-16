use Test::More tests => 13 * 2;
use Test::Mojo;

use FindBin;
$ENV{MOJO_HOME} = "$FindBin::Bin/../";
require "$ENV{MOJO_HOME}/opptid.pl";

my @tests = (
    { '99.9' => 1 },
    { '99.99' => 1 },
    { '99.999' => 1 },
    { '99.9999' => 1 },
    { '99.99999' => 0 },
    { '99.' => 0 },
    { '99' => 1 },
    { '9' => 1 },
    { '09' => 0 },
    { '999' => 0 },
    { '99,9' => 1 },
    { '99,99' => 1 },
    { '0' => 0 },
);

my $t = Test::Mojo->new;
foreach my $test (@tests) {
    foreach (keys %$test) {
        my $path = '/'.$_;
        my $status = $test->{$_} ? 200 : 302;
        $t->get_ok($path)
          ->status_is($status);
    }
}
