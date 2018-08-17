package utils;

use strict;

use base 'Exporter';
use Exporter;

use testapi;
our @EXPORT = qw/type_very_safely/;

# high-level 'type this string extremely safely and rather slow'
# function whose specific implementation may vary
sub type_very_safely {
    my $string = shift;
    type_string($string, wait_screen_change => 1, max_interval => 1);
    wait_still_screen 5;
}