
    * Feature Name: Command Suit Style CLI
    * Issue: 
    
# Summary
Bake needs a consistent (easy/esier to use) and extensible cli interface.

# Motivation
Over time the bake cli grew and grew and  got very cluttered, all kinds of features have been added 
in form of an option even though they are more of a "subcommand". Some features have been added 
as extra (not mentioned in documention) cli tools (most people even don't know of e.g. bakeclean, bake-format).
To name a few other issues see the list below:
* Inconsistent long, short option names (non compliant to common best practices)
* Inconsistent option value syntax  --option VALUE, --optionVALUE, --option=VALUE
  Depending on the option different formats supplying the value are supported.
* Output are unsed inconsitently (e.g. status information on stdout instead of stderr)
* Additional features (which are actually more of a subcommand) are available via option/flag
  and the help does not give any idea which --options can't work with others or have side effects
  (e.g. crc32, --install-doc, ..)
  
All this makes it increasingly harder to use and integrate bake.
Therefore the RFC is an attempt to consolidate the cli and think about a new more clear cli
which fits the current and the future needs better than the current one.

## Key Goals 
* Concistency
* Conformance with common well known CLI interrface standards/conventions
* Extensibility Mechanism
* Configuration/Defaults (Should also be supported by config file support)
  
# Detailed Design
In order to not confuse the new CLI with the old one thoughtout this document we will
call the base command name for the new CLI interface `bmake` whenever the term/command name `bake`
is used it is used to refere to the old/current cli.

## Guide-level explenation
The `bmake` cli is a command suit like `git` which means there are multiple cli commands grouped
under one major command name (`bake` / `git`).

### Example Base CLI (output of `bmake --help`)
```
A build tool for statically linked code

USAGE:
    bmake [OPTIONS] [SUBCOMMAND]

OPTIONS:
    -V, --version           Print version info and exit
        --list              List installed commands
    -v, --verbose           Use verbose output (-vv very verbose/build.rs output)
    -q, --quiet             No output printed to stdout
        --color <WHEN>      Coloring: auto, always, never  (default auto)
    -h, --help              Prints help information

SUBCOMMANDS:
    new                create a new bake package/project
    init               initalize a bake config for an existing project
    build              builds a target
    test               builds and runs tests of a target
    clean              cleans all artfiacts of a target
    run                builds and runs a target
    help               prints the help of a subcommand
    docs               opens the documentation in a browser
    metadata           prints metadata about the project and the build
    ...
```
### Subcommands
Not  all subcommands of `bmake` are built in commands, some maybe thrid party or project specific additions,
therefor to list all available subcommands one needs to use the `--list` option e.g. `bmake --list` which
will result in an output like this.

```
Installed Commands:
    new                 create a new bake package/project
    init                initalize a bake config for an existing project
    build               builds a target
    test                builds and runs tests of a target
    clean               cleans all artfiacts of a target
    run                 builds and runs a target
    help                prints the help of a subcommand
    docs                opens the documentation in a browser
    metadata            prints metadata about the project and the build
    dependency-graph    creates a .dot file of the config dependencies
    format              reformats a Project.meta file
    qacpp               runs a qacpp analysis on a specific config
    crc32               calulates the CRC32 of string (0x4C11DB7, init 0, final xor 0, input and result not reflected), used for Uid variable calculation
    ... (all commands)
```

#### Help for subcommands

To get the help of a subcommand one can either call the subcommand with -h, --help or use the help command
with the specific subcommand.

```
user@host ~$ bmake new -h
```
```
user@host ~$ bmake new --help
```

```
user@host ~$ bmake help new 
```

#### Adding a Subcommand
Can be any kind of executable file (script, binary, ...)

Requirements:
* It is executable
* It follows the naming convention `bmake-{toolname}`
* The first line of the help shows a summary sentence (which will be used in the help overview)
* It supports the -V and --version option to retrieve a version  string
* It supports -v and multiple instances of -vv / -v -v for verbosity (or ignores it/them if passed)
* It supports -q  and --quite for quite (or ignores it)
* It supports --color <WHEN> {auto, always, never} (or ignores it)
* It supports the -h and --help help flag for getting help information

### Configuration
Default values and all other configuration settings shall be adjustable follow the
following merge/application semantics from lowest prio to high prio 
(where a higher prio setting overrides the same lower prio setting):

* Defaults defined by the CLI itself
* Global Config
* User Config
* ENV
* CLI options


## Reference-level expleanation
TBD

## Migration Info/Ideas

### Flags, Commands etc. to be ported
| New Subcommand   | Old options, tools and or commands replaced moved to subcommand |
| ---------------- | ---------------------------------------------- |
| build            | --rebuild                                      |
|                  | --link-only                                    |
|                  | --compile-only                                 |
|                  | --ingore-cache                                 |
|                  |                                                |
| meta             | --compilation-db                               |
|                  | --incs-and-defs                                |
|                  | --conversion-info                              |
|                  |                                                |
| doc              | --doc                                          |
|                  | --generate-doc                                 |
|                  | --dotc                                         |
|                  | bake-doc                                       |
|                  |                                                |
| crc32            | --crc32                                        |
|                  |                                                |
| format           | bake-format                                    |
|                  |                                                |
| clean            | -c                                             |
|                  | bakeclean                                      |
|                  |                                                |
| checks           | -diab-case-check                               |

### Flags, Commands etc. to be removed

| Option, Flag, Command to be removed  | Reasoning |
| ---------------- | ---------------------------------------------- |
| --install-doc    | If installtions with and without docs are needed this should be done by the install mechanism   |
|                  | e.g. one gem with and one without docs | 
|                  |                                                |
| --license        | Should be shown in help or version or referenced extra option unnecessary |
|                  |                                                |
|  --link-beta     | There should be one common way to pass beta/experimental flags e.g -Z key=value | 
|                  | otherwise cli will be cluttered by beta/expirimental flags/options |
|                  |                                                |
|  --nb            | this is a workaround for the misuse of the output streams |
|                  | bakes output needs to be changed output -> stdout, status information -> stderr |
|                  |                                                |
|  --build_        | legacy won't be supported in new cli -> old cli can be used |
|                  |                                                |
|  --time          | there are commands already doing this -> `time` |
|                  |                                                |
|  --do  | should can be replaced by "runner" like mechnism |


## Prior Art
A Big source of inspiration for this RFC because it does lots of things right is
[cargo](cargo). I deeper look into its mechanics and solutions to specific problems
 defenetly would make sense.

# Drawbacks
TBD

# Alternatives
TBD

## Remove the old cli completely
| Pros | Cons | 
| ------------- | ---- | 
|  |  |

### Stick with the old cli
| Pros | Cons | 
| ------------- | ---- | 
|  |  |

# Unresolved Questions
* Name for the alternative "command" (cli interface) here `bmake`
* which error format is transmited via --socket <num> ?
* Finish list and mapping of old flags, options etc. to new subcommands
