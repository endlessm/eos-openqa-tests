# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Disable the desktop background so we don’t have to change all the needles
    # when the desktop background changes each release.
    $self->user_console();
    assert_script_run('gsettings set org.gnome.desktop.background picture-options none', 30);
    $self->exit_user_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
