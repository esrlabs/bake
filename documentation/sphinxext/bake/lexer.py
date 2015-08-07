# -*- coding: utf-8 -*-
__author__ = 'Nicola Coretti'
__all__ = ['BakeLexer']

from pygments.lexer import RegexLexer
from pygments.token import  *

class BakeLexer(RegexLexer):

    name = 'bake'
    aliases = ['bake']
    filenames = ['*.meta']
    mimetypes = ['text/x-bake']

    tokens = {
        'root': [(r"'.*'", String),
                 (r'".*"', String),
                 (r'"\s*"', Whitespace),
                 (r'#.*"', Comment),
                 (r'\bProject\b', Name.Namespace),
                 (r'\bResponsible\b', Name.Namespace),
                 (r'\bExecutableConfig\b', Name.Namespace),
                 (r'\bLibraryConfig\b', Name.Namespace),
                 (r'\bCustomConfig\b', Name.Namespace),
                 (r'\bPreSteps\b', Name.Namespace),
                 (r'\bPostSteps\b', Name.Namespace),
                 (r'\bStartupSteps\b', Name.Namespace),
                 (r'\bExitSteps\b', Name.Namespace),
                 (r'\bMakefile\b', Name.Namespace),
                 (r'\bDefaultToolchain\b', Name.Namespace),
                 (r'\bCompiler\b', Name.Namespace),
                 (r'\bArchiver\b', Name.Namespace),
                 (r'\bLinker\b', Name.Namespace),
                 (r'\bToolchain\b', Name.Namespace),
                 (r'\bDescription\b', Name.Class),
                 (r'\bPerson\b', Name.Class),
                 (r'\bSet\b', Name.Class),
                 (r'\bDependency\b', Name.Class),
                 (r'\bExternalLibrary\b', Name.Class),
                 (r'\bUserLibrary\b', Name.Class),
                 (r'\bExternalLibrarySearchPath\b', Name.Class),
                 (r'\bFlags\b', Name.Class),
                 (r'\bDefine\b', Name.Class),
                 (r'\bInternalDefines\b', Name.Class),
                 (r'\bFiles\b', Name.Class),
                 (r'\bExcludeFiles\b', Name.Class),
                 (r'\bIncludeDir\b', Name.Class),
                 (r'\bLibPrefixFlags\b', Name.Class),
                 (r'\bLibPostfixFlags\b', Name.Class),
                 (r'\bLintPolicy\b', Name.Class),
                 (r'\bDocu\b', Name.Class),
                 (r'\bInternalIncludes\b', Name.Class),
                 (r'\bDefine\b', Name.Class),
                 (r'\btrue\b', Number.Bin),
                 (r'\bfalse\b', Number.Bin),
                 (r'\bon\b', Number.Bin),
                 (r'\boff\b', Number.Bin),
                 (r'\bASM\b', Keyword.Constant),
                 (r'\bCPP\b', Keyword.Constant),
                 (r'\bC\b', Keyword.Constant),
                 (r'\bDiab\b', Keyword.Constant),
                 (r'\bGCC\b', Keyword.Constant),
                 (r'\bGCC_ENV\b', Keyword.Constant),
                 (r'\bCLANG\b', Keyword.Constant),
                 (r'\bCLANG_ANALYZE\b', Keyword.Constant),
                 (r'\bTI\b', Keyword.Constant),
                 (r'\bGreenHills\b', Keyword.Constant),
                 (r'\bKeil\b', Keyword.Constant),
                 (r'\bMSVC\b', Keyword.Constant),
                 (r'\bemail\b', Operator),
                 (r'\bvalue\b', Operator),
                 (r'\benv\b', Operator),
                 (r'\bsearch\b', Operator),
                 (r'\bpathTo\b', Operator),
                 (r'\bfilter\b', Operator),
                 (r'\boutputDir\b', Operator),
                 (r'\beclipseOrder\b', Operator),
                 (r'\bcommand\b', Operator),
                 (r'\blib\b', Operator),
                 (r'\bdefault\b', Operator),
                 (r'\bconfig\b', Operator),
                 (r'\bvalidExitCodes\b', Operator),
                 (r'\btarget\b', Operator),
                 (r'\badd\b', Operator),
                 (r'\bremove\b', Operator),
                 (r'\bextends\b', Operator),
                 (r'\S+', Text),
                 (r'\s+', Whitespace),
                 (r':', Text),

            ]
        }
