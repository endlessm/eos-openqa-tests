# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'sdktest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;
    my $app_id = 'com.endlessm.travel.en';

    check_desktop_clean();
    $self->install_app($app_id);

    # Check the startup page is shown. Click in the centre of the content area
    # and check that an article is shown. We can’t check which article is shown,
    # as the featured articles rotate regularly.
    # To exit from the article, we click the burger menu.
    assert_and_click('travel_startup');
    assert_and_click('travel_article');

    # Show the sidebar and open a category.
    assert_and_click('travel_categories_sidebar1');
    assert_and_click('travel_categories_africa');

    # Open the article for Machu Picchu from the religious places category.
    assert_and_click('travel_archeology');
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

    # Search for an article and open it.
    mouse_set(517, 16);
    mouse_click();
    type_string('mada');
    assert_screen('travel_search_mada');
    send_key('ret');
    assert_and_click('travel_search_mada_result');
    assert_and_click('travel_article_madagascar');

    # Search for an article that does not exist. Go home afterwards.
    type_string("fddfdsf");
    send_key('ret');
    assert_and_click('travel_search_whatever');

    # We are on the home screen now.
    assert_screen('travel_startup');

    # Click the hidden credits button.
    mouse_set(902, 20);
    sleep(2);
    mouse_click();
    sleep(2);
    assert_screen('travel_credits');
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    # FIXME: This should be `fatal => 1`, but the test just doesn’t work well enough yet.
    # See: https://phabricator.endlessm.com/T24855
    return { ignore_failure => 1 };
}

1;
