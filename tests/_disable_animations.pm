# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Disable UI animations so that watching for screen changes gives more
    # immediate results.
    $self->user_console();
    assert_script_run('gsettings set org.gnome.desktop.interface enable-animations false', 30);
    $self->exit_user_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
