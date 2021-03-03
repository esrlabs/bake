SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

.PHONY: Makefile

help: Makefile
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

fix: Makefile
	@ruby _check/main.rb --fix

%: Makefile
	@ruby _check/main.rb
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" -W $(SPHINXOPTS) $(O)
	@find ./_build/html/* -type f | sed -n 's|_build/html/||p' > ./_build/html/files.txt
	@cp -r _build/html/. ../install-docs/
