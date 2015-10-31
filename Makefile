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

deps-data-suika:
	./perl bin/clone.pl mapping.txt local/suika

deps-data-hero:
	wget -O local/hero.tar "https://www.dropbox.com/s/nae4o9yt07d5enx/hero-pub-furuike.tar?dl=1"
	tar xf local/hero.tar
	mv public_html local/suika/~hero
	mv local/suika/~hero/anime/nanohaA\'s.ja.html.sjis local/suika/~hero/anime/nanohaAs.ja.html.sjis
	echo "ErrorDocument 404 /~hero/anime/nanohaAs" >> local/suika/~hero/anime/.htaccess
	echo "Redirect 302 /~hero/N88BASICdayoon/latest /~hero/N88BASICdayoon/2006/03" >> local/suika/~hero/N88BASICdayoon/.htaccess
	wget -O local/hero-contents.tar.gz "https://www.dropbox.com/s/fpsvgb10sypu2yr/hero-pub-contents.tar.gz?dl=1"
	tar zxf local/hero-contents.tar.gz
	mv hero-wiki/* local/suika/~hero/wiki/
	mv hero-diary/* local/suika/~hero/Diary/
	cat local/suika/~hero/.htaccess | \
	    grep -v "^Redirect 301 /~hero/Diary/" | \
	    grep -v "^Redirect 301 /~hero/wiki/wiki.cgi" > local/foo
	cp local/foo local/suika/~hero/.htaccess
	echo "Redirect 301 /~hero/wiki/wiki.cgi /~hero/wiki/{mypagepuny}" > local/suika/~hero/wiki/.htaccess
	echo "DirectoryIndex RecentChanges-" >> local/suika/~hero/wiki/.htaccess
	echo "ErrorDocument 404 /~hero/wiki/RecentChanges-" >> local/suika/~hero/wiki/.htaccess
	echo "RedirectMatch 301 /~hero/Diary/$ /~hero/Diary/{date}" > local/suika/~hero/Diary/.htaccess
	echo "AddType application/rdf+xml .rdf" >> local/suika/~hero/Diary/.htaccess

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

create-commit-for-heroku:
	git remote rm origin
	rm -fr modules/*/.git t t_deps deps
	rm -fr local/furuike/.git local/furuike/modules/*/.git
	rm -fr local/furuike/t local/furuike/t_deps local/furuike/deps
	rm -fr local/cpanm local/furuike/local/cpanm
	find local/suika | grep '/\.git$$' | xargs rm -fr
	rm -fr local/suika/~wakaba/art
	#git rm .gitmodules
	#git rm modules/* --cached
	#git add -f modules/*/*
	git add -f local/suika local/bin local/furuike
	git commit -m "for heroku"

deps-data-heroku:
	cd local/suika/~wakaba && \
	git init && \
	git remote add origin https://bitbucket.org/wakabatan/suika-wakaba && \
	git fetch origin && \
	git checkout origin/master
	./perl local/bin/git-set-timestamp.pl local/suika/~wakaba

## ------ Tests ------

PROVE = ./prove

test: test-deps test-main

test-deps: git-submodules pmbp-install

test-main:
	$(PROVE) t/*.t