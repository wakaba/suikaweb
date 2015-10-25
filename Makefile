all:

WGET = wget
CURL = curl
GIT = git

updatenightly: local/bin/pmbp.pl
	$(CURL) -s -S -L https://gist.githubusercontent.com/wakaba/34a71d3137a52abb562d/raw/gistfile1.txt | sh
	$(GIT) add modules t_deps/modules
	perl local/bin/pmbp.pl --update
	$(GIT) add config

## ------ Setup ------

always:

deps: always
	true # dummy for make -q
ifdef PMBP_HEROKU_BUILDPACK
else
	$(MAKE) git-submodules
endif
	$(MAKE) pmbp-install deps-furuike deps-misc-tools deps-data

git-submodules:
	$(GIT) submodule update --init

PMBP_OPTIONS=

local/bin/pmbp.pl:
	mkdir -p local/bin
	$(CURL) -s -S -L https://raw.githubusercontent.com/wakaba/perl-setupenv/master/bin/pmbp.pl > $@
pmbp-upgrade: local/bin/pmbp.pl
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --update-pmbp-pl
pmbp-update: git-submodules pmbp-upgrade
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --update
pmbp-install: pmbp-upgrade
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --install \
            --create-perl-command-shortcut @perl \
            --create-perl-command-shortcut @prove

deps-data:
	./perl bin/clone.pl mapping.txt local/suika

deps-furuike:
	./perl local/bin/pmbp.pl --install-perl-app https://github.com/wakaba/furuike

deps-misc-tools: local/bin/git-set-timestamp.pl \
  local/perl-latest/pm/lib/perl5/Extras/Path/Class.pm
	./perl local/bin/pmbp.pl --install-module Path::Class

local/perl-latest/pm/lib/perl5/Extras/Path/Class.pm:
	mkdir -p local/perl-latest/pm/lib/perl5/Extras/Path
	$(WGET) -O local/perl-latest/pm/lib/perl5/Extras/Path/Class.pm https://raw.githubusercontent.com/wakaba/perl-cmdutils/master/lib/Extras/Path/Class.pm

local/bin/git-set-timestamp.pl:
	mkdir -p local/bin
	$(WGET) -O $@ https://raw.githubusercontent.com/wakaba/suika-git-tools/master/git/git-set-timestamp.pl

## ------ Tests ------

PROVE = ./prove

test: test-deps test-main

test-deps: git-submodules pmbp-install

test-main:
	$(PROVE) t/*.t