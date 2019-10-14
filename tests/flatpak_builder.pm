# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Ensure we start from a logged in desktop, so we know the user’s session
    # has been set up correctly.
    check_desktop_clean();

    $self->user_console();
    assert_script_run('git clone https://github.com/flathub/org.vim.Vim.git');
    assert_script_run('git -C org.vim.Vim submodule update --init');
    assert_script_run('flatpak-builder --assumeyes --install-deps-from=flathub --install --system build org.vim.Vim/org.vim.Vim.json');
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
