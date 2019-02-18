# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Test that all of the GSettings overrides in /usr/share/glib-2.0/schemas
    # are syntactically valid.

    $self->user_console();
    assert_script_run('glib-compile-schemas --dry-run --strict /usr/share/glib-2.0/schemas/');
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