package installedtest;
use base 'basetest';
use utils;

# Base class for tests that run on installed systems.
#
# This should be used with tests where the system is already installed: desktop
# tests, upgrade tests, and generally anything in the post-install phase.

use testapi;
use utils;

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
    send_key("ctrl-alt-f1");

    # There's a timing problem when we switch from a logged-in console
    # to a non-logged in console and immediately call another function; just
    # like with console_root_login().
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

sub post_fail_hook {
    my $self = shift;

    $self->root_console(tty=>6);
    $self->ensure_curl_available();

    # Note: script_run returns the exit code, so the logic looks weird.
    # upload any core dump files caught by coredumpctl
    unless (script_run('test -n "$(ls -A /var/lib/systemd/coredump)" && tar czvf /var/tmp/coredump.tar.gz /var/lib/systemd/coredump')) {
        upload_logs('/var/tmp/coredump.tar.gz');
    }

    # Upload /var/log
    # lastlog can mess up tar sometimes and it's not much use
    unless (script_run("tar czvf /var/tmp/var_log.tar.gz --exclude='lastlog' /var/log")) {
        upload_logs('/var/tmp/var_log.tar.gz');
    }

    # Sometimes useful for diagnosing FreeIPA issues
    upload_logs('/etc/nsswitch.conf', failok=>1);

    $self->exit_root_console();
}

1;
