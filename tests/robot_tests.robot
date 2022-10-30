*** Settings ***
Documentation    Suite sisältää muutamia UI-testejä demoblaze.com -sivustoa vasten.
    ...    Koska speksejä ei ole -> tutkivan testauksen tyylillä on menty ja testin stepit tehty sillä ajatuksella että "näin sen minun mielestäni kuuluisi toimia jotta käyttäjäkokemus olisi mahd. hyvä".
    ...    Testitapaukset on suunniteltu ja valittu mentaliteetilla "jos minulla olisi muutama tunti aikaa tehdä testit, mitä tekisin?"
    ...    Testitapaukset on pyritty pitämään pieninä ja että ne testasivat vähän asioita tai jopa vain yhden selkeän asian/ominaisuuden.
    ...    Testeistä pyritty tekemään mahdollisimman stabiileja jotta vältyttäisiin false positive -keisseiltä.
    ...    Testit eivät riipu toisistaan jotta niitä voisi ajaa missä järjestyksessä tahansa ja jottei yksi feilannut testi aiheuttaisi ketjureaktiota.

Library     Browser    auto_closing_level=SUITE    timeout=20
Library    String
Suite Setup    Suite Setup
Suite Teardown    Close Browser
Test Setup    Test Setup
Variables    ../variables.yml


*** Test Cases ***
Should Be Able To See Product Details, Add To Cart And Remove From Cart
    [Documentation]    Test verifies that front page includes more than 3 products
    ...    and that user can add one product into the cart and empty cart
    ${product_count}    Get Element Count    //div[@id='tbodyid']/div    >    3
    Set Suite Variable    ${PRODUCT_COUNT}    ${product_count}
    ${random_product_nr}    Evaluate    random.randint(1, ${PRODUCT_COUNT})
    Click    //div[@id='tbodyid']/div[${random_product_nr}]
    Wait For Elements State    id=more-information   
    ${product_name}    Get Text    //div[@id='tbodyid']/h2
    ${promise} =    Promise To    Wait For Alert    action=accept
    Click    //a[text()[contains(.,'Add to cart')]]
    ${text} =    Wait For      ${promise}
    Should Be Equal As Strings    ${text}    Product added
    Click    id=cartur
    Wait Until Network Is Idle
    Get Element Count    //tbody[@id='tbodyid']/tr    ==    1
    Wait For Elements State    //tbody[@id='tbodyid']/tr//td >> text=${product_name}
    Click    //a[text()[contains(.,'Delete')]]
    Wait Until Keyword Succeeds    5    500ms     Get Element Count    //tbody[@id='tbodyid']/tr    ==    0

Should Be Able To Order A Product
    [Documentation]    Test verifies that user can order a product and confirmation of a successful order is given
    Click    //div[@id='tbodyid']/div[1]/div/a[1]
    Wait For Elements State    id=more-information   
    ${product_name}    Get Text    //div[@id='tbodyid']/h2
    ${promise} =    Promise To    Wait For Alert    action=accept
    Click    //a[text()[contains(.,'Add to cart')]]
    ${text} =    Wait For      ${promise}
    Should Be Equal As Strings    ${text}    Product added
    Click    id=cartur
    Wait Until Network Is Idle
    Click    //button[text()[contains(.,'Place Order')]]
    Type Text    id=name    myname
    Type Secret    id=card    123
    Click    //button[text()[contains(.,'Purchase')]]
    Wait For Elements State    text=Thank you for your purchase!

Should Validate New Message Fields
    [Documentation]    Test verifies that when sending an empty message via form, at least some information should be given and validated
    Click    //div[@id='navbarExample']//*[text()[contains(.,'Contact')]]   
    ${promise} =    Promise To    Wait For Alert    action=accept
    Click    text=Send message
    ${text} =    Wait For      ${promise}
    Should Not Be Equal As Strings    ${text}    Thanks for the message!!

 Should Fail When Signing Up Without Username And Password   
    [Documentation]    Test verifies that new account cannot be created without username and password
    Click    id=signin2
    ${promise} =    Promise To    Wait For Alert    action=accept
    Click    //button[text()[contains(.,'Sign up')]]
    ${text} =    Wait For      ${promise}
    Should Be Equal As Strings    ${text}    Please fill out Username and Password.

Should Fail When Logging In With Wrong Credentials
    [Documentation]    Test verifies that login is impossible without giving username && password
    Click    id=login2
    ${username}    Generate Random String
    ${password}    Generate Random String
    Type Text    id=loginusername    ${username}
    Type Text    id=loginpassword    ${password}
    ${promise} =    Promise To    Wait For Alert    action=accept
    Click    //button[text()[contains(.,'Log in')]]
    ${text} =    Wait For      ${promise}
    Should Be Equal As Strings    ${text}    User does not exist.

 Should Be Able To Sign Up And Log In
    [Documentation]    Test verifies that signing up is possible and created credentials can be used when logging in
    Click    id=signin2
    ${username}    Generate Random String
    ${password}    Generate Random String
    Type Text    id=sign-username    ${username}
    Type Text    id=sign-password    ${password}
    ${promise} =    Promise To    Wait For Alert    action=accept
    Click    //button[text()[contains(.,'Sign up')]]
    ${text} =    Wait For      ${promise}
    Should Be Equal As Strings    ${text}    Sign up successful.
    Wait For Elements State    id=login2
    Click    id=login2
    Type Text    id=loginusername    ${username}
    Type Text    id=loginpassword    ${password}
    Click    //button[text()[contains(.,'Log in')]]
    Wait For Elements State    id=nameofuser >> text='Welcome ${username}'

*** Keywords ***
Suite Setup
    New Browser    browser=${browser}    headless=${headless}
    New Context
    New Page    about:blank

Test Setup
    New Page    about:blank
    Go To       ${start_page}
    Wait Until Network Is Idle    timeout=10s
