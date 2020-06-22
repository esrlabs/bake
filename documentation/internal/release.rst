How to release
**************

Prerequisites
-----------------
- pip install sphinx
- pip install sphinx_bootstrap_theme

git code and test
-----------------

- Develop features and fixes
- Increment version (in version.rb and index.rst)
- Create documentation in "documentation" folder with "make html && ./fixBootstrap.sh"
- Adapt unittest, run with "rake test:spec"
- Commit
- Check on Travis CI and Appveyor if all builds are green
- Tag repository
- Push commits and tags

git docu
-----------------

- Copy content from install_docs (after documentation has been generated) into gh_pages branch
- Commit
- Check if docu is really updated on "esrlabs.github.io/bake"

git admin
-----------------

- Resolve issues on github
- Draft a release (click on main page on releases link)

gem
-----------------

- Build gem with "gem build bake-toolkit.gemspec"
- Push gem to rubygems

Final
-----------------

- Announce the release in bake channel (ESRLabs internal)
