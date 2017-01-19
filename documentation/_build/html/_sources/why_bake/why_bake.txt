Why you should use bake
========================

Whether you should use bake is entirely up to you,
just take 2 minutes and have a look at our design goals and see if they fit what you are looking for.

bake desgin goals
******************

=================================================================           ===============================================================================================
Goal                                                                        Reasoning
=================================================================           ===============================================================================================
* It must be only a built tool                                              We want to focus your energy in providing a good and fast build tool.

* It must be a command line tool                                            Sticking to the unix and single purpose phisolophy, we think proving a command line tool
                                                                            is the easiest way to be easily used and integrated with other tools. **IDE independence!**

* It must be easy to configure                                              We want the developer to be able to focus on coding and testing not on reading and searching
                                                                            hours through the build tool documentation.
                                                                            **A build tool should be easy to use and not hard to maintain!**

* The configuration must not be a meta language                             We want our configurations to be WYSIWYG (What You See Is What You Get).
                                                                            We don't want developers to spent hours in searching for a configuration error
                                                                            where are multiple other config and script generation steps are in beteween.

* It must be easy to understand configurations of large project             In large projects build configurations usually get pretty complex and big, therefore
                                                                            generally just a few people understand the build process. This makes the maintance
                                                                            dependend on those people. This is a single point of failure and
                                                                            it should be avoided in our opinion.

* It must be fast                                                           We personaly aren't fans waiting for the built, we rather build, test and then do a kicker
                                                                            break!

* It should be lightweight                                                  Lightweight here means, less depencies because depencies can hinder people to get their
                                                                            setup up and running.

* It must be easy to use different versions of the build tool               Sometimes it is necessary to break compatability to embrace progress, even though
                                                                            it should be easy to switch between different version of the tool.
=================================================================           ===============================================================================================

