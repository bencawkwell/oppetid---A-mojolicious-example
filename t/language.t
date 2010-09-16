use Test::More tests => 8 * 3;
use Test::Mojo;

use FindBin;
$ENV{MOJO_HOME} = "$FindBin::Bin/../";
require "$ENV{MOJO_HOME}/downtime.pl";

my @tests = (
    { '/99.9' => '/<li>(\s*)?norsk(\s*)?</li>/' },
    { '/en/99.9' => '/<li>(\s*)?english(\s*)?</li>/' },
    { '/99.9' => '/<li>(\s*)?english(\s*)?</li>/' },
    { '/no/99.9' => '/<li>(\s*)?norsk(\s*)?</li>/' },
    { '/99.9' => qr/99,9/ },
    { '/en/99.9' => qr/99.9/ },
    { '/99.9' => qr/99.9/ },
    { '/no/99.9' => qr/99,9/ },
);

my $t = Test::Mojo->new;
foreach my $test (@tests) {
    foreach (keys %$test) {
        my $path = $_;
        my $content = $test->{$_};
        $t->get_ok($path)
          ->status_is(200)
          ->content_like($content);
    }
}
