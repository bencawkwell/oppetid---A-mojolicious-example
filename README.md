While demonstrating the benefits of Mojolicious to a friend, he asked me
to rewrite http://www.oppetid.info/ to prove that there were benfits of
this framework. This is the rewrite using Mojolicious::Lite.

Features
--------

* Uses DateTime to do the calculations

  Whether it does it correctly is up for debate.

* Uses Mojolicious::Plugin::I18n, for localisation into norwegian.

* Demonstrates using custom regex patterns on routes.

* Example use of hooks (used to determine locale from the url

* Uses session

* Adds a custom helper, and makes use of blocks in templates

* Comes with a set of tests


Installation
------------

    cpan Mojolicious
    cpan DateTime
    cpan DateTime::Format::Duration;

Then check out the code using git:

    git clone git://github.com/bencawkwell/oppetid---A-mojolicious-example.git
    cd oppetid---A-mojolicious-example

Then run the application:

    ./opptid.pl

