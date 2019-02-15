# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Disable automatic installation of Google Chrome. It pops up authentication
    # dialogues all the time, and sometimes hijacks the first instance of
    # gnome-software which a test runs (since gnome-software always runs as a
    # single process).
    $self->root_console();
    assert_script_run('echo -e "[Initial Setup]\nAutomaticInstallEnabled=false" > /etc/eos-google-chrome-helper/eos-google-chrome-helper.conf', 30);
    assert_script_run('pkill -f eos-google-chrome-installer.py || true', 30);
    assert_script_run('pkill -f gnome-software || true', 30);
    $self->exit_root_console();

}

sub test_flags {
    return { fatal => 1 };
}

1;
