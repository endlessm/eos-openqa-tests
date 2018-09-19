use base 'installedtest';
use strict;
use testapi;

sub run {
    my $self = shift;
    $self->root_console(tty=>4);
    $self->collect_data();
    $self->exit_root_console();
}

sub test_flags {
    return { 'ignore_failure' => 1 };
}

1;
