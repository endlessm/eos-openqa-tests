# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Test that all the installed AppData files are valid.
    # If you find that an application is installing an invalid AppData file,
    # please fix the application *and* suggest that they add their own
    # build-time `appstream-glib validate` test.

    $self->root_console();
    assert_script_run('flatpak install --system -y flathub org.freedesktop.appstream-glib');
    $self->exit_root_console();

    $self->user_console();

    $self->ensure_curl_available();

    # Run it once first to dump the output before potentially failing.
    script_run('for dir in $(echo $XDG_DATA_DIRS | tr ":" "\n"); do [[ $(compgen -G "${dir}/appdata/*.xml") ]] && flatpak run --file-forwarding org.freedesktop.appstream-glib validate @@ ${dir}/appdata/*.xml >> /var/tmp/appstream-glib-validate.log; done');
    upload_logs('/var/tmp/appstream-glib-validate.log');

    assert_script_run('for dir in $(echo $XDG_DATA_DIRS | tr ":" "\n"); do [[ $(compgen -G "${dir}/appdata/*.xml") ]] && flatpak run --file-forwarding org.freedesktop.appstream-glib validate @@ ${dir}/appdata/*.xml; done');
    $self->exit_user_console();
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
