all:

WGET = wget
CURL = curl
GIT = git

updatenightly: local/bin/pmbp.pl
	$(CURL) -s -S -L https://gist.githubusercontent.com/wakaba/34a71d3137a52abb562d/raw/gistfile1.txt | sh
	$(GIT) add modules t_deps/modules
	perl local/bin/pmbp.pl --update
	$(GIT) add config
	$(CURL) -sSLf https://raw.githubusercontent.com/wakaba/ciconfig/master/ciconfig | RUN_GIT=1 REMOVE_UNUSED=1 perl

## ------ Setup ------

always:

deps: always
	true # dummy for make -q
ifdef PMBP_HEROKU_BUILDPACK
else
	$(MAKE) git-submodules
endif
	$(MAKE) pmbp-install
ifdef PMBP_HEROKU_BUILDPACK
else
	$(MAKE) deps-furuike deps-misc-tools deps-data
endif

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

deps-data: deps-data-suika deps-data-hero

deps-data-suika: gitrepos.htaccess
	./perl bin/clone.pl mapping.txt local/suika
	mkdir -p local/suika/gate/git/wi local/suika/gate/git/bare
	cp gitrepos.htaccess local/suika/gate/git/.htaccess
	cp git-index.html local/suika/gate/git/wi/index.html
	cp git-index.html local/suika/gate/git/bare/index.html

deps-data-hero:
	mkdir -p local
	git clone https://bitbucket.org/wakabatan/suikaweb-pubdata.git local/pubdata --depth 1
	#tar xf local/pubdata/hero-pub-furuike.tar
	tar xf local/pubdata/hero-public.tar
	mv public_html local/suika/~hero
	mv local/suika/~hero/anime/nanohaA\'s.ja.html.sjis local/suika/~hero/anime/nanohaAs.ja.html.sjis
	echo "ErrorDocument 404 /~hero/anime/nanohaAs" >> local/suika/~hero/anime/.htaccess
	echo "Redirect 302 /~hero/N88BASICdayoon/latest /~hero/N88BASICdayoon/2006/03" >> local/suika/~hero/N88BASICdayoon/.htaccess
	tar zxf local/pubdata/hero-pub-contents.tar.gz
	mv hero-wiki/* local/suika/~hero/wiki/
	mv hero-diary/* local/suika/~hero/Diary/
	cp hero.htaccess local/suika/~hero/.htaccess
	cp hero.wiki.htaccess local/suika/~hero/wiki/.htaccess
	cp hero.diary.htaccess local/suika/~hero/Diary/.htaccess

gitrepos.htaccess: gitrepos.txt gitrepos.pl
	perl gitrepos.pl < gitrepos.txt > $@

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

create-commit-for-heroku: deps
	git config --global url."https://_:$$HEROKU_API_KEY@git.heroku.com/".insteadOf git@heroku.com:
	git remote rm origin
	rm -fr modules/*/.git t t_deps deps
	rm -fr local/furuike/.git local/furuike/modules/*/.git
	rm -fr local/furuike/t local/furuike/t_deps local/furuike/deps
	rm -fr local/cpanm local/furuike/local/cpanm
	find local/suika | grep '/\.git$$' | xargs rm -fr
	rm -fr local/suika/~wakaba local/suika/~hero
	#git rm .gitmodules
	#git rm modules/* --cached
	#git add -f modules/*/*
	git add -f local/suika local/bin local/furuike
	git commit -m "for heroku"

deps-data-heroku:
	git clone https://bitbucket.org/wakabatan/suika-wakaba local/suika/~wakaba
	./perl local/bin/git-set-timestamp.pl local/suika/~wakaba

## ------ Tests ------

PROVE = ./prove

test: test-deps test-main

test-deps: git-submodules pmbp-install

test-main:
	$(PROVE) t/*.t
