# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;
    my $default_extra_languages = "ar;bn;en;es;fr;id;pt;th;vi;zh";
    my $extra_languages = get_var('EOS_IMAGE_FLATPAK_LOCALES', '');
    $extra_languages =~ s/\ /;/ig;

    # Test extra-languages key is present
    $self->user_console();
    if ($extra_languages eq $default_extra_languages) {
        assert_script_run('flatpak config --system --get extra-languages', 60, '*unset*');
    } elsif (!$extra_languages) {
        assert_script_run('flatpak config --system --get extra-languages', 60, $extra_languages);
    }

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
