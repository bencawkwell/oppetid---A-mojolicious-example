use Test::More tests => 7 * (2 + 4); # @tests * ( basic_tests + keys[day,week,etc] )
use Test::Mojo;

use FindBin;
$ENV{MOJO_HOME} = "$FindBin::Bin/../";
require "$ENV{MOJO_HOME}/downtime.pl";

my @tests = (
    { '/en/2010/01/01/50' => {
        day   => [undef,12,0,0],   # [hours, minutes, seconds]
        week  => [3,12,0,0], # [days, hours, minutes, seconds]
        month => [15,12,0,0],
        year  => [182,12,0,0] }
    },
    { '/no/2010/01/01/50' => {
        day   => [undef,12,0,0],   # [hours, minutes, seconds]
        week  => [3,12,0,0], # [days, hours, minutes, seconds]
        month => [15,12,0,0],
        year  => [182,12,0,0] }
    },
    { '/en/2010/01/01/99' => {
        day   => [undef,0,14,24],   # [hours, minutes, seconds]
        week  => [0,1,40,48], # [days, hours, minutes, seconds]
        month => [0,7,26,24],
        year  => [3,15,36,0] }
    },
    { '/en/2010/01/01/99.98' => {
        day   => [undef,0,0,17],   # [hours, minutes, seconds]
        week  => [0,0,2,0], # [days, hours, minutes, seconds]
        month => [0,0,8,55],
        year  => [0,1,45,7] }
    },
    { '/no/2010/01/01/99,98' => {
        day   => [undef,0,0,17],   # [hours, minutes, seconds]
        week  => [0,0,2,0], # [days, hours, minutes, seconds]
        month => [0,0,8,55],
        year  => [0,1,45,7] }
    },
    { '/en/2010/01/01/66' => {
        day   => [undef,8,9,36],   # [hours, minutes, seconds]
        week  => [2,9,7,12], # [days, hours, minutes, seconds]
        month => [10,12,57,36],
        year  => [124,2,24,0] }
    },
    { '/en/2012/02/01/66' => {
        day   => [undef,8,9,36],   # [hours, minutes, seconds]
        week  => [2,9,7,12], # [days, hours, minutes, seconds]
        month => [9,20,38,24],
        year  => [124,10,33,36] }
    },
);

my $t = Test::Mojo->new;
foreach my $test (@tests) {
    foreach (keys %$test) {
        my $path = $_;
        my $values = $test->{$_};
        $t->get_ok($path)
          ->status_is(200);
        foreach my $key (keys %$values) {
            my ($d,$h,$m,$s) = @{$values->{$key}};
            my $regex = '/<dd>(\s*)?(.*)?'.$d.'(.*)?'.$h.'(.*)?'.$m.'(.*)?'.$s.'(.*)?(\s*)?</dd>/';
            $t->content_like($regex);
        }
    }
}
