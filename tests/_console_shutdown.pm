use base 'installedtest';
use strict;
use testapi;

sub run {
    my $self = shift;

    # Shut down to ensure the guest disk is clean before uploading an image of
    # it to bootstrap other tests from. We are not testing that the shutdown
    # process works or works from the UI. That can be done in separate tests if
    # needed.
    $self->root_console(tty=>4);
    script_run('poweroff', 0);
    assert_shutdown(180);
}

# This is not fatal or important, as all actual test cases have passed by the
# time this is reached.
sub test_flags {
    return { norollback => 1, ignore_failure => 1 };
}

1;
