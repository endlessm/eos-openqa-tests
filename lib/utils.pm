package utils;

use strict;

use base 'Exporter';
use Exporter;

use testapi;
our @EXPORT = qw/check_desktop_clean console_root_login type_very_safely/;

# high-level 'type this string extremely safely and rather slow'
# function whose specific implementation may vary
sub type_very_safely {
    my $string = shift;
    type_string($string, wait_screen_change => 1, max_interval => 1);
    wait_still_screen 5;
}

# Check we are at a ‘clean’ desktop, where we should be able to start typing
# to enter the shell’s application selector.
sub check_desktop_clean {
    assert_screen("desktop", 60);
}

# Log in to a TTY (which must already be displayed; see root_console() from the
# distribution class) and get a root console. On live images, we have to do this
# by logging in as the live user then entering a sudo session, as that’s the
# only pathway which doesn’t require any passwords.
sub console_root_login {
    # There's a timing problem when we switch from a logged-in console
    # to a non-logged in console and immediately call this function;
    # if the switch lags a bit, this function will match one of the
    # logged-in needles for the console we switched from, and get out
    # of sync (e.g. https://openqa.stg.fedoraproject.org/tests/1664 )
    # To avoid this, we'll sleep a few seconds before starting
    sleep 4;

    assert_screen('text_console_login', 10);

    if (get_var('LIVE')) {
        # Log in as the live user, as that’s the only user who is passwordless.
        # We do not know the root password.
        type_string("live\n");
        assert_screen('live_console', 30);

        # Now slip into a sudo session. On a live image this should not require
        # a password.
        type_string("sudo -s\n");
        assert_screen('root_console', 30);
    } else {
        # If we’re not in a live session, use the standard test username.
        type_string("test\n");
        sleep(1);
        type_string("123\n");
        assert_screen('test_console', 30);

        # Now slip into a sudo session. This will require the user’s password
        # again.
        type_string("sudo -s\n");
        sleep(1);
        type_string("123\n");
        assert_screen('root_console', 30);
    }
}