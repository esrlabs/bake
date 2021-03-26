Why you should use bake
=======================

Whether you should use bake is entirely up to you,
just take 2 minutes and have a look at our design goals and see if they fit what you are looking for.

bake design goals
-----------------

.. table::
    :widths: 30, 70

    +-----------------------------------+--------------------------------------------------------------+
    | Goal                              | Reasoning                                                    |
    +===================================+==============================================================+
    | It must be only a build tool      | We want to focus your energy in providing a good and fast    |
    |                                   | build tool.                                                  |
    +-----------------------------------+--------------------------------------------------------------+
    | It must be a command line tool    | Sticking to the unix and single purpose philosophy, we think |
    |                                   | proving a command line tool is the easiest way to be easily  |
    |                                   | used and integrated with other tools. **IDE independence!**  |
    +-----------------------------------+--------------------------------------------------------------+
    | It must be easy to configure      | We want the developer to be able to focus on coding and      |
    |                                   | testing, not on reading and searching hours through the      |
    |                                   | build tool documentation. **A build tool should be easy to   |
    |                                   | use and not hard to maintain!**                              |
    +-----------------------------------+--------------------------------------------------------------+
    | The configuration must not be a   | We want our configurations to be WYSIWYG (What You See Is    |
    | meta language                     | What You Get). We don't want developers to spend hours in    |
    |                                   | searching for a configuration error where multiple other     |
    |                                   | config and script generation steps are in between.           |
    +-----------------------------------+--------------------------------------------------------------+
    | The configurations of large       | In large projects, build configurations usually get pretty   |
    | projects must be easy to          | complex and big, therefore generally just a few people       |
    | understand                        | understand the build process. This makes the maintenance     |
    |                                   | dependent on those people. This is a single point of failure |
    |                                   | and it should be avoided, in our opinion.                    |
    +-----------------------------------+--------------------------------------------------------------+
    | It must be fast                   | We personally aren't fans of waiting for the build.          |
    |                                   | We rather build, test and then do a kicker break!            |
    +-----------------------------------+--------------------------------------------------------------+
    | It should be lightweight          | Lightweight here means: less dependencies, because           |
    |                                   | dependencies can hinder people from getting their setup up   |
    |                                   | and running.                                                 |
    +-----------------------------------+--------------------------------------------------------------+
    | It must be easy to use different  | Sometimes it is necessary to break compatibility to embrace  |
    | versions of the build tool        | progress, even though it should be easy to switch between    |
    |                                   | different versions of the tool.                              |
    +-----------------------------------+--------------------------------------------------------------+
