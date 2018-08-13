use strict;
use testapi;
use autotest;
use needle;

# distribution-specific implementations of expected methods
my $distri = testapi::get_var('CASEDIR') . '/lib/endlessdistribution.pm';
require $distri;
testapi::set_distribution(endlessdistribution->new());

# We only have the one test for the moment
autotest::loadtest 'tests/fbe_to_desktop.pm';

1;
