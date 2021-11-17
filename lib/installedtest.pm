# vi: set shiftwidth=4 tabstop=4 expandtab:
package installedtest;
use base 'basetest';
use testapi;
use utils;

# Base class for tests that run on installed systems.
#
# This should be used with tests where the system is already installed: desktop
# tests, upgrade tests, and generally anything in the post-install phase.

sub root_console {
    # Switch to a default or specified TTY and log in as root.
    # Use exit_root_console() to exit.
    my $self = shift;
    my %args = (
        tty => 3, # what TTY to login to
        @_);

    send_key("ctrl-alt-f$args{tty}");
    console_root_login();
}

sub exit_root_console {
    # Exit the console and return to a UI VT so that switching back to a
    # terminal TTY for the next root_console() call is not a no-op (and hence
    # causes the display to refresh).
    console_root_exit();
    sleep(4);
    send_key("ctrl-alt-f1");

    # There's a timing problem when we switch from a logged-in console
    # to a non-logged in console and immediately call another function; just
    # like with console_root_login().
    sleep 4;
}

sub user_console {
    # Switch to a default or specified TTY and log in as a non-root user.
    # Use exit_user_console() to exit.
    my $self = shift;
    my $username = shift;
    my %args = (
        tty => 3, # what TTY to login to
        set_password => 0,
        @_);

    send_key("ctrl-alt-f$args{tty}");
    console_user_login($username, set_password => $args{set_password});
}

sub exit_user_console {
    # Exit the console and return to a UI VT so that switching back to a
    # terminal TTY for the next user_console() call is not a no-op (and hence
    # causes the display to refresh).
    console_user_exit();
    # There's a timing problem. If "sleep" is not called the test fails,
    # because it keeps in the console.
    # My theory is that after calling "console_user_exit" there is a small delay
    # to refresh the console. If we send "ctrl-alt-f1" while it is refreshing
    # the console that event will never captured and the console will be still
    # displayed.
    sleep 4;
    send_key("ctrl-alt-f1");

    # There's a timing problem when we switch from a logged-in console
    # to a non-logged in console and immediately call another function; just
    # like with console_user_login().
    sleep 4;
}

sub ensure_curl_available {
    # EOS doesn’t install curl by default, so we might have to provide our own
    # version. We can’t install it by default in EOS to fix this, as the tests
    # have to run on old versions of EOS; and there’s no point in increasing the
    # image size just for OpenQA’s sake.
    # curl is needed for upload_logs().
    # This function assumes the SUT is already at a root console.

    # Note: script_run() returns the exit code; `which` returns 1 if the command
    # isn’t found, which Perl evaluates to true. That’s why the logic looks perverse.
    if (script_run ('which curl')) {
        my $fake_curl_uri = autoinst_url . '/data/curl.py';
        script_run("wget '$fake_curl_uri' && " .
                   "mkdir -p /usr/local/bin && " .
                   "mv curl.py /usr/local/bin/curl && " .
                   "chmod +x /usr/local/bin/curl");
    }
}

sub disable_polkit_policy {
    # Creates a Polkit rule to 'disable' the rules added for a given action_id.
    my $self = shift;
    my $action_id = shift;
    my $filename = shift;

    my $policy =
        "polkit.addRule(function(action, subject) {" .
        "    if (action.id == \"$action_id\") {" .
        "        return polkit.Result.YES;" .
        "    }" .
        "});";

    $self->root_console();
    assert_script_run("echo '$policy' > /etc/polkit-1/rules.d/$filename");
    $self->exit_root_console();
}

sub remove_polkit_policy {
    my $self = shift;
    my $filename = shift;
    $self->root_console();
    assert_script_run("rm /etc/polkit-1/rules.d/$filename");
    $self->exit_root_console();
}

sub uninstall_flatpak_app {
    my $self = shift;
    my $app_id = shift;

    $self->root_console();
    assert_script_run("flatpak uninstall -y '$app_id'");
    $self->exit_root_console();
}

sub switch_user {
    my $self = shift;
    my $username = shift;
    my $password = shift;
    my $new_password = shift;

    # If $password is '', no password is required to be inputted.
    # If $new_password is not '', we expect to be prompted to change password,
    # and will set $new_password as the new password.
    $password //= get_password();
    $new_password //= '';

    # Log out.
    check_desktop_clean();
    type_very_safely("log out\n");
    assert_and_click('desktop_log_out', timeout => 10);

    # Log in as the new user. This partially reimplements assert_and_click()
    # to manually handle the match areas. We require that any needle tagged as
    # ‘gdm_user_list’ has the ‘Not Listed?’ GDM button as its second ‘match’
    # area. assert_and_click() only lets us click on the final match area in a
    # needle, which gdm_user_list needles are required to have as the default
    # admin user.
    # FIXME: https://progress.opensuse.org/issues/47222
    $matched_needle = assert_screen('gdm_user_list', 600);

    my $not_listed_area = $matched_needle->{area}->[1];
    my $x = int($not_listed_area->{x} + $not_listed_area->{w} / 2);
    my $y = int($not_listed_area->{y} + $not_listed_area->{h} / 2);
    mouse_set($x, $y);
    mouse_click('left');
    mouse_hide();

    assert_screen('gdm_username', 10);
    type_string($username);
    send_key('ret');

    if ($password != '') {
        assert_screen('gdm_password', 10);
        type_string($password);
        send_key('ret');
    }

    if ($new_password != '') {
        assert_screen('gdm_change_password', 10);
        type_string($new_password);  # Password
        send_key('ret');
        sleep(3);
        type_string($new_password);  # Confirm password
        send_key('ret');
        sleep(3);
        type_string($new_password);  # Hint
        send_key('ret');
    }

    # Check logging in was successful.
    check_desktop_clean();
}

sub collect_data {
    # Collect and upload a load of logs for debugging problems on SUTs. This
    # should be used at the end of a test, or whenever a test fails.
    # This function assumes the SUT is already at a root console.
    my $self = shift;

    $self->ensure_curl_available();

    assert_script_run('ps aux > /var/tmp/ps-aux.log');
    upload_logs('/var/tmp/ps-aux.log');

    assert_script_run('top -i -n20 -b > /var/tmp/top.log', 120);
    upload_logs('/var/tmp/top.log');

    assert_script_run('apt list --installed | sort -u > /var/tmp/packages.log');
    upload_logs('/var/tmp/packages.log');

    assert_script_run('free > /var/tmp/free.log');
    upload_logs('/var/tmp/free.log');

    assert_script_run('df > /var/tmp/df.log');
    upload_logs('/var/tmp/df.log');

    assert_script_run('systemctl --no-pager --no-legend > /var/tmp/systemd-units.log');
    upload_logs('/var/tmp/systemd-units.log');

    # Note: script_run returns the exit code, so the logic looks weird.
    # upload any core dump files caught by coredumpctl
    unless (script_run('test -n "$(ls -A /var/lib/systemd/coredump)" && tar czvf /var/tmp/coredump.tar.gz /var/lib/systemd/coredump')) {
        upload_logs('/var/tmp/coredump.tar.gz');
    }

    # Upload /var/log
    # lastlog can mess up tar sometimes and it's not much use
    assert_script_run("tar czvf /var/tmp/var_log.tar.gz --exclude='lastlog' /var/log");
    upload_logs('/var/tmp/var_log.tar.gz');

    # Run eos-diagnostics and upload its results
    # Older versions of it can fail if $DISPLAY isn’t set
    unless (script_run('eos-diagnostics /var/tmp/eos-diagnostics.txt')) {
        upload_logs('/var/tmp/eos-diagnostics.txt');
    }
}

sub post_fail_hook {
    my $self = shift;
    $self->root_console(tty=>6);
    $self->collect_data();
    $self->exit_root_console();
}

1;
