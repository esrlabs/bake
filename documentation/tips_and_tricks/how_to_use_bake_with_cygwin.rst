How to use bake with cygwin
===========================
Why using Cygwin on Windows instead of the built-in command shell?
There is one major reason: Cygwin supports **colored output** via ansi escape sequences.
Note, that these steps differ depending on the Cygwin version, installed packages and configuration.

#. Get rid of the cygdrive prefix

    .. image:: ../_static/cygwin_mount.png
        :width: 100 %
        :scale: 50 %

    As you see, "c:" is now "/c" and not "/cygdrive/c" anymore.

    .. note::

        In newer Cygwin versions, this is not permanent. To make it permanent,
        add the following line to /etc/fstab (can be found in your Cygwin installation directory):

        .. code-block:: console

            none / cygdrive binary,posix=0,user 0 0

#. Get rid of the Cygwin ruby

    .. image:: ../_static/cygwin_ruby.png
        :width: 100 %
        :scale: 50 %

    Easiest way is to rename the Cygwin ruby, which makes the original ruby visible.
    This is only necessary if you have ruby installed in our Cygwin environment.

#. Add tty to CYGWIN option

    .. image:: ../_static/cygwin_tty.png
        :width: 100 %
        :scale: 70 %

    "tty" must be added to the CYGWIN system variable.

#. Switch to raw mode

    The ctrl-c handler in Cygwin only works for programs compiled with the correct Cygwin libs. This does not apply to
    most ruby installations. Hitting ctrl-c may interrupt the compiler, but bake does not get this signal.

    You can set the Cygwin console to raw mode:

    .. code-block:: console

        stty raw

    Now bake can read ctrl-c as raw character on stdin. Bake will abort after all subprocesses - like the running compilation steps - have returned.

#. Start the build

    Use the parameter "-a black" or "-a white" depending on the background color of your shell ("-a none" is default).
    Depending on your Cygwin installation, you have to call "bake.bat" instead of "bake". To avoid this, create an alias, e.g:

    .. code-block:: console

        alias bake=/c/Programme/_dev/Ruby192/bin/bake.bat

