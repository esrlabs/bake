Caching
*******

The project information will be cached here: <project folder>/.bake/\*.cache.
There is one cache file for each Project.meta.

In the main project, there will be an additional global cache, which also caches e.g. the adapt or filter settings.

This is done to reduce the time for reading the project information every build. If bake recognizes an outdated cache, it will print out
a message to the console why the information has to be reread. With "--debug" you can get detailed information what is checked exactly (in case you think this feature is broken).

Note, that when loading the cache, no "glob" is made. If you (re)move a project, bake will recognize that. Sure, files may not exist anymore. But if you **add**
a project with the name of an already cached project in this dependency tree, this it not seen by bake. In this case you need to manually trigger a reread.

Rereading the configs can be enforced with "--ignore-cache".
