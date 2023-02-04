# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;

sub run {
    my $self = shift;
    $self->root_console(tty=>4);

    # Check there are no coredumps.
    assert_script_run('[[ ! $(coredumpctl list --no-pager --no-legend --quiet) ]]');

    # Check there are no errors in the journal.
    # FIXME: Ramp this up to check emerg..err. Currently a lot of true (unfixed) positives there.
    my $journal_errors = script_output('journalctl --priority emerg..crit --quiet --no-pager');
    if ($journal_errors ne '') {
        die("There were errors in the journal:\n$journal_errors");
    }

    # Check no systemd units failed to start up. This isn’t caught by the
    # test above, as systemd only emits a warning on unit failure, rather than
    # an error. Look at the ‘systemd-units.log’ log file for a test run to see
    # a list of systemd units and their statuses (including ‘failed’).
    if (!script_run('systemctl is-system-running')) {
        my $failed_units = script_output('systemctl list-units --state=failed --quiet --no-pager');
        die("The following units are failed:\n$failed_units");
    }

    $self->exit_root_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
