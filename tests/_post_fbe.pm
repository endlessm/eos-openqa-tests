# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Set a root password.
    $self->user_console();
    set_root_password();
    $self->exit_user_console();

    # Check there are no remaining processes owned by gnome-initial-setup
    $self->root_console(tty=>4);
    assert_script_run('! ps -u gnome-initial-setup');
    $self->exit_root_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
