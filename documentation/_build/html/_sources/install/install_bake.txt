Install bake
============

bake is a `ruby gem <https://rubygems.org/>`_. It runs with `Ruby <https://www.ruby-lang.org/en/>`_ **>= 1.9**.
bake and its depedencies can be found on `rubygems <https://rubygems.org/gems/bake-toolkit/>`_, which is configured as ruby source per default.

.. attention::

    The actual name of the bake gem is `bake-toolkit <https://rubygems.org/gems/bake-toolkit/>`_.

How to install bake
*******************
Installing bake is very easy!

#. Make sure you have installed `Ruby <https://www.ruby-lang.org/en/>`_ **>= 1.9**.

#. Istall the bake gem.

    .. code-block:: console

        User@Host:~$ gem install bake-toolkit

Example
-------

.. code-block:: console

    User@Host:~$ ruby -v                    # (Check if an apropriate ruby version is installed)
    ruby 2.1.2p95 (2014-05-08 revision 45877) [x86_64-darwin13.0]

    User@Host:~$ gem install bake-toolkit   # (Install the bake gem)
    Fetching: highline-1.6.15.gem (100%)
    Fetching: colored-1.2.gem (100%)
    Fetching: progressbar-0.11.0.gem (100%)
    Fetching: rgen-0.6.0.gem (100%)
    Fetching: rtext-0.2.0.gem (100%)
    Fetching: bake-toolkit-1.0.2.gem (100%)
    Successfully installed highline-1.6.15
    Successfully installed colored-1.2
    Successfully installed progressbar-0.11.0
    Successfully installed rgen-0.6.0
    Successfully installed rtext-0.2.0
    Successfully installed bake-toolkit-1.0.2
    7 gems installed
    Installing ri documentation for highline-1.6.15...
    Installing ri documentation for colored-1.2...
    Installing ri documentation for progressbar-0.11.0...
    Installing ri documentation for rgen-0.6.0...
    Installing ri documentation for rtext-0.2.0...
    Installing ri documentation for bake-toolkit-1.0.2...
    Installing RDoc documentation for highline-1.6.15...
    Installing RDoc documentation for colored-1.2...
    Installing RDoc documentation for progressbar-0.11.0...
    Installing RDoc documentation for rgen-0.6.0...
    Installing RDoc documentation for rtext-0.2.0...
    Installing RDoc documentation for bake-toolkit-1.0.2...


Known Issues
************

The installation does not start
-------------------------------
**Issue:**
The installation of the bake gem does not start.
(This is often caused by a password protected internat proxy.)


**Solution:**

* Check your network connection.
* Unlock the password protected proxy by opening an external webpage (e.g. `google <https://www.google.com>`_) using your web browser.


Invalid Language Settings
-------------------------
*Issue:**
The error parsers in bake assume English language.

**Solution:**

Adjust your language settings e.g by setting the environment variable **LC_ALL**.

Example:

    ..  code-block:: console

        LC_ALL=en_US

.. note::

    Depending on the system and the compiler the way how to change the language might be different.

Error Message During the installation
-------------------------------------
**Issue:**
Ruby throws an error during the installation.

**Solution:**
Usualy you will see an error like this:

    .. code-block:: console

        ERROR:  While generating documentation for ...
        ... MESSAGE:   Error while evaluating ...
           undefined method `gsub' for nil:NilClass ...

This is a ruby bug. However, the gems were installed correctly. You can avoid building the documentation by installing bake like this:

    .. code-block:: console

        User@Host:~$ gem install bake-toolkit --no-rdoc --no-ri
