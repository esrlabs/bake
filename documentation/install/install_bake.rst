Install Bake
============

bake is a ruby gem. It runs with ruby 1.9 and above.
bake and its depedencies can be found on rubygems, which is configured as ruby source per default. Type "gem sources" if you wish to check that.

Installing bake is very easy:

.. code-block:: console 

    User@Host:~$ gem install bake-toolkit

This is how the installation could look like:

.. code-block:: console 

    User@Host:~$ gem install bake-toolkit
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

* If the installation does not start, it might be a problem of a password protected internet proxy. 
    .. tip:: alter-success
        Unlock the proxy by opening an external webpage e.g. google.

* The error parsers in bake assume English language. 
    .. tip::
        It depends on the system and compiler how to switch the language. One possibility is to set the environment variable **LC_ALL**:

        ..  code-block:: console
            
            LC_ALL=en_US

* Ruby error during the installation.
    .. tip::
        don't worry if you get this ruby error:

        .. code-block:: console

            ERROR:  While generating documentation for ...
            ... MESSAGE:   Error while evaluating ...
               undefined method `gsub' for nil:NilClass ...

        This is a ruby bug. However, the gems were installed correctly. You can avoid building the documentation by installing bake like this:

        .. code-block:: console

            User@Host:~$ gem install bake-toolkit --no-rdoc --no-ri
