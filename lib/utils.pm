# vi: set shiftwidth=4 tabstop=4 expandtab:
package utils;

use strict;

use base 'Exporter';
use Exporter;

use testapi;
our @EXPORT = qw/check_desktop_clean console_root_exit console_root_login
    console_user_exit console_user_login send_key_combo type_very_safely
    get_password/;

# Get the standard password used everywhere.
sub get_password {
    return '123';
}

# high-level 'type this string extremely safely and rather slow'
# function whose specific implementation may vary
sub type_very_safely {
    my $string = shift;
    type_string($string, wait_screen_change => 1, max_interval => 1);
    wait_still_screen 5;
}

# High level ‘type this keyboard shortcut’ utility.
# For example, send_key_combo('ctrl', 't');
sub send_key_combo {
    my $modifier = shift;
    my $key = shift;

    hold_key($modifier);
    send_key($key);
    release_key($modifier);
}

# Check we are at a ‘clean’ desktop, where we should be able to start typing
# to enter the shell’s application selector. This explicitly doesn’t match the
# icons in the icon grid, as they change often and are irrelevant to our ability
# to be able to type to select an application to launch.
sub check_desktop_clean {
    assert_screen('desktop_generic', 60);
}

# Log in to a TTY (which must already be displayed; see root_console() from the
# distribution class) and get a root console. On live images, we have to do this
# by logging in as the live user then entering a sudo session, as that’s the
# only pathway which doesn’t require any passwords.
# Use console_root_exit() to exit from it.
sub console_root_login {
    # There's a timing problem when we switch from a logged-in console
    # to a non-logged in console and immediately call this function;
    # if the switch lags a bit, this function will match one of the
    # logged-in needles for the console we switched from, and get out
    # of sync (e.g. https://openqa.stg.fedoraproject.org/tests/1664 )
    # To avoid this, we'll sleep a few seconds before starting
    wait_serial('endless login: ', timeout => 10);

    if (get_var('LIVE')) {
        # Log in as the live user, as that’s the only user who is passwordless.
        # We do not know the root password.
        type_string("live\n");
        wait_serial('live@endless:~\$ ', timeout => 10);

        # Now slip into a sudo session. On a live image this should not require
        # a password.
        type_string("sudo -i\n");
        wait_serial('root@endless:~# ', timeout => 10);
        type_string("PS1='# '\n");
        wait_serial('# ');
    } else {
        my $password = get_password();

        # If we’re not in a live session, use the standard test username.
        type_string("test\n");
        wait_serial('Password: ', timeout => 10);
        type_string($password . "\n");
        wait_serial('test@endless:~\$ ', timeout => 10);

        # Now slip into a sudo session. This will require the user’s password
        # again.
        type_string("sudo -i\n");
        wait_serial('\[sudo\] password for test: ', timeout => 10);
        type_string($password . "\n");
        wait_serial('root@endless:~# ', timeout => 10);
        type_string("PS1='# '\n");
        wait_serial('# ');
    }
}

sub console_root_exit {
    type_string('exit\n');
    wait_serial('test@endless:~\$ ', timeout => 10);
    type_string('exit\n');
    wait_serial('endless login: ', timeout => 10);
}

# Same as console_root_login(), but for a non-root user.
sub console_user_login {
    my $username = shift // 'test';
    my %args = (
        set_password => 0,
        @_);

    # There's a timing problem when we switch from a logged-in console
    # to a non-logged in console and immediately call this function;
    # if the switch lags a bit, this function will match one of the
    # logged-in needles for the console we switched from, and get out
    # of sync (e.g. https://openqa.stg.fedoraproject.org/tests/1664 )
    # To avoid this, we'll sleep a few seconds before starting
    wait_serial('endless login: ', timeout => 10);

    if (get_var('LIVE')) {
        # Log in as the live user. They are passwordless.
        type_string("live\n");
        wait_serial('live@endless:~\$ ', timeout => 10);
        type_string("PS1='$ '\n");
        wait_serial('$ ');
    } else {
        # If we’re not in a live session, use the standard test username.
        type_string($username . "\n");
        if ($args{set_password}) {
            wait_serial('New password: ');
            type_string(get_password() . "\n");
            wait_serial('Retype new password: ');
            type_string(get_password() . "\n");
        } else {
            wait_serial('Password: ', timeout => 10);
            type_string(get_password() . "\n");
        }
        wait_serial($username . '@endless:~\$ ', timeout => 10);
        type_string("PS1='$ '\n");
        wait_serial('$ ');
    }
}

sub console_user_exit {
    type_string('exit\n');
    wait_serial('endless login: ', timeout => 10);
}
