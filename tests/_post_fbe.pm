use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Check there are no remaining processes owned by gnome-initial-setup
    $self->root_console(tty=>4);
    assert_script_run('! ps -u gnome-initial-setup');
    $self->exit_root_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
