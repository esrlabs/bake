Socket
======

If command line option --socket is used, bake tries to connect to the given port on localhost.

send
----

Header
++++++

    .. code-block:: console

        1 Byte: Type
        4 Byte: Length (used to discard the paket if type is unknown to the listening application)

Error packet (type 0x01)
++++++++++++++++++++++++

    .. code-block:: console

        4 Byte: Length filename, project name
        x Byte: filename, project name
        4 Byte: line number (can be 0)
        1 Byte: severity (0x00 = info, 0x01 = warning, 0x02 = error, 0xFF = ok)
        x Byte: message (length = rest of packet)

Starting build packet (type 0x0A)
+++++++++++++++++++++++++++++++++

    .. code-block:: console

        4 Byte: Length project name
        x Byte: project name
        4 Byte: Length config name
        x Byte: config name
        4 Byte: number of projects in this build (greater than 0)

Building project packet
+++++++++++++++++++++++

Same as Starting build packet, except number of projects = 0

receive
-------

If a byte is received, the build will be aborted.
