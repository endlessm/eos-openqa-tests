# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'sdktest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;
    my $app_id = 'com.endlessm.dinosaurs.en';

    check_desktop_clean();
    $self->install_app($app_id);

    # Test thematic template.
    assert_screen('dinosaurs_startup');
    type_string('extinction');
    assert_and_click('dinosaurs_search_extinction');

    # Click the back button.
    assert_and_click('dinosaurs_article_extinction');
    # Enter into a category.
    assert_and_click('dinosaurs_categories');
    # Click the search entry and search for the word 'dino'.
    assert_and_click('dinosaurs_categories_dinosaurs');
    type_string("dino");
    assert_screen('dinosaurs_search_dino');
    send_key('ret');
    assert_and_click('dinosaurs_search_result_dino');
    assert_and_click('dinosaurs_article_classification');
    # Search for an article that does not exist.
    type_string("fddfdsf");
    send_key('ret');
    assert_screen('dinosaurs_search_whatever');
    # Click the hidden credits button.
    mouse_set(902, 20);
    sleep 2;
    mouse_click();
    sleep 2;
    assert_screen('dinosaurs_credits');
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
