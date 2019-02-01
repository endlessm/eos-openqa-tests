# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Enable coredumps permanently.
    $self->root_console();
    assert_script_run('eos-enable-coredumps', 30);
    $self->exit_root_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
