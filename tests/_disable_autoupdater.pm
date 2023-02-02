# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    $self->root_console();

    # Disable the autoupdater timer and service to ensure that the update
    # process is entirely managed here. The service is masked because
    # eos-stage-ostree starts it directly and we don't want that.
    assert_script_run('systemctl disable --now eos-autoupdater.timer',
                      timeout => 10);
    assert_script_run('systemctl mask --now eos-autoupdater.service',
                      timeout => 30);

    # Stop eos-updater to ensure it starts from a clean state later.
    assert_script_run('systemctl stop eos-updater.service', timeout => 30);

    $self->exit_root_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
