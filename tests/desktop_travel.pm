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
    sleep 5;
    type_string('123');
    sleep 2;
    send_key('ret');
    sleep 10;

    $self->user_console();
    assert_script_run('flatpak install -y eos-apps com.endlessm.travel.en');
    assert_script_run('flatpak install -y eos-sdk-nightly com.endlessm.apps.Platform//master', 1800);
    $self->exit_user_console();

    # Test thematic template.
    type_string("flatpak run --runtime=com.endlessm.apps.Platform//master com.endlessm.travel.en\n");

    mouse_hide();

    assert_and_click('travel_startup');
    assert_and_click('travel_article_uruguay');
    # Show the sidebar and open a category.
    assert_and_click('travel_categories_sidebar1');
    assert_and_click('travel_categories_africa');
    assert_and_click('travel_religious_places');
    assert_and_click('travel_article_machu_picchu');

    # Navigate through images.
    assert_and_click('travel_article_machu_picchu_image1');
    assert_screen('travel_article_machu_picchu_image2');
    send_key('right');
    assert_screen('travel_article_machu_picchu_image3');
    send_key('left');
    assert_screen('travel_article_machu_picchu_image2');
    send_key('left');
    assert_screen('travel_article_machu_picchu_image1');
    send_key('esc');
    assert_screen('travel_article_machu_picchu');

    # Search an article
    mouse_set(517, 16);
    mouse_click();
    type_string('mada');
    assert_screen('travel_search_mada');
    send_key('ret');
    assert_and_click('travel_search_mada_result');
    assert_and_click('travel_article_madagascar');

    # Search for an article that does not exist.
    type_string("fddfdsf");
    send_key('ret');

    # Go back to home.
    assert_and_click('travel_search_whatever');

    # We are in home now. Go to the page bottom.
    assert_screen('travel_home');
    # Click the hidden credits button.
    mouse_set(902, 20);
    sleep 2;
    mouse_click();
    sleep 2;
    assert_screen('travel_credits');
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
