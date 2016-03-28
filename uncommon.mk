bin: $(PROGRAM) $(WPROGRAM)
lib: $(LIBRUBY)
dll: $(LIBRUBY_SO)

.SUFFIXES: .inc .h .c .y .i .$(DTRACE_EXT)

# V=0 quiet, V=1 verbose.  other values don't work.
V = 0
Q1 = $(V:1=)
Q = $(Q1:0=@)
ECHO0 = $(ECHO1:0=echo)
ECHO = @$(ECHO0)

UNICODE_VERSION = 7.0.0

RUBYLIB       = $(PATH_SEPARATOR)
RUBYOPT       = -
RUN_OPTS      = --disable-gems

SPEC_GIT_BASE = git://github.com/nurse
MSPEC_GIT_URL = $(SPEC_GIT_BASE)/mspec.git
RUBYSPEC_GIT_URL = $(SPEC_GIT_BASE)/rubyspec.git

SIMPLECOV_GIT_URL = git://github.com/hsbt/simplecov.git

STATIC_RUBY   = static-ruby

EXTCONF       = extconf.rb
LIBRUBY_EXTS  = ./.libruby-with-ext.time
REVISION_H    = ./.revision.time
PLATFORM_D    = ./$(PLATFORM_DIR)/.time
RDOCOUT       = $(EXTOUT)/rdoc
HTMLOUT       = $(EXTOUT)/html
CAPIOUT       = doc/capi

INITOBJS      = dmyext.$(OBJEXT) dmyenc.$(OBJEXT)
NORMALMAINOBJ = main.$(OBJEXT)
MAINOBJ       = $(NORMALMAINOBJ)
DLDOBJS	      = $(INITOBJS)
EXTSOLIBS     =
MINIOBJS      = $(ARCHMINIOBJS) miniinit.$(OBJEXT) miniprelude.$(OBJEXT)
ENC_MK        = enc.mk

COMMONOBJS    = array.$(OBJEXT) \
		bignum.$(OBJEXT) \
		class.$(OBJEXT) \
		compar.$(OBJEXT) \
		complex.$(OBJEXT) \
		dir.$(OBJEXT) \
		dln_find.$(OBJEXT) \
		encoding.$(OBJEXT) \
		enum.$(OBJEXT) \
		enumerator.$(OBJEXT) \
		error.$(OBJEXT) \
		eval.$(OBJEXT) \
		load.$(OBJEXT) \
		proc.$(OBJEXT) \
		file.$(OBJEXT) \
		gc.$(OBJEXT) \
		hash.$(OBJEXT) \
		inits.$(OBJEXT) \
		io.$(OBJEXT) \
		marshal.$(OBJEXT) \
		math.$(OBJEXT) \
		node.$(OBJEXT) \
		numeric.$(OBJEXT) \
		object.$(OBJEXT) \
		pack.$(OBJEXT) \
		parse.$(OBJEXT) \
		process.$(OBJEXT) \
		random.$(OBJEXT) \
		range.$(OBJEXT) \
		rational.$(OBJEXT) \
		re.$(OBJEXT) \
		regcomp.$(OBJEXT) \
		regenc.$(OBJEXT) \
		regerror.$(OBJEXT) \
		regexec.$(OBJEXT) \
		regparse.$(OBJEXT) \
		regsyntax.$(OBJEXT) \
		ruby.$(OBJEXT) \
		safe.$(OBJEXT) \
		signal.$(OBJEXT) \
		sprintf.$(OBJEXT) \
		st.$(OBJEXT) \
		strftime.$(OBJEXT) \
		string.$(OBJEXT) \
		struct.$(OBJEXT) \
		symbol.$(OBJEXT) \
		time.$(OBJEXT) \
		transcode.$(OBJEXT) \
		util.$(OBJEXT) \
		variable.$(OBJEXT) \
		version.$(OBJEXT) \
		compile.$(OBJEXT) \
		debug.$(OBJEXT) \
		iseq.$(OBJEXT) \
		vm.$(OBJEXT) \
		vm_dump.$(OBJEXT) \
		vm_backtrace.$(OBJEXT) \
		vm_trace.$(OBJEXT) \
		thread.$(OBJEXT) \
		cont.$(OBJEXT) \
		$(DTRACE_OBJ) \
		$(BUILTIN_ENCOBJS) \
		$(BUILTIN_TRANSOBJS) \
		$(MISSING)

EXPORTOBJS    = $(DLNOBJ) \
		localeinit.$(OBJEXT) \
		loadpath.$(OBJEXT) \
		$(COMMONOBJS)

OBJS          = $(EXPORTOBJS) prelude.$(OBJEXT)
ALLOBJS       = $(NORMALMAINOBJ) $(MINIOBJS) $(COMMONOBJS) $(INITOBJS)

GOLFOBJS      = goruby.$(OBJEXT) golf_prelude.$(OBJEXT)

DEFAULT_PRELUDES = $(GEM_PRELUDE)
PRELUDE_SCRIPTS = $(srcdir)/prelude.rb $(srcdir)/enc/prelude.rb $(DEFAULT_PRELUDES)
GEM_PRELUDE   = $(srcdir)/gem_prelude.rb
PRELUDES      = prelude.c miniprelude.c
GOLFPRELUDES  = golf_prelude.c

SCRIPT_ARGS   =	--dest-dir="$(DESTDIR)" \
		--extout="$(EXTOUT)" \
		--mflags="$(MFLAGS)" \
		--make-flags="$(MAKEFLAGS)"
EXTMK_ARGS    =	$(SCRIPT_ARGS) --extension $(EXTS) --extstatic $(EXTSTATIC) \
		--make-flags="V=$(V) MINIRUBY='$(MINIRUBY)'" --gnumake=$(gnumake) \
		--
INSTRUBY      =	$(SUDO) $(RUNRUBY) -r./$(arch)-fake $(srcdir)/tool/rbinstall.rb
INSTRUBY_ARGS =	$(SCRIPT_ARGS) \
		--data-mode=$(INSTALL_DATA_MODE) \
		--prog-mode=$(INSTALL_PROG_MODE) \
		--installed-list $(INSTALLED_LIST) \
		--mantype="$(MANTYPE)"
INSTALL_PROG_MODE = 0755
INSTALL_DATA_MODE = 0644

PRE_LIBRUBY_UPDATE = $(MINIRUBY) -e 'ARGV[1] or File.unlink(ARGV[0]) rescue nil' -- \
			$(LIBRUBY_EXTS) $(LIBRUBY_SO_UPDATE)

TESTSDIR      = $(srcdir)/test
TESTWORKDIR   = testwork

TESTRUN_SCRIPT = $(srcdir)/test.rb

BOOTSTRAPRUBY = $(BASERUBY)

COMPILE_PRELUDE = $(srcdir)/tool/generic_erb.rb $(srcdir)/template/prelude.c.tmpl

all: showflags main docs

main: showflags $(ENCSTATIC:static=lib)encs exts
	@$(NULLCMD)

.PHONY: showflags
exts enc trans: showflags
showflags:
	$(MESSAGE_BEGIN) \
	"	CC = $(CC)" \
	"	LD = $(LD)" \
	"	LDSHARED = $(LDSHARED)" \
	"	CFLAGS = $(CFLAGS)" \
	"	XCFLAGS = $(XCFLAGS)" \
	"	CPPFLAGS = $(CPPFLAGS)" \
	"	DLDFLAGS = $(DLDFLAGS)" \
	"	SOLIBS = $(SOLIBS)" \
	$(MESSAGE_END)
	-@$(CC_VERSION)

.PHONY: showconfig
showconfig:
	@$(ECHO_BEGIN) \
	$(configure_args) \
	$(ECHO_END)

exts: build-ext

EXTS_MK = exts.mk
$(EXTS_MK): $(MKFILES) all-incs $(PREP) $(RBCONFIG) $(LIBRUBY)
	$(ECHO) generating makefile $@
	$(Q)$(MINIRUBY) $(srcdir)/ext/extmk.rb --make="$(MAKE)" --command-output=$(EXTS_MK) $(EXTMK_ARGS) configure

configure-ext: $(EXTS_MK)

build-ext: $(EXTS_MK)
	$(Q)$(MAKE) -f $(EXTS_MK) $(MFLAGS) libdir="$(libdir)" LIBRUBY_EXTS=$(LIBRUBY_EXTS) \
	    ENCOBJS="$(ENCOBJS)" UPDATE_LIBRARIES=no $(EXTSTATIC)

prog: program wprogram

$(PREP): $(MKFILES)

miniruby$(EXEEXT): config.status $(ALLOBJS) $(ARCHFILE)

objs: $(ALLOBJS)

GORUBY = go$(RUBY_INSTALL_NAME)
golf: $(LIBRUBY) $(GOLFOBJS) PHONY
	$(Q) $(MAKE) $(MFLAGS) MAINOBJ="$(GOLFOBJS)" PROGRAM=$(GORUBY)$(EXEEXT) program
capi: $(CAPIOUT)/.timestamp PHONY

$(CAPIOUT)/.timestamp: Doxyfile $(PREP)
	$(Q) $(MAKEDIRS) "$(@D)"
	$(ECHO) generating capi
	-$(Q) $(DOXYGEN) -b
	$(Q) $(MINIRUBY) -e 'File.open(ARGV[0], "w"){|f| f.puts(Time.now)}' "$@"

Doxyfile: $(srcdir)/template/Doxyfile.tmpl $(PREP) $(srcdir)/tool/generic_erb.rb $(RBCONFIG)
	$(ECHO) generating $@
	$(Q) $(MINIRUBY) $(srcdir)/tool/generic_erb.rb -o $@ $(srcdir)/template/Doxyfile.tmpl \
	--srcdir="$(srcdir)" --miniruby="$(MINIRUBY)"

program: showflags $(PROGRAM)
wprogram: showflags $(WPROGRAM)
mini: PHONY miniruby$(EXEEXT)

$(PROGRAM) $(WPROGRAM): $(LIBRUBY) $(MAINOBJ) $(OBJS) $(EXTOBJS) $(SETUP) $(PREP)

$(LIBRUBY_A):	$(LIBRUBY_A_OBJS) $(MAINOBJ) $(INITOBJS) $(ARCHFILE)

$(LIBRUBY_SO):	$(OBJS) $(DLDOBJS) $(LIBRUBY_A) $(PREP) $(LIBRUBY_SO_UPDATE) $(BUILTIN_ENCOBJS)

$(LIBRUBY_EXTS):
	@exit > $@

$(STATIC_RUBY)$(EXEEXT): $(MAINOBJ) $(DLDOBJS) $(EXTOBJS) $(LIBRUBY_A)
	$(Q)$(RM) $@
	$(PURIFY) $(CC) $(MAINOBJ) $(DLDOBJS) $(EXTOBJS) $(LIBRUBY_A) $(MAINLIBS) $(EXTLIBS) $(LIBS) $(OUTFLAG)$@ $(LDFLAGS) $(XLDFLAGS)

ruby.imp: $(COMMONOBJS)
	$(Q)$(NM) -Pgp $(COMMONOBJS) | \
	awk 'BEGIN{print "#!"}; $$2~/^[BDT]$$/&&$$1!~/^(Init_|.*_threadptr_|\.)/{print $$1}' | \
	sort -u -o $@

install: install-$(INSTALLDOC)
docs: $(DOCTARGETS)
pkgconfig-data: $(ruby_pc)
$(ruby_pc): $(srcdir)/template/ruby.pc.in config.status

install-all: docs pre-install-all do-install-all post-install-all
pre-install-all:: all pre-install-local pre-install-ext pre-install-doc
do-install-all: pre-install-all
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=all --rdoc-output="$(RDOCOUT)"
post-install-all:: post-install-local post-install-ext post-install-doc
	@$(NULLCMD)

install-nodoc: pre-install-nodoc do-install-nodoc post-install-nodoc
pre-install-nodoc:: pre-install-local pre-install-ext
do-install-nodoc: main pre-install-nodoc
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS)
post-install-nodoc:: post-install-local post-install-ext

install-local: pre-install-local do-install-local post-install-local
pre-install-local:: pre-install-bin pre-install-lib pre-install-man
do-install-local: $(PROGRAM) pre-install-local
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=local
post-install-local:: post-install-bin post-install-lib post-install-man

install-ext: pre-install-ext do-install-ext post-install-ext
pre-install-ext:: pre-install-ext-arch pre-install-ext-comm
do-install-ext: exts pre-install-ext
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext
post-install-ext:: post-install-ext-arch post-install-ext-comm

install-arch: pre-install-arch do-install-arch post-install-arch
pre-install-arch:: pre-install-bin pre-install-ext-arch
do-install-arch: main do-install-arch
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=arch
post-install-arch:: post-install-bin post-install-ext-arch

install-comm: pre-install-comm do-install-comm post-install-comm
pre-install-comm:: pre-install-lib pre-install-ext-comm pre-install-man
do-install-comm: $(PREP) pre-install-comm
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=lib --install=ext-comm --install=man
post-install-comm:: post-install-lib post-install-ext-comm post-install-man

install-bin: pre-install-bin do-install-bin post-install-bin
pre-install-bin:: install-prereq
do-install-bin: $(PROGRAM) pre-install-bin
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=bin
post-install-bin::
	@$(NULLCMD)

install-lib: pre-install-lib do-install-lib post-install-lib
pre-install-lib:: install-prereq
do-install-lib: $(PREP) pre-install-lib
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=lib
post-install-lib::
	@$(NULLCMD)

install-ext-comm: pre-install-ext-comm do-install-ext-comm post-install-ext-comm
pre-install-ext-comm:: install-prereq
do-install-ext-comm: exts pre-install-ext-comm
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext-comm
post-install-ext-comm::
	@$(NULLCMD)

install-ext-arch: pre-install-ext-arch do-install-ext-arch post-install-ext-arch
pre-install-ext-arch:: install-prereq
do-install-ext-arch: exts pre-install-ext-arch
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext-arch
post-install-ext-arch::
	@$(NULLCMD)

install-man: pre-install-man do-install-man post-install-man
pre-install-man:: install-prereq
do-install-man: $(PREP) pre-install-man
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=man
post-install-man::
	@$(NULLCMD)

install-capi: capi pre-install-capi do-install-capi post-install-capi
pre-install-capi:: install-prereq
do-install-capi: $(PREP) pre-install-capi
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=capi
post-install-capi::
	@$(NULLCMD)

what-where: no-install
no-install: no-install-$(INSTALLDOC)
what-where-all: no-install-all
no-install-all: pre-no-install-all dont-install-all post-no-install-all
pre-no-install-all:: pre-no-install-local pre-no-install-ext pre-no-install-doc
dont-install-all: $(PROGRAM)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=all --rdoc-output="$(RDOCOUT)"
post-no-install-all:: post-no-install-local post-no-install-ext post-no-install-doc
	@$(NULLCMD)

uninstall: $(INSTALLED_LIST) sudo-precheck
	$(Q)$(SUDO) $(MINIRUBY) $(srcdir)/tool/rbuninstall.rb --destdir=$(DESTDIR) $(INSTALLED_LIST)

reinstall: all uninstall install

what-where-nodoc: no-install-nodoc
no-install-nodoc: pre-no-install-nodoc dont-install-nodoc post-no-install-nodoc
pre-no-install-nodoc:: pre-no-install-local pre-no-install-ext
dont-install-nodoc:  $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS)
post-no-install-nodoc:: post-no-install-local post-no-install-ext

what-where-local: no-install-local
no-install-local: pre-no-install-local dont-install-local post-no-install-local
pre-no-install-local:: pre-no-install-bin pre-no-install-lib pre-no-install-man
dont-install-local: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=local
post-no-install-local:: post-no-install-bin post-no-install-lib post-no-install-man

what-where-ext: no-install-ext
no-install-ext: pre-no-install-ext dont-install-ext post-no-install-ext
pre-no-install-ext:: pre-no-install-ext-arch pre-no-install-ext-comm
dont-install-ext: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext
post-no-install-ext:: post-no-install-ext-arch post-no-install-ext-comm

what-where-arch: no-install-arch
no-install-arch: pre-no-install-arch dont-install-arch post-no-install-arch
pre-no-install-arch:: pre-no-install-bin pre-no-install-ext-arch
dont-install-arch: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=bin --install=ext-arch
post-no-install-arch:: post-no-install-lib post-no-install-man post-no-install-ext-arch

what-where-comm: no-install-comm
no-install-comm: pre-no-install-comm dont-install-comm post-no-install-comm
pre-no-install-comm:: pre-no-install-lib pre-no-install-ext-comm pre-no-install-man
dont-install-comm: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=lib --install=ext-comm --install=man
post-no-install-comm:: post-no-install-lib post-no-install-ext-comm post-no-install-man

what-where-bin: no-install-bin
no-install-bin: pre-no-install-bin dont-install-bin post-no-install-bin
pre-no-install-bin:: install-prereq
dont-install-bin: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=bin
post-no-install-bin::
	@$(NULLCMD)

what-where-lib: no-install-lib
no-install-lib: pre-no-install-lib dont-install-lib post-no-install-lib
pre-no-install-lib:: install-prereq
dont-install-lib: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=lib
post-no-install-lib::
	@$(NULLCMD)

what-where-ext-comm: no-install-ext-comm
no-install-ext-comm: pre-no-install-ext-comm dont-install-ext-comm post-no-install-ext-comm
pre-no-install-ext-comm:: install-prereq
dont-install-ext-comm: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext-comm
post-no-install-ext-comm::
	@$(NULLCMD)

what-where-ext-arch: no-install-ext-arch
no-install-ext-arch: pre-no-install-ext-arch dont-install-ext-arch post-no-install-ext-arch
pre-no-install-ext-arch:: install-prereq
dont-install-ext-arch: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext-arch
post-no-install-ext-arch::
	@$(NULLCMD)

what-where-man: no-install-man
no-install-man: pre-no-install-man dont-install-man post-no-install-man
pre-no-install-man:: install-prereq
dont-install-man: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=man
post-no-install-man::
	@$(NULLCMD)

install-doc: rdoc pre-install-doc do-install-doc post-install-doc
pre-install-doc:: install-prereq
do-install-doc: $(PROGRAM) pre-install-doc
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=rdoc --rdoc-output="$(RDOCOUT)"
post-install-doc::
	@$(NULLCMD)

install-gem: pre-install-gem do-install-gem post-install-gem
pre-install-gem:: pre-install-bin pre-install-lib pre-install-man
do-install-gem: $(PROGRAM) pre-install-gem
	$(INSTRUBY) --make="$(MAKE)" $(INSTRUBY_ARGS) --install=gem
post-install-gem::
	@$(NULLCMD)

rdoc: PHONY main
	@echo Generating RDoc documentation
	$(Q) $(XRUBY) "$(srcdir)/bin/rdoc" --root "$(srcdir)" --page-dir "$(srcdir)/doc" --encoding=UTF-8 --no-force-update --all --ri --op "$(RDOCOUT)" --debug $(RDOCFLAGS) "$(srcdir)"

html: PHONY main
	@echo Generating RDoc HTML files
	$(Q) $(XRUBY) "$(srcdir)/bin/rdoc" --root "$(srcdir)" --page-dir "$(srcdir)/doc" --encoding=UTF-8 --no-force-update --all --op "$(HTMLOUT)" --debug $(RDOCFLAGS) "$(srcdir)"

rdoc-coverage: PHONY main
	@echo Generating RDoc coverage report
	$(Q) $(XRUBY) "$(srcdir)/bin/rdoc" --root "$(srcdir)" --encoding=UTF-8 --all --quiet -C $(RDOCFLAGS) "$(srcdir)"

RDOCBENCHOUT=/tmp/rdocbench

GCBENCH_ITEM=null

gcbench: PHONY
	$(Q) $(XRUBY) "$(srcdir)/benchmark/gc/gcbench.rb" $(GCBENCH_ITEM)

gcbench-rdoc: PHONY
	$(Q) $(XRUBY) "$(srcdir)/benchmark/gc/gcbench.rb" rdoc

nodoc: PHONY

what-where-doc: no-install-doc
no-install-doc: pre-no-install-doc dont-install-doc post-no-install-doc
pre-no-install-doc:: install-prereq
dont-install-doc:: $(PREP)
	$(INSTRUBY) -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=rdoc --rdoc-output="$(RDOCOUT)"
post-no-install-doc::
	@$(NULLCMD)

CLEAR_INSTALLED_LIST = clear-installed-list

install-prereq: $(CLEAR_INSTALLED_LIST) yes-fake sudo-precheck PHONY

clear-installed-list: PHONY
	@> $(INSTALLED_LIST) set MAKE="$(MAKE)"

clean: clean-ext clean-local clean-enc clean-golf clean-rdoc clean-capi clean-extout clean-platform
clean-local:: clean-runnable
	$(Q)$(RM) $(OBJS) $(MINIOBJS) $(MAINOBJ) $(LIBRUBY_A) $(LIBRUBY_SO) $(LIBRUBY) $(LIBRUBY_ALIASES)
	$(Q)$(RM) $(PROGRAM) $(WPROGRAM) miniruby$(EXEEXT) dmyext.$(OBJEXT) dmyenc.$(OBJEXT) $(ARCHFILE) .*.time
	$(Q)$(RM) y.tab.c y.output encdb.h transdb.h config.log rbconfig.rb $(ruby_pc) probes.h probes.$(OBJEXT) probes.stamp ruby-glommed.$(OBJEXT)
	$(Q)$(RM) GNUmakefile.old Makefile.old $(arch)-fake.rb
clean-runnable:: PHONY
	$(Q)$(CHDIR) bin 2>$(NULL) && $(RM) $(PROGRAM) $(WPROGRAM) $(GORUBY)$(EXEEXT) bin/*.$(DLEXT) 2>$(NULL) || exit 0
	$(Q)$(CHDIR) lib 2>$(NULL) && $(RM) $(LIBRUBY_A) $(LIBRUBY) $(LIBRUBY_ALIASES) $(RUBY_BASE_NAME)/$(RUBY_PROGRAM_VERSION) $(RUBY_BASE_NAME)/vendor_ruby 2>$(NULL) || exit 0
	$(Q)$(RMDIR) lib/$(RUBY_BASE_NAME) lib bin 2>$(NULL) || exit 0
clean-ext:: PHONY
clean-golf: PHONY
	$(Q)$(RM) $(GORUBY)$(EXEEXT) $(GOLFOBJS)
clean-rdoc: PHONY
clean-html: PHONY
clean-capi: PHONY
clean-platform: PHONY
clean-extout: PHONY
	-$(Q)$(RMDIR) $(EXTOUT)/$(arch) $(EXTOUT) 2> $(NULL) || exit 0
clean-docs: clean-rdoc clean-html clean-capi

distclean: distclean-ext distclean-local distclean-enc distclean-golf distclean-extout distclean-platform
distclean-local:: clean-local
	$(Q)$(RM) $(MKFILES) yasmdata.rb *.inc $(arch)-fake.rb
	$(Q)$(RM) config.cache config.status config.status.lineno
	$(Q)$(RM) *~ *.bak *.stackdump core *.core gmon.out $(PREP)
distclean-ext:: PHONY
distclean-golf: clean-golf
distclean-rdoc: PHONY
distclean-html: PHONY
distclean-capi: PHONY
distclean-extout: clean-extout
distclean-platform: clean-platform

realclean:: realclean-ext realclean-local realclean-enc realclean-golf realclean-extout
realclean-local:: distclean-local
	$(Q)$(RM) parse.c parse.h lex.c newline.c $(PRELUDES) revision.h
	$(Q)$(CHDIR) $(srcdir) && $(exec) $(RM) parse.c parse.h lex.c newline.c $(PRELUDES) revision.h
	$(Q)$(CHDIR) $(srcdir) && $(exec) $(RM) configure tool/config.guess tool/config.sub gems/*.gem
realclean-ext:: PHONY
realclean-golf: distclean-golf
	$(Q)$(RM) $(GOLFPRELUDES)
realclean-capi: PHONY
realclean-extout: distclean-extout

clean-ext distclean-ext realclean-ext::
	$(Q)$(RM) $(EXTS_MK)
	$(Q)$(RM) $(EXTOUT)/.timestamp/.*.time
	$(Q)$(RMDIR) $(EXTOUT)/.timestamp 2> $(NULL) || exit 0

clean-enc distclean-enc realclean-enc: PHONY

clean-rdoc distclean-rdoc realclean-rdoc:
	@echo $(@:-rdoc=ing) rdoc
	$(Q)$(RMALL) $(RDOCOUT)

clean-html distclean-html realclean-html:
	@echo $(@:-html=ing) HTML
	$(Q)$(RMALL) $(HTMLOUT)

clean-capi distclean-capi realclean-capi:
	@echo $(@:-capi=ing) capi
	$(Q)$(RMALL) $(CAPIOUT)

clean-platform:
	$(Q) $(RM) $(PLATFORM_D)
	-$(Q) $(RMDIR) $(PLATFORM_DIR) 2> $(NULL) || exit 0

check: main test test-all
	$(ECHO) check succeeded
check-ruby: test test-ruby

fake: $(CROSS_COMPILING)-fake
yes-fake: $(arch)-fake.rb $(RBCONFIG) PHONY
no-fake: PHONY

btest: $(TEST_RUNNABLE)-btest
no-btest: PHONY
yes-btest: fake miniruby$(EXEEXT) PHONY
	$(BOOTSTRAPRUBY) "$(srcdir)/bootstraptest/runner.rb" --ruby="$(BTESTRUBY) $(RUN_OPTS)" $(OPTS) $(TESTOPTS)

btest-ruby: $(TEST_RUNNABLE)-btest-ruby
no-btest-ruby: PHONY
yes-btest-ruby: prog PHONY
	$(Q)$(RUNRUBY) "$(srcdir)/bootstraptest/runner.rb" --ruby="$(PROGRAM) -I$(srcdir)/lib $(RUN_OPTS)" -q $(OPTS) $(TESTOPTS)

test-sample: $(TEST_RUNNABLE)-test-sample
no-test-sample: PHONY
yes-test-sample: prog PHONY
	$(Q)$(RUNRUBY) $(srcdir)/tool/rubytest.rb --run-opt=$(RUN_OPTS) $(OPTS) $(TESTOPTS)

test-knownbugs: test-knownbug
test-knownbug: $(TEST_RUNNABLE)-test-knownbug
no-test-knownbug: PHONY
yes-test-knownbug: prog PHONY
	-$(RUNRUBY) "$(srcdir)/bootstraptest/runner.rb" --ruby="$(PROGRAM) $(RUN_OPTS)" $(OPTS) $(TESTOPTS) $(srcdir)/KNOWNBUGS.rb

test: test-sample btest-ruby test-knownbug

test-all: $(TEST_RUNNABLE)-test-all
yes-test-all: prog PHONY
	$(RUNRUBY) "$(srcdir)/test/runner.rb" --ruby="$(RUNRUBY)" $(TESTOPTS) $(TESTS)
TESTS_BUILD = mkmf
no-test-all: PHONY
	$(MINIRUBY) -I"$(srcdir)/lib" "$(srcdir)/test/runner.rb" $(TESTOPTS) $(TESTS_BUILD)

test-ruby: $(TEST_RUNNABLE)-test-ruby
no-test-ruby: PHONY
yes-test-ruby: prog encs PHONY
	$(RUNRUBY) "$(srcdir)/test/runner.rb" -q $(TESTOPTS) -- ruby -ext-

extconf: $(PREP)
	$(Q) $(MAKEDIRS) "$(EXTCONFDIR)"
	$(RUNRUBY) -C "$(EXTCONFDIR)" $(EXTCONF) $(EXTCONFARGS)

$(RBCONFIG): $(srcdir)/tool/mkconfig.rb config.status $(srcdir)/version.h $(PREP)
	$(Q)$(MINIRUBY) $(srcdir)/tool/mkconfig.rb -timestamp=$@ \
		-install_name=$(RUBY_INSTALL_NAME) \
		-so_name=$(RUBY_SO_NAME) rbconfig.rb

test-rubyspec-precheck:

test-rubyspec: test-rubyspec-precheck
	$(RUNRUBY) $(srcdir)/spec/mspec/bin/mspec run -B $(srcdir)/spec/default.mspec $(MSPECOPT)

RUNNABLE = $(LIBRUBY_RELATIVE:no=un)-runnable
runnable: $(RUNNABLE) prog $(srcdir)/tool/mkrunnable.rb PHONY
	$(Q) $(MINIRUBY) $(srcdir)/tool/mkrunnable.rb -v $(EXTOUT)
yes-runnable: PHONY

encs: enc trans
libencs: libenc libtrans
encs enc trans libencs libenc libtrans: showflags $(ENC_MK) $(LIBRUBY) $(PREP) PHONY
	$(ECHO) making $@
	$(Q) $(MAKE) -f $(ENC_MK) V="$(V)" \
		RUBY="$(MINIRUBY)" MINIRUBY="$(MINIRUBY)" \
		$(MFLAGS) $@


libenc enc: encdb.h
libtrans trans: transdb.h

$(ENC_MK): $(srcdir)/enc/make_encmake.rb $(srcdir)/enc/Makefile.in $(srcdir)/enc/depend \
	$(srcdir)/enc/encinit.c.erb $(srcdir)/lib/mkmf.rb $(RBCONFIG)
	$(ECHO) generating $@
	$(Q) $(MINIRUBY) $(srcdir)/enc/make_encmake.rb --builtin-encs="$(BUILTIN_ENCOBJS)" --builtin-transes="$(BUILTIN_TRANSOBJS)" --module$(ENCSTATIC) $@ $(ENCS)

.PRECIOUS: $(MKFILES)

.PHONY: PHONY all fake prereq incs srcs preludes help
.PHONY: test install install-nodoc install-doc dist
.PHONY: loadpath golf capi rdoc install-prereq clear-installed-list
.PHONY: clean clean-ext clean-local clean-enc clean-golf clean-rdoc clean-html clean-extout
.PHONY: distclean distclean-ext distclean-local distclean-enc distclean-golf distclean-extout
.PHONY: realclean realclean-ext realclean-local realclean-enc realclean-golf realclean-extout
.PHONY: check test test-all btest btest-ruby test-sample test-knownbug
.PHONY: run runruby parse benchmark benchmark-each tbench gdb gdb-ruby
.PHONY: update-mspec update-rubyspec test-rubyspec

PHONY:

parse.c: parse.y $(srcdir)/tool/ytab.sed id.h
parse.h: parse.c

.y.c:
	$(ECHO) generating $@
	$(Q)$(BASERUBY) $(srcdir)/tool/id2token.rb --path-separator=.$(PATH_SEPARATOR)./ --vpath=$(VPATH) id.h $(SRC_FILE) > parse.tmp.y
	$(Q)$(YACC) -d $(YFLAGS) -o y.tab.c parse.tmp.y
	$(Q)$(RM) parse.tmp.y
	$(Q)sed -f $(srcdir)/tool/ytab.sed -e "/^#/s!parse\.tmp\.[iy]!parse.y!" -e "/^#/s!y\.tab\.c!$@!" y.tab.c > $@.new
	$(Q)$(MV) $@.new $@
	$(Q)sed -e "/^#line.*y\.tab\.h/d;/^#line.*parse.*\.y/d" y.tab.h > $(@:.c=.h)
	$(Q)$(RM) y.tab.c y.tab.h

$(PLATFORM_D):
	$(Q) $(MAKEDIRS) $(PLATFORM_DIR)
	@exit > $@

###
CCAN_DIR = ccan

RUBY_H_INCLUDES    = ruby.h config.h defines.h \
		     intern.h missing.h st.h \
		     subst.h

###

acosh.$(OBJEXT): acosh.c
alloca.$(OBJEXT): alloca.c config.h
crypt.$(OBJEXT): crypt.c
dup2.$(OBJEXT): dup2.c
erf.$(OBJEXT): erf.c
finite.$(OBJEXT): finite.c
flock.$(OBJEXT): flock.c
memcmp.$(OBJEXT): memcmp.c
memmove.$(OBJEXT): memmove.c
mkdir.$(OBJEXT): mkdir.c
setproctitle.$(OBJEXT): setproctitle.c
strchr.$(OBJEXT): strchr.c
strdup.$(OBJEXT): strdup.c
strerror.$(OBJEXT): strerror.c
strlcat.$(OBJEXT): strlcat.c
strlcpy.$(OBJEXT): strlcpy.c
strstr.$(OBJEXT): strstr.c
strtod.$(OBJEXT): strtod.c
strtol.$(OBJEXT): strtol.c
nt.$(OBJEXT): nt.c
os2.$(OBJEXT): os2.c
dl_os2.$(OBJEXT): dl_os2.c
ia64.$(OBJEXT): ia64.s
	$(CC) $(CFLAGS) -c $<

###

# dependencies for generated C sources.
parse.$(OBJEXT): parse.c
miniprelude.$(OBJEXT): miniprelude.c
prelude.$(OBJEXT): prelude.c

# dependencies for optional sources.
compile.$(OBJEXT): opt_sc.inc optunifs.inc

win32/win32.$(OBJEXT): win32/win32.c dln.h dln_find.c \
  internal.h $(RUBY_H_INCLUDES) $(PLATFORM_D)
win32/file.$(OBJEXT): win32/file.c $(RUBY_H_INCLUDES) $(PLATFORM_D)

$(NEWLINE_C): $(srcdir)/enc/trans/newline.trans $(srcdir)/tool/transcode-tblgen.rb
	$(Q) $(BASERUBY) "$(srcdir)/tool/transcode-tblgen.rb" -vo $@ $(srcdir)/enc/trans/newline.trans
newline.$(OBJEXT): $(NEWLINE_C)

verconf.h: $(srcdir)/template/verconf.h.tmpl $(srcdir)/tool/generic_erb.rb
	$(ECHO) creating $@
	$(Q) $(MINIRUBY) "$(srcdir)/tool/generic_erb.rb" -o $@ $(srcdir)/template/verconf.h.tmpl

ruby-glommed.$(OBJEXT): $(OBJS)

$(OBJS):  config.h missing.h

INSNS2VMOPT = --srcdir="$(srcdir)"

minsns.inc: $(srcdir)/template/minsns.inc.tmpl

opt_sc.inc: $(srcdir)/template/opt_sc.inc.tmpl

optinsn.inc: $(srcdir)/template/optinsn.inc.tmpl

optunifs.inc: $(srcdir)/template/optunifs.inc.tmpl

insns.inc: $(srcdir)/template/insns.inc.tmpl

insns_info.inc: $(srcdir)/template/insns_info.inc.tmpl

vmtc.inc: $(srcdir)/template/vmtc.inc.tmpl

vm.inc: $(srcdir)/template/vm.inc.tmpl

common-srcs: parse.c lex.c newline.c id.c \
	     srcs-lib srcs-ext

srcs: common-srcs srcs-enc

EXT_SRCS = $(srcdir)/ext/ripper/ripper.c \
	   $(srcdir)/ext/rbconfig/sizeof/sizes.c

srcs-ext: $(EXT_SRCS)

srcs-extra: $(srcdir)/ext/json/parser/parser.c

LIB_SRCS = $(srcdir)/lib/unicode_normalize/tables.rb

srcs-lib: $(LIB_SRCS)

srcs-enc: $(ENC_MK)
	$(ECHO) making srcs under enc
	$(Q) $(MAKE) -f $(ENC_MK) RUBY="$(MINIRUBY)" MINIRUBY="$(MINIRUBY)" $(MFLAGS) srcs

all-incs: incs encdb.h transdb.h
incs: $(INSNS) node_name.inc known_errors.inc \
      $(srcdir)/revision.h $(REVISION_H) enc/unicode/name2ctype.h enc/jis/props.h \
      id.h probes.dmyh

insns: $(INSNS)

id.h: $(srcdir)/tool/generic_erb.rb $(srcdir)/template/id.h.tmpl $(srcdir)/defs/id.def
	$(ECHO) generating $@
	$(Q) $(BASERUBY) $(srcdir)/tool/generic_erb.rb --output=$@ \
		$(srcdir)/template/id.h.tmpl

id.c: $(srcdir)/tool/generic_erb.rb $(srcdir)/template/id.c.tmpl $(srcdir)/defs/id.def
	$(ECHO) generating $@
	$(Q) $(BASERUBY) $(srcdir)/tool/generic_erb.rb --output=$@ \
		$(srcdir)/template/id.c.tmpl

node_name.inc: node.h
	$(ECHO) generating $@
	$(Q) $(BASERUBY) -n $(srcdir)/tool/node_name.rb < $? > $@

encdb.h: $(PREP) $(srcdir)/tool/generic_erb.rb $(srcdir)/template/encdb.h.tmpl
	$(ECHO) generating $@
	$(Q) $(MINIRUBY) $(srcdir)/tool/generic_erb.rb -c -o $@ $(srcdir)/template/encdb.h.tmpl $(srcdir)/enc enc

transdb.h: $(PREP) srcs-enc $(srcdir)/tool/generic_erb.rb $(srcdir)/template/transdb.h.tmpl
	$(ECHO) generating $@
	$(Q) $(MINIRUBY) $(srcdir)/tool/generic_erb.rb -c -o $@ $(srcdir)/template/transdb.h.tmpl $(srcdir)/enc/trans enc/trans

enc/encinit.c: $(ENC_MK) $(srcdir)/enc/encinit.c.erb

known_errors.inc: $(srcdir)/template/known_errors.inc.tmpl $(srcdir)/defs/known_errors.def
	$(ECHO) generating $@
	$(Q) $(BASERUBY) $(srcdir)/tool/generic_erb.rb -c -o $@ $(srcdir)/template/known_errors.inc.tmpl $(srcdir)/defs/known_errors.def

$(MINIPRELUDE_C): $(COMPILE_PRELUDE)
	$(ECHO) generating $@
	$(Q) $(BASERUBY) $(srcdir)/tool/generic_erb.rb -I$(srcdir) -o $@ \
		$(srcdir)/template/prelude.c.tmpl

$(PRELUDE_C): $(COMPILE_PRELUDE) \
	   lib/rubygems/defaults.rb \
	   lib/rubygems/core_ext/kernel_gem.rb \
	   $(PRELUDE_SCRIPTS) $(LIB_SRCS)
	$(ECHO) generating $@
	$(Q) $(BASERUBY) $(srcdir)/tool/generic_erb.rb -I$(srcdir) -c -o $@ \
		$(srcdir)/template/prelude.c.tmpl $(PRELUDE_SCRIPTS)

golf_prelude.c: $(COMPILE_PRELUDE) golf_prelude.rb
	$(ECHO) generating $@
	$(Q) $(BASERUBY) $(srcdir)/tool/generic_erb.rb -I$(srcdir) -c -o $@ \
		$(srcdir)/template/prelude.c.tmpl golf_prelude.rb

probes.dmyh: probes.d $(srcdir)/tool/gen_dummy_probes.rb
	$(BASERUBY) $(srcdir)/tool/gen_dummy_probes.rb $(srcdir)/probes.d > $@

probes.h: probes.$(DTRACE_EXT)

prereq: incs srcs preludes PHONY

preludes: prelude.c
preludes: miniprelude.c
preludes: golf_prelude.c

$(srcdir)/revision.h:
	@exit > $@

$(REVISION_H): $(srcdir)/version.h $(srcdir)/ChangeLog $(srcdir)/tool/file2lastrev.rb $(REVISION_FORCE)
	-$(Q) $(BASERUBY) $(srcdir)/tool/file2lastrev.rb --revision.h "$(srcdir)" > revision.tmp
	$(Q)$(IFCHANGE) "--timestamp=$@" "$(srcdir)/revision.h" revision.tmp

$(srcdir)/ext/ripper/ripper.c: parse.y id.h
	$(ECHO) generating $@
	$(Q) $(CHDIR) $(@D) && $(exec) $(MAKE) -f depend $(MFLAGS) \
		Q=$(Q) ECHO=$(ECHO) RM="$(RM)" VPATH="$(PWD)" \
		top_srcdir=../.. srcdir=. \
		RUBY="$(BASERUBY)" PATH_SEPARATOR="$(PATH_SEPARATOR)"

$(srcdir)/ext/json/parser/parser.c: $(srcdir)/ext/json/parser/parser.rl
	$(ECHO) generating $@
	$(Q) $(CHDIR) $(@D) && $(exec) $(MAKE) -f prereq.mk $(MFLAGS) \
		Q=$(Q) ECHO=$(ECHO) top_srcdir=../../.. srcdir=. VPATH=../../.. BASERUBY="$(BASERUBY)"

$(srcdir)/ext/rbconfig/sizeof/sizes.c: $(srcdir)/ext/rbconfig/sizeof/depend \
		$(srcdir)/tool/generic_erb.rb $(srcdir)/template/sizes.c.tmpl $(srcdir)/configure.in
	$(ECHO) generating $@
	$(Q) $(CHDIR) $(@D) && $(exec) $(MAKE) -f depend $(MFLAGS) \
		Q=$(Q) ECHO=$(ECHO) top_srcdir=../../.. srcdir=. VPATH=../../.. RUBY="$(BASERUBY)"

##

run: fake miniruby$(EXEEXT) PHONY
	$(BTESTRUBY) $(TESTRUN_SCRIPT) $(RUNOPT)

runruby: $(PROGRAM) PHONY
	$(RUNRUBY) $(TESTRUN_SCRIPT)

parse: fake miniruby$(EXEEXT) PHONY
	$(BTESTRUBY) $(srcdir)/tool/parse.rb $(TESTRUN_SCRIPT)

bisect: PHONY
	$(srcdir)/tool/bisect.sh miniruby $(srcdir)

bisect-ruby: PHONY
	$(srcdir)/tool/bisect.sh ruby $(srcdir)

COMPARE_RUBY = $(BASERUBY)
ITEM =
OPTS =

benchmark: $(PROGRAM) PHONY
	$(BASERUBY) $(srcdir)/benchmark/driver.rb -v \
	            --executables="$(COMPARE_RUBY); built-ruby::$(RUNRUBY)" \
	            --pattern='bm_' --directory=$(srcdir)/benchmark $(OPTS)

benchmark-each: $(PROGRAM) PHONY
	$(BASERUBY) $(srcdir)/benchmark/driver.rb -v \
	            --executables="$(COMPARE_RUBY); built-ruby::$(RUNRUBY)" \
	            --pattern=$(ITEM) --directory=$(srcdir)/benchmark $(OPTS)

tbench: $(PROGRAM) PHONY
	$(BASERUBY) $(srcdir)/benchmark/driver.rb -v \
	            --executables="$(COMPARE_RUBY); built-ruby::$(RUNRUBY)" \
	            --pattern='bmx_' --directory=$(srcdir)/benchmark $(OPTS)

run.gdb:
	echo set breakpoint pending on         > run.gdb
	echo b ruby_debug_breakpoint          >> run.gdb
	echo '# handle SIGINT nostop'         >> run.gdb
	echo '# handle SIGPIPE nostop'        >> run.gdb
	echo '# b rb_longjmp'                 >> run.gdb
	echo source $(srcdir)/breakpoints.gdb >> run.gdb
	echo source $(srcdir)/.gdbinit        >> run.gdb
	echo 'set $$_exitcode = -999'         >> run.gdb
	echo run                              >> run.gdb
	echo 'if $$_exitcode != -999'         >> run.gdb
	echo '  quit'                         >> run.gdb
	echo end                              >> run.gdb


gdb: miniruby$(EXEEXT) run.gdb PHONY
	gdb -x run.gdb --quiet --args $(MINIRUBY) $(TESTRUN_SCRIPT)

gdb-ruby: $(PROGRAM) run.gdb PHONY
	$(Q) $(RUNRUBY_COMMAND) $(RUNRUBY_DEBUGGER) -- $(TESTRUN_SCRIPT)

dist:
	$(BASERUBY) $(srcdir)/tool/make-snapshot -srcdir=$(srcdir) tmp $(RELNAME)

up::
	-$(Q)$(MAKE) $(MFLAGS) Q=$(Q) REVISION_FORCE=PHONY "$(REVISION_H)"

up::
	-$(Q)$(MAKE) $(MFLAGS) Q=$(Q) after-update

after-update:: update-unicode update-gems extract-extlibs

update-config_files: PHONY
	$(Q) $(BASERUBY) -C "$(srcdir)/tool" \
	    ../tool/downloader.rb -e gnu \
	    config.guess config.sub

update-gems: PHONY
	$(ECHO) Downloading bundled gem files...
	$(Q) $(RUNRUBY) -C "$(srcdir)/gems" \
	    -I../tool -rdownloader -answ \
	    -e 'gem, ver = *$$F' \
	    -e 'old = Dir.glob("#{gem}-*.gem")' \
	    -e 'gem = "#{gem}-#{ver}.gem"' \
	    -e 'Downloader::RubyGems.download(gem, nil, nil) and' \
	    -e 'File.unlink(*(old-[gem]))' \
	    bundled_gems

UPDATE_LIBRARIES = no

### set the following environment variable or uncomment the line if
### the Unicode data files are updated every minute.
# ALWAYS_UPDATE_UNICODE = yes

UNICODE_FILES = $(srcdir)/enc/unicode/data/$(UNICODE_VERSION)/UnicodeData.txt \
		$(srcdir)/enc/unicode/data/$(UNICODE_VERSION)/CompositionExclusions.txt \
		$(srcdir)/enc/unicode/data/$(UNICODE_VERSION)/NormalizationTest.txt

update-unicode: $(UNICODE_FILES) PHONY

UNICODE_FILES_DEPS0 = $(UPDATE_LIBRARIES:yes=download-unicode-data)
UNICODE_FILES_DEPS = $(UNICODE_FILES_DEPS0:no=)
$(UNICODE_FILES): $(UNICODE_FILES_DEPS)

download-unicode-data: ./.unicode-$(UNICODE_VERSION).time
./.unicode-$(UNICODE_VERSION).time: PHONY
	$(ECHO) Downloading Unicode $(UNICODE_VERSION) data files...
	$(Q) $(MAKEDIRS) "$(srcdir)/enc/unicode/data/$(UNICODE_VERSION)"
	$(Q) $(BASERUBY) -C "$(srcdir)" tool/downloader.rb \
	    -d enc/unicode/data/$(UNICODE_VERSION) \
	    -e $(ALWAYS_UPDATE_UNICODE:yes=-a) unicode \
	    $(UNICODE_VERSION)/ucd/UnicodeData.txt \
	    $(UNICODE_VERSION)/ucd/CompositionExclusions.txt \
	    $(UNICODE_VERSION)/ucd/NormalizationTest.txt
	@exit > $@

$(srcdir)/$(HAVE_BASERUBY:yes=lib/unicode_normalize/tables.rb): \
	$(UNICODE_FILES_DEPS:download-unicode-data=./.unicode-tables.time)

./.unicode-tables.time: $(srcdir)/tool/generic_erb.rb \
		$(UNICODE_FILES) $(UNICODE_FILES_DEPS) \
		$(srcdir)/template/unicode_norm_gen.tmpl
	$(Q) $(BASERUBY) $(srcdir)/tool/generic_erb.rb \
		-c -t$@ -o $(srcdir)/lib/unicode_normalize/tables.rb \
		-I $(srcdir) \
		$(srcdir)/template/unicode_norm_gen.tmpl \
		enc/unicode/data/$(UNICODE_VERSION) lib/unicode_normalize

download-extlibs:
	$(Q) $(BASERUBY) -C $(srcdir) -w tool/extlibs.rb --download ext

extract-extlibs:
	$(Q) $(BASERUBY) -C $(srcdir) -w tool/extlibs.rb --all ext

clean-extlibs:
	$(Q) $(RMALL) $(srcdir)/.downloaded-cache

CLEAN_CACHE = clean-extlibs

info: info-program info-libruby_a info-libruby_so info-arch
info-program: PHONY
	@echo PROGRAM=$(PROGRAM)
info-libruby_a: PHONY
	@echo LIBRUBY_A=$(LIBRUBY_A)
info-libruby_so: PHONY
	@echo LIBRUBY_SO=$(LIBRUBY_SO)
info-arch: PHONY
	@echo arch=$(arch)

change: PHONY
	$(BASERUBY) -C "$(srcdir)" ./tool/change_maker.rb $(CHANGES) > change.log

love: sudo-precheck up all test install test-all
	@echo love is all you need

yes-test-all: sudo-precheck

sudo-precheck: PHONY
	@$(SUDO) echo > $(NULL)

help: PHONY
	$(MESSAGE_BEGIN) \
	"                Makefile of Ruby" \
	"" \
	"targets:" \
	"  all (default):   builds all of below" \
	"  miniruby:        builds only miniruby" \
	"  encs:            builds encodings" \
	"  exts:            builds extensions" \
	"  main:            builds encodings, extensions and ruby" \
	"  docs:            builds documents" \
	"  run:             runs test.rb by miniruby" \
	"  runruby:         runs test.rb by ruby you just built" \
	"  gdb:             runs test.rb by miniruby under gdb" \
	"  gdb-ruby:        runs test.rb by ruby under gdb" \
	"  check:           equals make test test-all" \
	"  test:            ruby core tests" \
	"  test-all:        all ruby tests [TESTS=<test files>]" \
	"  test-rubyspec:   run RubySpec test suite" \
	"  update-rubyspec: update local copy of RubySpec" \
	"  benchmark:       benchmark this ruby and COMPARE_RUBY" \
	"  gcbench:         gc benchmark [GCBENCH_ITEM=<item_name>]" \
	"  gcbench-rdoc:    gc benchmark with GCBENCH_ITEM=rdoc" \
	"  install:         install all ruby distributions" \
	"  install-nodoc:   install without rdoc" \
	"  install-cross:   install cross compiling staff" \
	"  clean:           clean for tarball" \
	"  distclean:       clean for repository" \
	"  change:          make change log template" \
	"  golf:            for golfers" \
	"" \
	"see DeveloperHowto for more detail: " \
	"  https://bugs.ruby-lang.org/projects/ruby/wiki/DeveloperHowto" \
	$(MESSAGE_END)

# AUTOGENERATED DEPENDENCIES START
addr2line.$(OBJEXT): addr2line.c
addr2line.$(OBJEXT): addr2line.h
addr2line.$(OBJEXT): config.h
addr2line.$(OBJEXT): missing.h
array.$(OBJEXT): $(hdrdir)/ruby/ruby.h
array.$(OBJEXT): $(top_srcdir)/include/ruby.h
array.$(OBJEXT): array.c
array.$(OBJEXT): config.h
array.$(OBJEXT): defines.h
array.$(OBJEXT): encoding.h
array.$(OBJEXT): id.h
array.$(OBJEXT): intern.h
array.$(OBJEXT): internal.h
array.$(OBJEXT): io.h
array.$(OBJEXT): missing.h
array.$(OBJEXT): oniguruma.h
array.$(OBJEXT): probes.h
array.$(OBJEXT): st.h
array.$(OBJEXT): subst.h
array.$(OBJEXT): util.h
array.$(OBJEXT): vm_opts.h
ascii.$(OBJEXT): ascii.c
ascii.$(OBJEXT): config.h
ascii.$(OBJEXT): defines.h
ascii.$(OBJEXT): missing.h
ascii.$(OBJEXT): oniguruma.h
ascii.$(OBJEXT): regenc.h
bignum.$(OBJEXT): $(hdrdir)/ruby/ruby.h
bignum.$(OBJEXT): $(top_srcdir)/include/ruby.h
bignum.$(OBJEXT): bignum.c
bignum.$(OBJEXT): config.h
bignum.$(OBJEXT): defines.h
bignum.$(OBJEXT): encoding.h
bignum.$(OBJEXT): intern.h
bignum.$(OBJEXT): internal.h
bignum.$(OBJEXT): io.h
bignum.$(OBJEXT): missing.h
bignum.$(OBJEXT): oniguruma.h
bignum.$(OBJEXT): st.h
bignum.$(OBJEXT): subst.h
bignum.$(OBJEXT): thread.h
bignum.$(OBJEXT): util.h
class.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
class.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
class.$(OBJEXT): $(CCAN_DIR)/list/list.h
class.$(OBJEXT): $(CCAN_DIR)/str/str.h
class.$(OBJEXT): $(hdrdir)/ruby/ruby.h
class.$(OBJEXT): $(top_srcdir)/include/ruby.h
class.$(OBJEXT): class.c
class.$(OBJEXT): config.h
class.$(OBJEXT): constant.h
class.$(OBJEXT): defines.h
class.$(OBJEXT): encoding.h
class.$(OBJEXT): id.h
class.$(OBJEXT): intern.h
class.$(OBJEXT): internal.h
class.$(OBJEXT): io.h
class.$(OBJEXT): method.h
class.$(OBJEXT): missing.h
class.$(OBJEXT): node.h
class.$(OBJEXT): oniguruma.h
class.$(OBJEXT): ruby_atomic.h
class.$(OBJEXT): st.h
class.$(OBJEXT): subst.h
class.$(OBJEXT): thread_$(THREAD_MODEL).h
class.$(OBJEXT): thread_native.h
class.$(OBJEXT): vm_core.h
class.$(OBJEXT): vm_debug.h
class.$(OBJEXT): vm_opts.h
compar.$(OBJEXT): $(hdrdir)/ruby/ruby.h
compar.$(OBJEXT): compar.c
compar.$(OBJEXT): config.h
compar.$(OBJEXT): defines.h
compar.$(OBJEXT): intern.h
compar.$(OBJEXT): missing.h
compar.$(OBJEXT): st.h
compar.$(OBJEXT): subst.h
compile.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
compile.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
compile.$(OBJEXT): $(CCAN_DIR)/list/list.h
compile.$(OBJEXT): $(CCAN_DIR)/str/str.h
compile.$(OBJEXT): $(hdrdir)/ruby/ruby.h
compile.$(OBJEXT): $(top_srcdir)/include/ruby.h
compile.$(OBJEXT): compile.c
compile.$(OBJEXT): config.h
compile.$(OBJEXT): defines.h
compile.$(OBJEXT): encoding.h
compile.$(OBJEXT): id.h
compile.$(OBJEXT): insns.inc
compile.$(OBJEXT): insns_info.inc
compile.$(OBJEXT): intern.h
compile.$(OBJEXT): internal.h
compile.$(OBJEXT): io.h
compile.$(OBJEXT): iseq.h
compile.$(OBJEXT): method.h
compile.$(OBJEXT): missing.h
compile.$(OBJEXT): node.h
compile.$(OBJEXT): oniguruma.h
compile.$(OBJEXT): optinsn.inc
compile.$(OBJEXT): ruby_atomic.h
compile.$(OBJEXT): st.h
compile.$(OBJEXT): subst.h
compile.$(OBJEXT): thread_$(THREAD_MODEL).h
compile.$(OBJEXT): thread_native.h
compile.$(OBJEXT): vm_core.h
compile.$(OBJEXT): vm_debug.h
compile.$(OBJEXT): vm_opts.h
complex.$(OBJEXT): $(hdrdir)/ruby/ruby.h
complex.$(OBJEXT): $(top_srcdir)/include/ruby.h
complex.$(OBJEXT): complex.c
complex.$(OBJEXT): config.h
complex.$(OBJEXT): defines.h
complex.$(OBJEXT): encoding.h
complex.$(OBJEXT): intern.h
complex.$(OBJEXT): internal.h
complex.$(OBJEXT): io.h
complex.$(OBJEXT): missing.h
complex.$(OBJEXT): oniguruma.h
complex.$(OBJEXT): st.h
complex.$(OBJEXT): subst.h
cont.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
cont.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
cont.$(OBJEXT): $(CCAN_DIR)/list/list.h
cont.$(OBJEXT): $(CCAN_DIR)/str/str.h
cont.$(OBJEXT): $(hdrdir)/ruby/ruby.h
cont.$(OBJEXT): $(top_srcdir)/include/ruby.h
cont.$(OBJEXT): config.h
cont.$(OBJEXT): cont.c
cont.$(OBJEXT): defines.h
cont.$(OBJEXT): encoding.h
cont.$(OBJEXT): eval_intern.h
cont.$(OBJEXT): gc.h
cont.$(OBJEXT): id.h
cont.$(OBJEXT): intern.h
cont.$(OBJEXT): internal.h
cont.$(OBJEXT): io.h
cont.$(OBJEXT): method.h
cont.$(OBJEXT): missing.h
cont.$(OBJEXT): node.h
cont.$(OBJEXT): oniguruma.h
cont.$(OBJEXT): ruby_atomic.h
cont.$(OBJEXT): st.h
cont.$(OBJEXT): subst.h
cont.$(OBJEXT): thread_$(THREAD_MODEL).h
cont.$(OBJEXT): thread_native.h
cont.$(OBJEXT): vm_core.h
cont.$(OBJEXT): vm_debug.h
cont.$(OBJEXT): vm_opts.h
debug.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
debug.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
debug.$(OBJEXT): $(CCAN_DIR)/list/list.h
debug.$(OBJEXT): $(CCAN_DIR)/str/str.h
debug.$(OBJEXT): $(hdrdir)/ruby/ruby.h
debug.$(OBJEXT): $(top_srcdir)/include/ruby.h
debug.$(OBJEXT): config.h
debug.$(OBJEXT): debug.c
debug.$(OBJEXT): defines.h
debug.$(OBJEXT): encoding.h
debug.$(OBJEXT): eval_intern.h
debug.$(OBJEXT): id.h
debug.$(OBJEXT): intern.h
debug.$(OBJEXT): internal.h
debug.$(OBJEXT): io.h
debug.$(OBJEXT): method.h
debug.$(OBJEXT): missing.h
debug.$(OBJEXT): node.h
debug.$(OBJEXT): oniguruma.h
debug.$(OBJEXT): ruby_atomic.h
debug.$(OBJEXT): st.h
debug.$(OBJEXT): subst.h
debug.$(OBJEXT): thread_$(THREAD_MODEL).h
debug.$(OBJEXT): thread_native.h
debug.$(OBJEXT): util.h
debug.$(OBJEXT): vm_core.h
debug.$(OBJEXT): vm_debug.h
debug.$(OBJEXT): vm_opts.h
dir.$(OBJEXT): $(hdrdir)/ruby/ruby.h
dir.$(OBJEXT): $(top_srcdir)/include/ruby.h
dir.$(OBJEXT): config.h
dir.$(OBJEXT): defines.h
dir.$(OBJEXT): dir.c
dir.$(OBJEXT): encoding.h
dir.$(OBJEXT): intern.h
dir.$(OBJEXT): internal.h
dir.$(OBJEXT): io.h
dir.$(OBJEXT): missing.h
dir.$(OBJEXT): oniguruma.h
dir.$(OBJEXT): st.h
dir.$(OBJEXT): subst.h
dir.$(OBJEXT): util.h
dln.$(OBJEXT): $(hdrdir)/ruby/ruby.h
dln.$(OBJEXT): config.h
dln.$(OBJEXT): defines.h
dln.$(OBJEXT): dln.c
dln.$(OBJEXT): dln.h
dln.$(OBJEXT): intern.h
dln.$(OBJEXT): missing.h
dln.$(OBJEXT): st.h
dln.$(OBJEXT): subst.h
dln_find.$(OBJEXT): $(hdrdir)/ruby/ruby.h
dln_find.$(OBJEXT): config.h
dln_find.$(OBJEXT): defines.h
dln_find.$(OBJEXT): dln.h
dln_find.$(OBJEXT): dln_find.c
dln_find.$(OBJEXT): intern.h
dln_find.$(OBJEXT): missing.h
dln_find.$(OBJEXT): st.h
dln_find.$(OBJEXT): subst.h
dmydln.$(OBJEXT): $(hdrdir)/ruby/ruby.h
dmydln.$(OBJEXT): config.h
dmydln.$(OBJEXT): defines.h
dmydln.$(OBJEXT): dmydln.c
dmydln.$(OBJEXT): intern.h
dmydln.$(OBJEXT): missing.h
dmydln.$(OBJEXT): st.h
dmydln.$(OBJEXT): subst.h
dmyenc.$(OBJEXT): dmyenc.c
dmyext.$(OBJEXT): dmyext.c
encoding.$(OBJEXT): $(hdrdir)/ruby/ruby.h
encoding.$(OBJEXT): $(top_srcdir)/include/ruby.h
encoding.$(OBJEXT): config.h
encoding.$(OBJEXT): defines.h
encoding.$(OBJEXT): encoding.c
encoding.$(OBJEXT): encoding.h
encoding.$(OBJEXT): intern.h
encoding.$(OBJEXT): internal.h
encoding.$(OBJEXT): io.h
encoding.$(OBJEXT): missing.h
encoding.$(OBJEXT): oniguruma.h
encoding.$(OBJEXT): regenc.h
encoding.$(OBJEXT): st.h
encoding.$(OBJEXT): subst.h
encoding.$(OBJEXT): util.h
enum.$(OBJEXT): $(hdrdir)/ruby/ruby.h
enum.$(OBJEXT): $(top_srcdir)/include/ruby.h
enum.$(OBJEXT): config.h
enum.$(OBJEXT): defines.h
enum.$(OBJEXT): encoding.h
enum.$(OBJEXT): enum.c
enum.$(OBJEXT): id.h
enum.$(OBJEXT): intern.h
enum.$(OBJEXT): internal.h
enum.$(OBJEXT): io.h
enum.$(OBJEXT): missing.h
enum.$(OBJEXT): node.h
enum.$(OBJEXT): oniguruma.h
enum.$(OBJEXT): st.h
enum.$(OBJEXT): subst.h
enum.$(OBJEXT): util.h
enumerator.$(OBJEXT): $(hdrdir)/ruby/ruby.h
enumerator.$(OBJEXT): $(top_srcdir)/include/ruby.h
enumerator.$(OBJEXT): config.h
enumerator.$(OBJEXT): defines.h
enumerator.$(OBJEXT): encoding.h
enumerator.$(OBJEXT): enumerator.c
enumerator.$(OBJEXT): intern.h
enumerator.$(OBJEXT): internal.h
enumerator.$(OBJEXT): io.h
enumerator.$(OBJEXT): missing.h
enumerator.$(OBJEXT): node.h
enumerator.$(OBJEXT): oniguruma.h
enumerator.$(OBJEXT): st.h
enumerator.$(OBJEXT): subst.h
error.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
error.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
error.$(OBJEXT): $(CCAN_DIR)/list/list.h
error.$(OBJEXT): $(CCAN_DIR)/str/str.h
error.$(OBJEXT): $(hdrdir)/ruby/ruby.h
error.$(OBJEXT): $(top_srcdir)/include/ruby.h
error.$(OBJEXT): config.h
error.$(OBJEXT): defines.h
error.$(OBJEXT): encoding.h
error.$(OBJEXT): error.c
error.$(OBJEXT): id.h
error.$(OBJEXT): intern.h
error.$(OBJEXT): internal.h
error.$(OBJEXT): io.h
error.$(OBJEXT): known_errors.inc
error.$(OBJEXT): method.h
error.$(OBJEXT): missing.h
error.$(OBJEXT): node.h
error.$(OBJEXT): oniguruma.h
error.$(OBJEXT): ruby_atomic.h
error.$(OBJEXT): st.h
error.$(OBJEXT): subst.h
error.$(OBJEXT): thread_$(THREAD_MODEL).h
error.$(OBJEXT): thread_native.h
error.$(OBJEXT): vm_core.h
error.$(OBJEXT): vm_debug.h
error.$(OBJEXT): vm_opts.h
eval.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
eval.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
eval.$(OBJEXT): $(CCAN_DIR)/list/list.h
eval.$(OBJEXT): $(CCAN_DIR)/str/str.h
eval.$(OBJEXT): $(hdrdir)/ruby/ruby.h
eval.$(OBJEXT): $(top_srcdir)/include/ruby.h
eval.$(OBJEXT): config.h
eval.$(OBJEXT): defines.h
eval.$(OBJEXT): encoding.h
eval.$(OBJEXT): eval.c
eval.$(OBJEXT): eval_error.c
eval.$(OBJEXT): eval_intern.h
eval.$(OBJEXT): eval_jump.c
eval.$(OBJEXT): gc.h
eval.$(OBJEXT): id.h
eval.$(OBJEXT): intern.h
eval.$(OBJEXT): internal.h
eval.$(OBJEXT): io.h
eval.$(OBJEXT): iseq.h
eval.$(OBJEXT): method.h
eval.$(OBJEXT): missing.h
eval.$(OBJEXT): node.h
eval.$(OBJEXT): oniguruma.h
eval.$(OBJEXT): probes.h
eval.$(OBJEXT): probes_helper.h
eval.$(OBJEXT): ruby_atomic.h
eval.$(OBJEXT): st.h
eval.$(OBJEXT): subst.h
eval.$(OBJEXT): thread_$(THREAD_MODEL).h
eval.$(OBJEXT): thread_native.h
eval.$(OBJEXT): vm.h
eval.$(OBJEXT): vm_core.h
eval.$(OBJEXT): vm_debug.h
eval.$(OBJEXT): vm_opts.h
file.$(OBJEXT): $(hdrdir)/ruby/ruby.h
file.$(OBJEXT): $(top_srcdir)/include/ruby.h
file.$(OBJEXT): config.h
file.$(OBJEXT): defines.h
file.$(OBJEXT): dln.h
file.$(OBJEXT): encoding.h
file.$(OBJEXT): file.c
file.$(OBJEXT): intern.h
file.$(OBJEXT): internal.h
file.$(OBJEXT): io.h
file.$(OBJEXT): missing.h
file.$(OBJEXT): oniguruma.h
file.$(OBJEXT): st.h
file.$(OBJEXT): subst.h
file.$(OBJEXT): util.h
gc.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
gc.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
gc.$(OBJEXT): $(CCAN_DIR)/list/list.h
gc.$(OBJEXT): $(CCAN_DIR)/str/str.h
gc.$(OBJEXT): $(hdrdir)/ruby/ruby.h
gc.$(OBJEXT): $(top_srcdir)/include/ruby.h
gc.$(OBJEXT): config.h
gc.$(OBJEXT): constant.h
gc.$(OBJEXT): debug.h
gc.$(OBJEXT): defines.h
gc.$(OBJEXT): encoding.h
gc.$(OBJEXT): eval_intern.h
gc.$(OBJEXT): gc.c
gc.$(OBJEXT): gc.h
gc.$(OBJEXT): id.h
gc.$(OBJEXT): intern.h
gc.$(OBJEXT): internal.h
gc.$(OBJEXT): io.h
gc.$(OBJEXT): method.h
gc.$(OBJEXT): missing.h
gc.$(OBJEXT): node.h
gc.$(OBJEXT): oniguruma.h
gc.$(OBJEXT): probes.h
gc.$(OBJEXT): re.h
gc.$(OBJEXT): regenc.h
gc.$(OBJEXT): regex.h
gc.$(OBJEXT): regint.h
gc.$(OBJEXT): ruby_atomic.h
gc.$(OBJEXT): st.h
gc.$(OBJEXT): subst.h
gc.$(OBJEXT): thread.h
gc.$(OBJEXT): thread_$(THREAD_MODEL).h
gc.$(OBJEXT): thread_native.h
gc.$(OBJEXT): util.h
gc.$(OBJEXT): vm_core.h
gc.$(OBJEXT): vm_debug.h
gc.$(OBJEXT): vm_opts.h
golf_prelude.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
golf_prelude.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
golf_prelude.$(OBJEXT): $(CCAN_DIR)/list/list.h
golf_prelude.$(OBJEXT): $(CCAN_DIR)/str/str.h
golf_prelude.$(OBJEXT): $(hdrdir)/ruby/ruby.h
golf_prelude.$(OBJEXT): $(top_srcdir)/include/ruby.h
golf_prelude.$(OBJEXT): config.h
golf_prelude.$(OBJEXT): defines.h
golf_prelude.$(OBJEXT): encoding.h
golf_prelude.$(OBJEXT): golf_prelude.c
golf_prelude.$(OBJEXT): id.h
golf_prelude.$(OBJEXT): intern.h
golf_prelude.$(OBJEXT): internal.h
golf_prelude.$(OBJEXT): io.h
golf_prelude.$(OBJEXT): method.h
golf_prelude.$(OBJEXT): missing.h
golf_prelude.$(OBJEXT): node.h
golf_prelude.$(OBJEXT): oniguruma.h
golf_prelude.$(OBJEXT): ruby_atomic.h
golf_prelude.$(OBJEXT): st.h
golf_prelude.$(OBJEXT): subst.h
golf_prelude.$(OBJEXT): thread_$(THREAD_MODEL).h
golf_prelude.$(OBJEXT): thread_native.h
golf_prelude.$(OBJEXT): vm_core.h
golf_prelude.$(OBJEXT): vm_debug.h
golf_prelude.$(OBJEXT): vm_opts.h
goruby.$(OBJEXT): $(hdrdir)/ruby/ruby.h
goruby.$(OBJEXT): $(top_srcdir)/include/ruby.h
goruby.$(OBJEXT): config.h
goruby.$(OBJEXT): defines.h
goruby.$(OBJEXT): goruby.c
goruby.$(OBJEXT): intern.h
goruby.$(OBJEXT): main.c
goruby.$(OBJEXT): missing.h
goruby.$(OBJEXT): node.h
goruby.$(OBJEXT): st.h
goruby.$(OBJEXT): subst.h
goruby.$(OBJEXT): vm_debug.h
hash.$(OBJEXT): $(hdrdir)/ruby/ruby.h
hash.$(OBJEXT): $(top_srcdir)/include/ruby.h
hash.$(OBJEXT): config.h
hash.$(OBJEXT): defines.h
hash.$(OBJEXT): encoding.h
hash.$(OBJEXT): hash.c
hash.$(OBJEXT): id.h
hash.$(OBJEXT): intern.h
hash.$(OBJEXT): internal.h
hash.$(OBJEXT): io.h
hash.$(OBJEXT): missing.h
hash.$(OBJEXT): oniguruma.h
hash.$(OBJEXT): probes.h
hash.$(OBJEXT): st.h
hash.$(OBJEXT): subst.h
hash.$(OBJEXT): util.h
hash.$(OBJEXT): vm_opts.h
inits.$(OBJEXT): $(hdrdir)/ruby/ruby.h
inits.$(OBJEXT): $(top_srcdir)/include/ruby.h
inits.$(OBJEXT): config.h
inits.$(OBJEXT): defines.h
inits.$(OBJEXT): encoding.h
inits.$(OBJEXT): inits.c
inits.$(OBJEXT): intern.h
inits.$(OBJEXT): internal.h
inits.$(OBJEXT): io.h
inits.$(OBJEXT): missing.h
inits.$(OBJEXT): oniguruma.h
inits.$(OBJEXT): st.h
inits.$(OBJEXT): subst.h
io.$(OBJEXT): $(hdrdir)/ruby/ruby.h
io.$(OBJEXT): $(top_srcdir)/include/ruby.h
io.$(OBJEXT): config.h
io.$(OBJEXT): defines.h
io.$(OBJEXT): dln.h
io.$(OBJEXT): encoding.h
io.$(OBJEXT): id.h
io.$(OBJEXT): intern.h
io.$(OBJEXT): internal.h
io.$(OBJEXT): io.c
io.$(OBJEXT): io.h
io.$(OBJEXT): missing.h
io.$(OBJEXT): oniguruma.h
io.$(OBJEXT): ruby_atomic.h
io.$(OBJEXT): st.h
io.$(OBJEXT): subst.h
io.$(OBJEXT): thread.h
io.$(OBJEXT): util.h
iseq.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
iseq.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
iseq.$(OBJEXT): $(CCAN_DIR)/list/list.h
iseq.$(OBJEXT): $(CCAN_DIR)/str/str.h
iseq.$(OBJEXT): $(hdrdir)/ruby/ruby.h
iseq.$(OBJEXT): $(top_srcdir)/include/ruby.h
iseq.$(OBJEXT): config.h
iseq.$(OBJEXT): defines.h
iseq.$(OBJEXT): encoding.h
iseq.$(OBJEXT): eval_intern.h
iseq.$(OBJEXT): gc.h
iseq.$(OBJEXT): id.h
iseq.$(OBJEXT): insns.inc
iseq.$(OBJEXT): insns_info.inc
iseq.$(OBJEXT): intern.h
iseq.$(OBJEXT): internal.h
iseq.$(OBJEXT): io.h
iseq.$(OBJEXT): iseq.c
iseq.$(OBJEXT): iseq.h
iseq.$(OBJEXT): method.h
iseq.$(OBJEXT): missing.h
iseq.$(OBJEXT): node.h
iseq.$(OBJEXT): node_name.inc
iseq.$(OBJEXT): oniguruma.h
iseq.$(OBJEXT): ruby_atomic.h
iseq.$(OBJEXT): st.h
iseq.$(OBJEXT): subst.h
iseq.$(OBJEXT): thread_$(THREAD_MODEL).h
iseq.$(OBJEXT): thread_native.h
iseq.$(OBJEXT): util.h
iseq.$(OBJEXT): vm_core.h
iseq.$(OBJEXT): vm_debug.h
iseq.$(OBJEXT): vm_opts.h
load.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
load.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
load.$(OBJEXT): $(CCAN_DIR)/list/list.h
load.$(OBJEXT): $(CCAN_DIR)/str/str.h
load.$(OBJEXT): $(hdrdir)/ruby/ruby.h
load.$(OBJEXT): $(top_srcdir)/include/ruby.h
load.$(OBJEXT): config.h
load.$(OBJEXT): defines.h
load.$(OBJEXT): dln.h
load.$(OBJEXT): encoding.h
load.$(OBJEXT): eval_intern.h
load.$(OBJEXT): id.h
load.$(OBJEXT): intern.h
load.$(OBJEXT): internal.h
load.$(OBJEXT): io.h
load.$(OBJEXT): load.c
load.$(OBJEXT): method.h
load.$(OBJEXT): missing.h
load.$(OBJEXT): node.h
load.$(OBJEXT): oniguruma.h
load.$(OBJEXT): probes.h
load.$(OBJEXT): ruby_atomic.h
load.$(OBJEXT): st.h
load.$(OBJEXT): subst.h
load.$(OBJEXT): thread_$(THREAD_MODEL).h
load.$(OBJEXT): thread_native.h
load.$(OBJEXT): util.h
load.$(OBJEXT): vm_core.h
load.$(OBJEXT): vm_debug.h
load.$(OBJEXT): vm_opts.h
loadpath.$(OBJEXT): $(hdrdir)/ruby/ruby.h
loadpath.$(OBJEXT): $(hdrdir)/ruby/version.h
loadpath.$(OBJEXT): $(top_srcdir)/version.h
loadpath.$(OBJEXT): config.h
loadpath.$(OBJEXT): defines.h
loadpath.$(OBJEXT): intern.h
loadpath.$(OBJEXT): loadpath.c
loadpath.$(OBJEXT): missing.h
loadpath.$(OBJEXT): st.h
loadpath.$(OBJEXT): subst.h
loadpath.$(OBJEXT): verconf.h
localeinit.$(OBJEXT): $(hdrdir)/ruby/ruby.h
localeinit.$(OBJEXT): $(top_srcdir)/include/ruby.h
localeinit.$(OBJEXT): config.h
localeinit.$(OBJEXT): defines.h
localeinit.$(OBJEXT): encoding.h
localeinit.$(OBJEXT): intern.h
localeinit.$(OBJEXT): internal.h
localeinit.$(OBJEXT): io.h
localeinit.$(OBJEXT): localeinit.c
localeinit.$(OBJEXT): missing.h
localeinit.$(OBJEXT): oniguruma.h
localeinit.$(OBJEXT): st.h
localeinit.$(OBJEXT): subst.h
main.$(OBJEXT): $(hdrdir)/ruby/ruby.h
main.$(OBJEXT): $(top_srcdir)/include/ruby.h
main.$(OBJEXT): config.h
main.$(OBJEXT): defines.h
main.$(OBJEXT): intern.h
main.$(OBJEXT): main.c
main.$(OBJEXT): missing.h
main.$(OBJEXT): node.h
main.$(OBJEXT): st.h
main.$(OBJEXT): subst.h
main.$(OBJEXT): vm_debug.h
marshal.$(OBJEXT): $(hdrdir)/ruby/ruby.h
marshal.$(OBJEXT): $(top_srcdir)/include/ruby.h
marshal.$(OBJEXT): config.h
marshal.$(OBJEXT): defines.h
marshal.$(OBJEXT): encoding.h
marshal.$(OBJEXT): intern.h
marshal.$(OBJEXT): internal.h
marshal.$(OBJEXT): io.h
marshal.$(OBJEXT): marshal.c
marshal.$(OBJEXT): missing.h
marshal.$(OBJEXT): oniguruma.h
marshal.$(OBJEXT): st.h
marshal.$(OBJEXT): subst.h
marshal.$(OBJEXT): util.h
math.$(OBJEXT): $(hdrdir)/ruby/ruby.h
math.$(OBJEXT): $(top_srcdir)/include/ruby.h
math.$(OBJEXT): config.h
math.$(OBJEXT): defines.h
math.$(OBJEXT): encoding.h
math.$(OBJEXT): intern.h
math.$(OBJEXT): internal.h
math.$(OBJEXT): io.h
math.$(OBJEXT): math.c
math.$(OBJEXT): missing.h
math.$(OBJEXT): oniguruma.h
math.$(OBJEXT): st.h
math.$(OBJEXT): subst.h
miniinit.$(OBJEXT): $(hdrdir)/ruby/ruby.h
miniinit.$(OBJEXT): config.h
miniinit.$(OBJEXT): defines.h
miniinit.$(OBJEXT): encoding.h
miniinit.$(OBJEXT): intern.h
miniinit.$(OBJEXT): miniinit.c
miniinit.$(OBJEXT): missing.h
miniinit.$(OBJEXT): oniguruma.h
miniinit.$(OBJEXT): st.h
miniinit.$(OBJEXT): subst.h
miniprelude.$(OBJEXT): miniprelude.c
newline.$(OBJEXT): $(hdrdir)/ruby/ruby.h
newline.$(OBJEXT): config.h
newline.$(OBJEXT): defines.h
newline.$(OBJEXT): intern.h
newline.$(OBJEXT): missing.h
newline.$(OBJEXT): newline.c
newline.$(OBJEXT): st.h
newline.$(OBJEXT): subst.h
newline.$(OBJEXT): transcode_data.h
node.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
node.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
node.$(OBJEXT): $(CCAN_DIR)/list/list.h
node.$(OBJEXT): $(CCAN_DIR)/str/str.h
node.$(OBJEXT): $(hdrdir)/ruby/ruby.h
node.$(OBJEXT): $(top_srcdir)/include/ruby.h
node.$(OBJEXT): config.h
node.$(OBJEXT): defines.h
node.$(OBJEXT): encoding.h
node.$(OBJEXT): id.h
node.$(OBJEXT): intern.h
node.$(OBJEXT): internal.h
node.$(OBJEXT): io.h
node.$(OBJEXT): method.h
node.$(OBJEXT): missing.h
node.$(OBJEXT): node.c
node.$(OBJEXT): node.h
node.$(OBJEXT): oniguruma.h
node.$(OBJEXT): ruby_atomic.h
node.$(OBJEXT): st.h
node.$(OBJEXT): subst.h
node.$(OBJEXT): thread_$(THREAD_MODEL).h
node.$(OBJEXT): thread_native.h
node.$(OBJEXT): vm_core.h
node.$(OBJEXT): vm_debug.h
node.$(OBJEXT): vm_opts.h
numeric.$(OBJEXT): $(hdrdir)/ruby/ruby.h
numeric.$(OBJEXT): $(top_srcdir)/include/ruby.h
numeric.$(OBJEXT): config.h
numeric.$(OBJEXT): defines.h
numeric.$(OBJEXT): encoding.h
numeric.$(OBJEXT): id.h
numeric.$(OBJEXT): intern.h
numeric.$(OBJEXT): internal.h
numeric.$(OBJEXT): io.h
numeric.$(OBJEXT): missing.h
numeric.$(OBJEXT): numeric.c
numeric.$(OBJEXT): oniguruma.h
numeric.$(OBJEXT): st.h
numeric.$(OBJEXT): subst.h
numeric.$(OBJEXT): util.h
object.$(OBJEXT): $(hdrdir)/ruby/ruby.h
object.$(OBJEXT): $(top_srcdir)/include/ruby.h
object.$(OBJEXT): config.h
object.$(OBJEXT): constant.h
object.$(OBJEXT): defines.h
object.$(OBJEXT): encoding.h
object.$(OBJEXT): id.h
object.$(OBJEXT): intern.h
object.$(OBJEXT): internal.h
object.$(OBJEXT): io.h
object.$(OBJEXT): missing.h
object.$(OBJEXT): object.c
object.$(OBJEXT): oniguruma.h
object.$(OBJEXT): probes.h
object.$(OBJEXT): st.h
object.$(OBJEXT): subst.h
object.$(OBJEXT): util.h
object.$(OBJEXT): vm_opts.h
pack.$(OBJEXT): $(hdrdir)/ruby/ruby.h
pack.$(OBJEXT): $(top_srcdir)/include/ruby.h
pack.$(OBJEXT): config.h
pack.$(OBJEXT): defines.h
pack.$(OBJEXT): encoding.h
pack.$(OBJEXT): intern.h
pack.$(OBJEXT): internal.h
pack.$(OBJEXT): io.h
pack.$(OBJEXT): missing.h
pack.$(OBJEXT): oniguruma.h
pack.$(OBJEXT): pack.c
pack.$(OBJEXT): st.h
pack.$(OBJEXT): subst.h
parse.$(OBJEXT): $(hdrdir)/ruby/ruby.h
parse.$(OBJEXT): $(top_srcdir)/include/ruby.h
parse.$(OBJEXT): config.h
parse.$(OBJEXT): defines.h
parse.$(OBJEXT): defs/keywords
parse.$(OBJEXT): encoding.h
parse.$(OBJEXT): id.h
parse.$(OBJEXT): intern.h
parse.$(OBJEXT): internal.h
parse.$(OBJEXT): io.h
parse.$(OBJEXT): lex.c
parse.$(OBJEXT): missing.h
parse.$(OBJEXT): node.h
parse.$(OBJEXT): oniguruma.h
parse.$(OBJEXT): parse.c
parse.$(OBJEXT): parse.h
parse.$(OBJEXT): parse.y
parse.$(OBJEXT): probes.h
parse.$(OBJEXT): regenc.h
parse.$(OBJEXT): regex.h
parse.$(OBJEXT): st.h
parse.$(OBJEXT): subst.h
parse.$(OBJEXT): symbol.h
parse.$(OBJEXT): util.h
parse.$(OBJEXT): vm_opts.h
prelude.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
prelude.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
prelude.$(OBJEXT): $(CCAN_DIR)/list/list.h
prelude.$(OBJEXT): $(CCAN_DIR)/str/str.h
prelude.$(OBJEXT): $(hdrdir)/ruby/ruby.h
prelude.$(OBJEXT): $(top_srcdir)/include/ruby.h
prelude.$(OBJEXT): config.h
prelude.$(OBJEXT): defines.h
prelude.$(OBJEXT): encoding.h
prelude.$(OBJEXT): id.h
prelude.$(OBJEXT): intern.h
prelude.$(OBJEXT): internal.h
prelude.$(OBJEXT): io.h
prelude.$(OBJEXT): method.h
prelude.$(OBJEXT): missing.h
prelude.$(OBJEXT): node.h
prelude.$(OBJEXT): oniguruma.h
prelude.$(OBJEXT): prelude.c
prelude.$(OBJEXT): ruby_atomic.h
prelude.$(OBJEXT): st.h
prelude.$(OBJEXT): subst.h
prelude.$(OBJEXT): thread_$(THREAD_MODEL).h
prelude.$(OBJEXT): thread_native.h
prelude.$(OBJEXT): vm_core.h
prelude.$(OBJEXT): vm_debug.h
prelude.$(OBJEXT): vm_opts.h
proc.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
proc.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
proc.$(OBJEXT): $(CCAN_DIR)/list/list.h
proc.$(OBJEXT): $(CCAN_DIR)/str/str.h
proc.$(OBJEXT): $(hdrdir)/ruby/ruby.h
proc.$(OBJEXT): $(top_srcdir)/include/ruby.h
proc.$(OBJEXT): config.h
proc.$(OBJEXT): defines.h
proc.$(OBJEXT): encoding.h
proc.$(OBJEXT): eval_intern.h
proc.$(OBJEXT): gc.h
proc.$(OBJEXT): id.h
proc.$(OBJEXT): intern.h
proc.$(OBJEXT): internal.h
proc.$(OBJEXT): io.h
proc.$(OBJEXT): iseq.h
proc.$(OBJEXT): method.h
proc.$(OBJEXT): missing.h
proc.$(OBJEXT): node.h
proc.$(OBJEXT): oniguruma.h
proc.$(OBJEXT): proc.c
proc.$(OBJEXT): ruby_atomic.h
proc.$(OBJEXT): st.h
proc.$(OBJEXT): subst.h
proc.$(OBJEXT): thread_$(THREAD_MODEL).h
proc.$(OBJEXT): thread_native.h
proc.$(OBJEXT): vm_core.h
proc.$(OBJEXT): vm_debug.h
proc.$(OBJEXT): vm_opts.h
process.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
process.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
process.$(OBJEXT): $(CCAN_DIR)/list/list.h
process.$(OBJEXT): $(CCAN_DIR)/str/str.h
process.$(OBJEXT): $(hdrdir)/ruby/ruby.h
process.$(OBJEXT): $(top_srcdir)/include/ruby.h
process.$(OBJEXT): config.h
process.$(OBJEXT): defines.h
process.$(OBJEXT): dln.h
process.$(OBJEXT): encoding.h
process.$(OBJEXT): id.h
process.$(OBJEXT): intern.h
process.$(OBJEXT): internal.h
process.$(OBJEXT): io.h
process.$(OBJEXT): method.h
process.$(OBJEXT): missing.h
process.$(OBJEXT): node.h
process.$(OBJEXT): oniguruma.h
process.$(OBJEXT): process.c
process.$(OBJEXT): ruby_atomic.h
process.$(OBJEXT): st.h
process.$(OBJEXT): subst.h
process.$(OBJEXT): thread.h
process.$(OBJEXT): thread_$(THREAD_MODEL).h
process.$(OBJEXT): thread_native.h
process.$(OBJEXT): util.h
process.$(OBJEXT): vm_core.h
process.$(OBJEXT): vm_debug.h
process.$(OBJEXT): vm_opts.h
random.$(OBJEXT): $(hdrdir)/ruby/ruby.h
random.$(OBJEXT): $(top_srcdir)/include/ruby.h
random.$(OBJEXT): config.h
random.$(OBJEXT): defines.h
random.$(OBJEXT): encoding.h
random.$(OBJEXT): intern.h
random.$(OBJEXT): internal.h
random.$(OBJEXT): io.h
random.$(OBJEXT): missing.h
random.$(OBJEXT): oniguruma.h
random.$(OBJEXT): random.c
random.$(OBJEXT): siphash.c
random.$(OBJEXT): siphash.h
random.$(OBJEXT): st.h
random.$(OBJEXT): subst.h
range.$(OBJEXT): $(hdrdir)/ruby/ruby.h
range.$(OBJEXT): $(top_srcdir)/include/ruby.h
range.$(OBJEXT): config.h
range.$(OBJEXT): defines.h
range.$(OBJEXT): encoding.h
range.$(OBJEXT): id.h
range.$(OBJEXT): intern.h
range.$(OBJEXT): internal.h
range.$(OBJEXT): io.h
range.$(OBJEXT): missing.h
range.$(OBJEXT): oniguruma.h
range.$(OBJEXT): range.c
range.$(OBJEXT): st.h
range.$(OBJEXT): subst.h
rational.$(OBJEXT): $(hdrdir)/ruby/ruby.h
rational.$(OBJEXT): $(top_srcdir)/include/ruby.h
rational.$(OBJEXT): config.h
rational.$(OBJEXT): defines.h
rational.$(OBJEXT): encoding.h
rational.$(OBJEXT): intern.h
rational.$(OBJEXT): internal.h
rational.$(OBJEXT): io.h
rational.$(OBJEXT): missing.h
rational.$(OBJEXT): oniguruma.h
rational.$(OBJEXT): rational.c
rational.$(OBJEXT): st.h
rational.$(OBJEXT): subst.h
re.$(OBJEXT): $(hdrdir)/ruby/ruby.h
re.$(OBJEXT): $(top_srcdir)/include/ruby.h
re.$(OBJEXT): config.h
re.$(OBJEXT): defines.h
re.$(OBJEXT): encoding.h
re.$(OBJEXT): intern.h
re.$(OBJEXT): internal.h
re.$(OBJEXT): io.h
re.$(OBJEXT): missing.h
re.$(OBJEXT): oniguruma.h
re.$(OBJEXT): re.c
re.$(OBJEXT): re.h
re.$(OBJEXT): regenc.h
re.$(OBJEXT): regex.h
re.$(OBJEXT): regint.h
re.$(OBJEXT): st.h
re.$(OBJEXT): subst.h
re.$(OBJEXT): util.h
regcomp.$(OBJEXT): $(hdrdir)/ruby/ruby.h
regcomp.$(OBJEXT): config.h
regcomp.$(OBJEXT): defines.h
regcomp.$(OBJEXT): intern.h
regcomp.$(OBJEXT): missing.h
regcomp.$(OBJEXT): oniguruma.h
regcomp.$(OBJEXT): regcomp.c
regcomp.$(OBJEXT): regenc.h
regcomp.$(OBJEXT): regint.h
regcomp.$(OBJEXT): regparse.h
regcomp.$(OBJEXT): st.h
regcomp.$(OBJEXT): subst.h
regenc.$(OBJEXT): $(hdrdir)/ruby/ruby.h
regenc.$(OBJEXT): config.h
regenc.$(OBJEXT): defines.h
regenc.$(OBJEXT): intern.h
regenc.$(OBJEXT): missing.h
regenc.$(OBJEXT): oniguruma.h
regenc.$(OBJEXT): regenc.c
regenc.$(OBJEXT): regenc.h
regenc.$(OBJEXT): regint.h
regenc.$(OBJEXT): st.h
regenc.$(OBJEXT): subst.h
regerror.$(OBJEXT): $(hdrdir)/ruby/ruby.h
regerror.$(OBJEXT): config.h
regerror.$(OBJEXT): defines.h
regerror.$(OBJEXT): intern.h
regerror.$(OBJEXT): missing.h
regerror.$(OBJEXT): oniguruma.h
regerror.$(OBJEXT): regenc.h
regerror.$(OBJEXT): regerror.c
regerror.$(OBJEXT): regint.h
regerror.$(OBJEXT): st.h
regerror.$(OBJEXT): subst.h
regexec.$(OBJEXT): $(hdrdir)/ruby/ruby.h
regexec.$(OBJEXT): config.h
regexec.$(OBJEXT): defines.h
regexec.$(OBJEXT): intern.h
regexec.$(OBJEXT): missing.h
regexec.$(OBJEXT): oniguruma.h
regexec.$(OBJEXT): regenc.h
regexec.$(OBJEXT): regexec.c
regexec.$(OBJEXT): regint.h
regexec.$(OBJEXT): st.h
regexec.$(OBJEXT): subst.h
regparse.$(OBJEXT): $(hdrdir)/ruby/ruby.h
regparse.$(OBJEXT): config.h
regparse.$(OBJEXT): defines.h
regparse.$(OBJEXT): intern.h
regparse.$(OBJEXT): missing.h
regparse.$(OBJEXT): oniguruma.h
regparse.$(OBJEXT): regenc.h
regparse.$(OBJEXT): regint.h
regparse.$(OBJEXT): regparse.c
regparse.$(OBJEXT): regparse.h
regparse.$(OBJEXT): st.h
regparse.$(OBJEXT): subst.h
regsyntax.$(OBJEXT): $(hdrdir)/ruby/ruby.h
regsyntax.$(OBJEXT): config.h
regsyntax.$(OBJEXT): defines.h
regsyntax.$(OBJEXT): intern.h
regsyntax.$(OBJEXT): missing.h
regsyntax.$(OBJEXT): oniguruma.h
regsyntax.$(OBJEXT): regenc.h
regsyntax.$(OBJEXT): regint.h
regsyntax.$(OBJEXT): regsyntax.c
regsyntax.$(OBJEXT): st.h
regsyntax.$(OBJEXT): subst.h
ruby.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
ruby.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
ruby.$(OBJEXT): $(CCAN_DIR)/list/list.h
ruby.$(OBJEXT): $(CCAN_DIR)/str/str.h
ruby.$(OBJEXT): $(hdrdir)/ruby/ruby.h
ruby.$(OBJEXT): $(top_srcdir)/include/ruby.h
ruby.$(OBJEXT): config.h
ruby.$(OBJEXT): defines.h
ruby.$(OBJEXT): dln.h
ruby.$(OBJEXT): encoding.h
ruby.$(OBJEXT): eval_intern.h
ruby.$(OBJEXT): id.h
ruby.$(OBJEXT): intern.h
ruby.$(OBJEXT): internal.h
ruby.$(OBJEXT): io.h
ruby.$(OBJEXT): method.h
ruby.$(OBJEXT): missing.h
ruby.$(OBJEXT): node.h
ruby.$(OBJEXT): oniguruma.h
ruby.$(OBJEXT): ruby.c
ruby.$(OBJEXT): ruby_atomic.h
ruby.$(OBJEXT): st.h
ruby.$(OBJEXT): subst.h
ruby.$(OBJEXT): thread_$(THREAD_MODEL).h
ruby.$(OBJEXT): thread_native.h
ruby.$(OBJEXT): util.h
ruby.$(OBJEXT): vm_core.h
ruby.$(OBJEXT): vm_debug.h
ruby.$(OBJEXT): vm_opts.h
safe.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
safe.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
safe.$(OBJEXT): $(CCAN_DIR)/list/list.h
safe.$(OBJEXT): $(CCAN_DIR)/str/str.h
safe.$(OBJEXT): $(hdrdir)/ruby/ruby.h
safe.$(OBJEXT): $(top_srcdir)/include/ruby.h
safe.$(OBJEXT): config.h
safe.$(OBJEXT): defines.h
safe.$(OBJEXT): encoding.h
safe.$(OBJEXT): id.h
safe.$(OBJEXT): intern.h
safe.$(OBJEXT): internal.h
safe.$(OBJEXT): io.h
safe.$(OBJEXT): method.h
safe.$(OBJEXT): missing.h
safe.$(OBJEXT): node.h
safe.$(OBJEXT): oniguruma.h
safe.$(OBJEXT): ruby_atomic.h
safe.$(OBJEXT): safe.c
safe.$(OBJEXT): st.h
safe.$(OBJEXT): subst.h
safe.$(OBJEXT): thread_$(THREAD_MODEL).h
safe.$(OBJEXT): thread_native.h
safe.$(OBJEXT): vm_core.h
safe.$(OBJEXT): vm_debug.h
safe.$(OBJEXT): vm_opts.h
setproctitle.$(OBJEXT): $(hdrdir)/ruby/ruby.h
setproctitle.$(OBJEXT): $(top_srcdir)/include/ruby.h
setproctitle.$(OBJEXT): config.h
setproctitle.$(OBJEXT): defines.h
setproctitle.$(OBJEXT): intern.h
setproctitle.$(OBJEXT): missing.h
setproctitle.$(OBJEXT): setproctitle.c
setproctitle.$(OBJEXT): st.h
setproctitle.$(OBJEXT): subst.h
setproctitle.$(OBJEXT): util.h
signal.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
signal.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
signal.$(OBJEXT): $(CCAN_DIR)/list/list.h
signal.$(OBJEXT): $(CCAN_DIR)/str/str.h
signal.$(OBJEXT): $(hdrdir)/ruby/ruby.h
signal.$(OBJEXT): $(top_srcdir)/include/ruby.h
signal.$(OBJEXT): config.h
signal.$(OBJEXT): defines.h
signal.$(OBJEXT): encoding.h
signal.$(OBJEXT): eval_intern.h
signal.$(OBJEXT): id.h
signal.$(OBJEXT): intern.h
signal.$(OBJEXT): internal.h
signal.$(OBJEXT): io.h
signal.$(OBJEXT): method.h
signal.$(OBJEXT): missing.h
signal.$(OBJEXT): node.h
signal.$(OBJEXT): oniguruma.h
signal.$(OBJEXT): ruby_atomic.h
signal.$(OBJEXT): signal.c
signal.$(OBJEXT): st.h
signal.$(OBJEXT): subst.h
signal.$(OBJEXT): thread_$(THREAD_MODEL).h
signal.$(OBJEXT): thread_native.h
signal.$(OBJEXT): vm_core.h
signal.$(OBJEXT): vm_debug.h
signal.$(OBJEXT): vm_opts.h
sprintf.$(OBJEXT): $(hdrdir)/ruby/ruby.h
sprintf.$(OBJEXT): $(top_srcdir)/include/ruby.h
sprintf.$(OBJEXT): config.h
sprintf.$(OBJEXT): defines.h
sprintf.$(OBJEXT): encoding.h
sprintf.$(OBJEXT): id.h
sprintf.$(OBJEXT): intern.h
sprintf.$(OBJEXT): internal.h
sprintf.$(OBJEXT): io.h
sprintf.$(OBJEXT): missing.h
sprintf.$(OBJEXT): oniguruma.h
sprintf.$(OBJEXT): re.h
sprintf.$(OBJEXT): regex.h
sprintf.$(OBJEXT): sprintf.c
sprintf.$(OBJEXT): st.h
sprintf.$(OBJEXT): subst.h
sprintf.$(OBJEXT): vsnprintf.c
st.$(OBJEXT): $(hdrdir)/ruby/ruby.h
st.$(OBJEXT): $(top_srcdir)/include/ruby.h
st.$(OBJEXT): config.h
st.$(OBJEXT): defines.h
st.$(OBJEXT): encoding.h
st.$(OBJEXT): intern.h
st.$(OBJEXT): internal.h
st.$(OBJEXT): io.h
st.$(OBJEXT): missing.h
st.$(OBJEXT): oniguruma.h
st.$(OBJEXT): st.c
st.$(OBJEXT): st.h
st.$(OBJEXT): subst.h
strftime.$(OBJEXT): $(hdrdir)/ruby/ruby.h
strftime.$(OBJEXT): config.h
strftime.$(OBJEXT): defines.h
strftime.$(OBJEXT): encoding.h
strftime.$(OBJEXT): intern.h
strftime.$(OBJEXT): missing.h
strftime.$(OBJEXT): oniguruma.h
strftime.$(OBJEXT): st.h
strftime.$(OBJEXT): strftime.c
strftime.$(OBJEXT): subst.h
strftime.$(OBJEXT): timev.h
string.$(OBJEXT): $(hdrdir)/ruby/ruby.h
string.$(OBJEXT): $(top_srcdir)/include/ruby.h
string.$(OBJEXT): config.h
string.$(OBJEXT): defines.h
string.$(OBJEXT): encoding.h
string.$(OBJEXT): gc.h
string.$(OBJEXT): intern.h
string.$(OBJEXT): internal.h
string.$(OBJEXT): io.h
string.$(OBJEXT): missing.h
string.$(OBJEXT): oniguruma.h
string.$(OBJEXT): probes.h
string.$(OBJEXT): re.h
string.$(OBJEXT): regex.h
string.$(OBJEXT): st.h
string.$(OBJEXT): string.c
string.$(OBJEXT): subst.h
string.$(OBJEXT): vm_opts.h
strlcat.$(OBJEXT): config.h
strlcat.$(OBJEXT): missing.h
strlcat.$(OBJEXT): strlcat.c
strlcpy.$(OBJEXT): config.h
strlcpy.$(OBJEXT): missing.h
strlcpy.$(OBJEXT): strlcpy.c
struct.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
struct.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
struct.$(OBJEXT): $(CCAN_DIR)/list/list.h
struct.$(OBJEXT): $(CCAN_DIR)/str/str.h
struct.$(OBJEXT): $(hdrdir)/ruby/ruby.h
struct.$(OBJEXT): $(top_srcdir)/include/ruby.h
struct.$(OBJEXT): config.h
struct.$(OBJEXT): defines.h
struct.$(OBJEXT): encoding.h
struct.$(OBJEXT): id.h
struct.$(OBJEXT): intern.h
struct.$(OBJEXT): internal.h
struct.$(OBJEXT): io.h
struct.$(OBJEXT): method.h
struct.$(OBJEXT): missing.h
struct.$(OBJEXT): node.h
struct.$(OBJEXT): oniguruma.h
struct.$(OBJEXT): ruby_atomic.h
struct.$(OBJEXT): st.h
struct.$(OBJEXT): struct.c
struct.$(OBJEXT): subst.h
struct.$(OBJEXT): thread_$(THREAD_MODEL).h
struct.$(OBJEXT): thread_native.h
struct.$(OBJEXT): vm_core.h
struct.$(OBJEXT): vm_debug.h
struct.$(OBJEXT): vm_opts.h
symbol.$(OBJEXT): $(hdrdir)/ruby/ruby.h
symbol.$(OBJEXT): $(top_srcdir)/include/ruby.h
symbol.$(OBJEXT): config.h
symbol.$(OBJEXT): defines.h
symbol.$(OBJEXT): encoding.h
symbol.$(OBJEXT): gc.h
symbol.$(OBJEXT): id.c
symbol.$(OBJEXT): id.h
symbol.$(OBJEXT): intern.h
symbol.$(OBJEXT): internal.h
symbol.$(OBJEXT): io.h
symbol.$(OBJEXT): missing.h
symbol.$(OBJEXT): node.h
symbol.$(OBJEXT): oniguruma.h
symbol.$(OBJEXT): probes.h
symbol.$(OBJEXT): st.h
symbol.$(OBJEXT): subst.h
symbol.$(OBJEXT): symbol.c
symbol.$(OBJEXT): symbol.h
symbol.$(OBJEXT): vm_opts.h
thread.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
thread.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
thread.$(OBJEXT): $(CCAN_DIR)/list/list.h
thread.$(OBJEXT): $(CCAN_DIR)/str/str.h
thread.$(OBJEXT): $(hdrdir)/ruby/ruby.h
thread.$(OBJEXT): $(top_srcdir)/include/ruby.h
thread.$(OBJEXT): config.h
thread.$(OBJEXT): defines.h
thread.$(OBJEXT): encoding.h
thread.$(OBJEXT): eval_intern.h
thread.$(OBJEXT): gc.h
thread.$(OBJEXT): id.h
thread.$(OBJEXT): intern.h
thread.$(OBJEXT): internal.h
thread.$(OBJEXT): io.h
thread.$(OBJEXT): method.h
thread.$(OBJEXT): missing.h
thread.$(OBJEXT): node.h
thread.$(OBJEXT): oniguruma.h
thread.$(OBJEXT): ruby_atomic.h
thread.$(OBJEXT): st.h
thread.$(OBJEXT): subst.h
thread.$(OBJEXT): thread.c
thread.$(OBJEXT): thread.h
thread.$(OBJEXT): thread_$(THREAD_MODEL).c
thread.$(OBJEXT): thread_$(THREAD_MODEL).h
thread.$(OBJEXT): thread_native.h
thread.$(OBJEXT): timev.h
thread.$(OBJEXT): vm_core.h
thread.$(OBJEXT): vm_debug.h
thread.$(OBJEXT): vm_opts.h
time.$(OBJEXT): $(hdrdir)/ruby/ruby.h
time.$(OBJEXT): $(top_srcdir)/include/ruby.h
time.$(OBJEXT): config.h
time.$(OBJEXT): defines.h
time.$(OBJEXT): encoding.h
time.$(OBJEXT): intern.h
time.$(OBJEXT): internal.h
time.$(OBJEXT): io.h
time.$(OBJEXT): missing.h
time.$(OBJEXT): oniguruma.h
time.$(OBJEXT): st.h
time.$(OBJEXT): subst.h
time.$(OBJEXT): time.c
time.$(OBJEXT): timev.h
transcode.$(OBJEXT): $(hdrdir)/ruby/ruby.h
transcode.$(OBJEXT): $(top_srcdir)/include/ruby.h
transcode.$(OBJEXT): config.h
transcode.$(OBJEXT): defines.h
transcode.$(OBJEXT): encoding.h
transcode.$(OBJEXT): intern.h
transcode.$(OBJEXT): internal.h
transcode.$(OBJEXT): io.h
transcode.$(OBJEXT): missing.h
transcode.$(OBJEXT): oniguruma.h
transcode.$(OBJEXT): st.h
transcode.$(OBJEXT): subst.h
transcode.$(OBJEXT): transcode.c
transcode.$(OBJEXT): transcode_data.h
unicode.$(OBJEXT): $(hdrdir)/ruby/ruby.h
unicode.$(OBJEXT): config.h
unicode.$(OBJEXT): defines.h
unicode.$(OBJEXT): intern.h
unicode.$(OBJEXT): missing.h
unicode.$(OBJEXT): oniguruma.h
unicode.$(OBJEXT): regenc.h
unicode.$(OBJEXT): regint.h
unicode.$(OBJEXT): st.h
unicode.$(OBJEXT): subst.h
unicode.$(OBJEXT): unicode.c
unicode.$(OBJEXT): unicode/casefold.h
unicode.$(OBJEXT): unicode/name2ctype.h
us_ascii.$(OBJEXT): config.h
us_ascii.$(OBJEXT): defines.h
us_ascii.$(OBJEXT): missing.h
us_ascii.$(OBJEXT): oniguruma.h
us_ascii.$(OBJEXT): regenc.h
us_ascii.$(OBJEXT): us_ascii.c
utf_8.$(OBJEXT): config.h
utf_8.$(OBJEXT): defines.h
utf_8.$(OBJEXT): missing.h
utf_8.$(OBJEXT): oniguruma.h
utf_8.$(OBJEXT): regenc.h
utf_8.$(OBJEXT): utf_8.c
util.$(OBJEXT): $(hdrdir)/ruby/ruby.h
util.$(OBJEXT): $(top_srcdir)/include/ruby.h
util.$(OBJEXT): config.h
util.$(OBJEXT): defines.h
util.$(OBJEXT): encoding.h
util.$(OBJEXT): intern.h
util.$(OBJEXT): internal.h
util.$(OBJEXT): io.h
util.$(OBJEXT): missing.h
util.$(OBJEXT): oniguruma.h
util.$(OBJEXT): st.h
util.$(OBJEXT): subst.h
util.$(OBJEXT): util.c
util.$(OBJEXT): util.h
variable.$(OBJEXT): $(hdrdir)/ruby/ruby.h
variable.$(OBJEXT): $(top_srcdir)/include/ruby.h
variable.$(OBJEXT): config.h
variable.$(OBJEXT): constant.h
variable.$(OBJEXT): defines.h
variable.$(OBJEXT): encoding.h
variable.$(OBJEXT): id.h
variable.$(OBJEXT): intern.h
variable.$(OBJEXT): internal.h
variable.$(OBJEXT): io.h
variable.$(OBJEXT): missing.h
variable.$(OBJEXT): node.h
variable.$(OBJEXT): oniguruma.h
variable.$(OBJEXT): st.h
variable.$(OBJEXT): subst.h
variable.$(OBJEXT): util.h
variable.$(OBJEXT): variable.c
version.$(OBJEXT): $(hdrdir)/ruby/ruby.h
version.$(OBJEXT): $(hdrdir)/ruby/version.h
version.$(OBJEXT): $(top_srcdir)/revision.h
version.$(OBJEXT): $(top_srcdir)/version.h
version.$(OBJEXT): config.h
version.$(OBJEXT): defines.h
version.$(OBJEXT): intern.h
version.$(OBJEXT): missing.h
version.$(OBJEXT): st.h
version.$(OBJEXT): subst.h
version.$(OBJEXT): version.c
vm.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
vm.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
vm.$(OBJEXT): $(CCAN_DIR)/list/list.h
vm.$(OBJEXT): $(CCAN_DIR)/str/str.h
vm.$(OBJEXT): $(hdrdir)/ruby/ruby.h
vm.$(OBJEXT): $(top_srcdir)/include/ruby.h
vm.$(OBJEXT): config.h
vm.$(OBJEXT): constant.h
vm.$(OBJEXT): defines.h
vm.$(OBJEXT): encoding.h
vm.$(OBJEXT): eval_intern.h
vm.$(OBJEXT): gc.h
vm.$(OBJEXT): id.h
vm.$(OBJEXT): insns.def
vm.$(OBJEXT): insns.inc
vm.$(OBJEXT): intern.h
vm.$(OBJEXT): internal.h
vm.$(OBJEXT): io.h
vm.$(OBJEXT): iseq.h
vm.$(OBJEXT): method.h
vm.$(OBJEXT): missing.h
vm.$(OBJEXT): node.h
vm.$(OBJEXT): oniguruma.h
vm.$(OBJEXT): probes.h
vm.$(OBJEXT): probes_helper.h
vm.$(OBJEXT): ruby_atomic.h
vm.$(OBJEXT): st.h
vm.$(OBJEXT): subst.h
vm.$(OBJEXT): thread_$(THREAD_MODEL).h
vm.$(OBJEXT): thread_native.h
vm.$(OBJEXT): vm.c
vm.$(OBJEXT): vm.h
vm.$(OBJEXT): vm.inc
vm.$(OBJEXT): vm_args.c
vm.$(OBJEXT): vm_core.h
vm.$(OBJEXT): vm_debug.h
vm.$(OBJEXT): vm_eval.c
vm.$(OBJEXT): vm_exec.c
vm.$(OBJEXT): vm_exec.h
vm.$(OBJEXT): vm_insnhelper.c
vm.$(OBJEXT): vm_insnhelper.h
vm.$(OBJEXT): vm_method.c
vm.$(OBJEXT): vm_opts.h
vm.$(OBJEXT): vmtc.inc
vm_backtrace.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
vm_backtrace.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
vm_backtrace.$(OBJEXT): $(CCAN_DIR)/list/list.h
vm_backtrace.$(OBJEXT): $(CCAN_DIR)/str/str.h
vm_backtrace.$(OBJEXT): $(hdrdir)/ruby/ruby.h
vm_backtrace.$(OBJEXT): $(top_srcdir)/include/ruby.h
vm_backtrace.$(OBJEXT): config.h
vm_backtrace.$(OBJEXT): debug.h
vm_backtrace.$(OBJEXT): defines.h
vm_backtrace.$(OBJEXT): encoding.h
vm_backtrace.$(OBJEXT): eval_intern.h
vm_backtrace.$(OBJEXT): id.h
vm_backtrace.$(OBJEXT): intern.h
vm_backtrace.$(OBJEXT): internal.h
vm_backtrace.$(OBJEXT): io.h
vm_backtrace.$(OBJEXT): iseq.h
vm_backtrace.$(OBJEXT): method.h
vm_backtrace.$(OBJEXT): missing.h
vm_backtrace.$(OBJEXT): node.h
vm_backtrace.$(OBJEXT): oniguruma.h
vm_backtrace.$(OBJEXT): ruby_atomic.h
vm_backtrace.$(OBJEXT): st.h
vm_backtrace.$(OBJEXT): subst.h
vm_backtrace.$(OBJEXT): thread_$(THREAD_MODEL).h
vm_backtrace.$(OBJEXT): thread_native.h
vm_backtrace.$(OBJEXT): vm_backtrace.c
vm_backtrace.$(OBJEXT): vm_core.h
vm_backtrace.$(OBJEXT): vm_debug.h
vm_backtrace.$(OBJEXT): vm_opts.h
vm_dump.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
vm_dump.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
vm_dump.$(OBJEXT): $(CCAN_DIR)/list/list.h
vm_dump.$(OBJEXT): $(CCAN_DIR)/str/str.h
vm_dump.$(OBJEXT): $(hdrdir)/ruby/ruby.h
vm_dump.$(OBJEXT): $(top_srcdir)/include/ruby.h
vm_dump.$(OBJEXT): addr2line.h
vm_dump.$(OBJEXT): config.h
vm_dump.$(OBJEXT): defines.h
vm_dump.$(OBJEXT): encoding.h
vm_dump.$(OBJEXT): id.h
vm_dump.$(OBJEXT): intern.h
vm_dump.$(OBJEXT): internal.h
vm_dump.$(OBJEXT): io.h
vm_dump.$(OBJEXT): iseq.h
vm_dump.$(OBJEXT): method.h
vm_dump.$(OBJEXT): missing.h
vm_dump.$(OBJEXT): node.h
vm_dump.$(OBJEXT): oniguruma.h
vm_dump.$(OBJEXT): ruby_atomic.h
vm_dump.$(OBJEXT): st.h
vm_dump.$(OBJEXT): subst.h
vm_dump.$(OBJEXT): thread_$(THREAD_MODEL).h
vm_dump.$(OBJEXT): thread_native.h
vm_dump.$(OBJEXT): vm_core.h
vm_dump.$(OBJEXT): vm_debug.h
vm_dump.$(OBJEXT): vm_dump.c
vm_dump.$(OBJEXT): vm_opts.h
vm_trace.$(OBJEXT): $(CCAN_DIR)/check_type/check_type.h
vm_trace.$(OBJEXT): $(CCAN_DIR)/container_of/container_of.h
vm_trace.$(OBJEXT): $(CCAN_DIR)/list/list.h
vm_trace.$(OBJEXT): $(CCAN_DIR)/str/str.h
vm_trace.$(OBJEXT): $(hdrdir)/ruby/ruby.h
vm_trace.$(OBJEXT): $(top_srcdir)/include/ruby.h
vm_trace.$(OBJEXT): config.h
vm_trace.$(OBJEXT): debug.h
vm_trace.$(OBJEXT): defines.h
vm_trace.$(OBJEXT): encoding.h
vm_trace.$(OBJEXT): eval_intern.h
vm_trace.$(OBJEXT): id.h
vm_trace.$(OBJEXT): intern.h
vm_trace.$(OBJEXT): internal.h
vm_trace.$(OBJEXT): io.h
vm_trace.$(OBJEXT): method.h
vm_trace.$(OBJEXT): missing.h
vm_trace.$(OBJEXT): node.h
vm_trace.$(OBJEXT): oniguruma.h
vm_trace.$(OBJEXT): ruby_atomic.h
vm_trace.$(OBJEXT): st.h
vm_trace.$(OBJEXT): subst.h
vm_trace.$(OBJEXT): thread_$(THREAD_MODEL).h
vm_trace.$(OBJEXT): thread_native.h
vm_trace.$(OBJEXT): vm_core.h
vm_trace.$(OBJEXT): vm_debug.h
vm_trace.$(OBJEXT): vm_opts.h
vm_trace.$(OBJEXT): vm_trace.c
# AUTOGENERATED DEPENDENCIES END
