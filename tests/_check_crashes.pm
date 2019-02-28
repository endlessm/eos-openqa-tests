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
    assert_script_run('[[ ! $(journalctl --priority emerg..crit --quiet --no-pager) ]]');

    # Check no systemd units failed to start up. This isn’t caught by the
    # test above, as systemd only emits a warning on unit failure, rather than
    # an error.
    #
    # Note: The logic is perverse here, as is-failed returns exit status 0 if
    # any units failed, and exit status 1 if all units succeeded.
    assert_script_run('! systemctl is-failed --quiet \'*\'');

    $self->exit_root_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
