# vi: set shiftwidth=4 tabstop=4 expandtab:
package endlessdistribution;
use base 'distribution';

# Endless distribution class

# Distro-specific functions, that are actually part of the API
# (and it's completely up to us to implement them) should be here

# functions that can be reimplemented:
# ensure_installed
# x11_start_program
# become_root
# script_sudo
# type_password

# importing whole testapi creates circular dependency, so import only
# necessary functions from testapi
use testapi qw(check_var);

sub init() {
    my ($self) = @_;

    $self->SUPER::init();
    $self->init_consoles();
}

# initialize the consoles needed during our tests
sub init_consoles {
    my ($self) = @_;

    if (check_var('BACKEND', 'qemu')) {
        $self->add_console('root-virtio-terminal', 'virtio-terminal', {});

        $self->add_console('x11', 'tty-console', {tty => 1});
        $self->add_console('log-console', 'tty-console', {tty => 2});
        $self->add_console('user-console', 'tty-console', {tty => 3});
    }
}

1;
# vim: set sw=4 et:
