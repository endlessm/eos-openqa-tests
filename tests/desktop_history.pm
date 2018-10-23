use base 'sdktest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;
    my $app_id = 'com.endlessm.history.en';

    check_desktop_clean();
    $self->add_nightly_sdk_repo();
    $self->install_app($app_id, run_with_nightly_sdk => 1);

    assert_screen('history_startup');
    type_string('inca');
    assert_and_click('history_search_inca');

    # Click the back button.
    assert_and_click('history_article_inca');
    # Enter into a category.
    assert_and_click('history_categories');
    # Click the search entry and search for the word 'world war'.
    assert_and_click('history_categories_old_age');
    type_string("world war");
    assert_screen('history_search_world_war');
    send_key('ret');
    assert_and_click('history_search_result_world_war');
    assert_and_click('history_article_world_war');
    # Search for an article that does not exist.
    type_string("fddfdsf");
    send_key('ret');
    assert_and_click('history_search_whatever');
    # Click the hidden credits button.
    mouse_set(902, 20);
    sleep 2;
    mouse_click();
    sleep 2;
    assert_screen('history_credits');
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
