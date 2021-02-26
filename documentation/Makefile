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
	@cp -r _build/html/. ../install-docs/
