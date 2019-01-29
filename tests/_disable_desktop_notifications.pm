# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Disable desktop notification popups permanently. They can still be
    # accessed from the shell’s banner menu.
    $self->user_console();
    assert_script_run('gsettings set org.gnome.desktop.notifications show-banners false', 30);
    $self->exit_user_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
