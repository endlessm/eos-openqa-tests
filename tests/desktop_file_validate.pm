# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Test that all the installed .desktop files are valid.
    # If you find that an application is installing an invalid .desktop file,
    # please fix the application *and* suggest that they add their own
    # build-time `desktop-file-validate` test.

    $self->user_console();

    $self->ensure_curl_available();

    # Run it once first to dump the output before potentially failing.
    script_run('for dir in $(echo $XDG_DATA_DIRS | tr ":" "\n"); do [[ $(compgen -G "${dir}/applications/*.desktop") ]] && desktop-file-validate --no-hints ${dir}/applications/*.desktop >> /var/tmp/desktop-file-validate.log; done');
    upload_logs('/var/tmp/desktop-file-validate.log');

    assert_script_run('for dir in $(echo $XDG_DATA_DIRS | tr ":" "\n"); do [[ $(compgen -G "${dir}/applications/*.desktop") ]] && desktop-file-validate --no-hints ${dir}/applications/*.desktop; done');

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
