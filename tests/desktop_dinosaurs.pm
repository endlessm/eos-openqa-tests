use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;
    my $sdk_nightly_repo = 'http://endlessm.github.io/eos-knowledge-lib/eos-sdk-nightly.flatpakrepo';

    check_desktop_clean();
    type_very_safely("gnome-terminal\n");
    assert_screen('desktop_terminal', 5);

    type_string("flatpak remote-add --from eos-sdk-nightly " . $sdk_nightly_repo . "\n");

    # Authenticate to Polkit Authentication Agent.
    sleep 5;
    type_string('123');
    send_key('ret');
    sleep 5;

    $self->user_console();
    assert_script_run('flatpak install -y eos-apps com.endlessm.dinosaurs.en');
    assert_script_run('flatpak install -y eos-sdk-nightly com.endlessm.apps.Platform//master', 1800);
    $self->exit_user_console();

    # Test thematic template.
    type_string("flatpak run --runtime=com.endlessm.apps.Platform//master com.endlessm.dinosaurs.en\n");

    mouse_hide();

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
