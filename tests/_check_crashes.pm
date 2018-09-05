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

    $self->exit_root_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
