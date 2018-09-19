use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Run LibreOffice Writer and write a few things.
    type_very_safely("writer\n");
    assert_screen('libreoffice_writer_main_window', 10);

    type_string('hello world');
    assert_screen('libreoffice_writer_test_string', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
