
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /usr/lib/ruby/1.8/x86_64-linux
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
exec_prefix = $(prefix)
prefix = $(DESTDIR)/usr
sitearchdir = $(sitelibdir)/$(sitearch)
mandir = $(prefix)/share/man
psdir = $(docdir)
includedir = $(prefix)/include
pdfdir = $(docdir)
sitelibdir = $(sitedir)/$(ruby_version)
libexecdir = $(prefix)/lib/ruby1.8
localedir = $(datarootdir)/locale
docdir = $(datarootdir)/doc/$(PACKAGE)
htmldir = $(docdir)
vendorlibdir = $(vendordir)/$(ruby_version)
archdir = $(rubylibdir)/$(arch)
libdir = $(exec_prefix)/lib
sysconfdir = $(DESTDIR)/etc
bindir = $(exec_prefix)/bin
vendordir = $(libdir)/ruby/vendor_ruby
rubylibdir = $(libdir)/ruby/$(ruby_version)
infodir = $(prefix)/share/info
localstatedir = $(DESTDIR)/var
sharedstatedir = $(prefix)/com
dvidir = $(docdir)
datarootdir = $(prefix)/share
sbindir = $(exec_prefix)/sbin
vendorarchdir = $(vendorlibdir)/$(sitearch)
oldincludedir = $(DESTDIR)/usr/include
datadir = $(datarootdir)
sitedir = $(DESTDIR)/usr/local/lib/site_ruby

CC = gcc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = extconf.h
CFLAGS   =  -fPIC  -I/usr/include/ImageMagick -fopenmp 
INCFLAGS = -I. -I. -I/usr/lib/ruby/1.8/x86_64-linux -I.
DEFS     = 
CPPFLAGS = -DRUBY_EXTCONF_H=\"$(RUBY_EXTCONF_H)\"  -I/usr/include/ImageMagick
CXXFLAGS = $(CFLAGS) 
ldflags  =  -L/usr/lib -Wl,-Bsymbolic-functions -Wl,-z,relro -L/usr/lib/X11
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = $(CC) -shared
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby1.8
RUBY_SO_NAME = ruby1.8
arch = x86_64-linux
sitearch = x86_64-linux
ruby_version = 1.8
ruby = /usr/bin/ruby1.8
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir)
LIBPATH =  -L. -L$(libdir)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = 
LOCAL_LIBS =  -L/usr/lib -lMagickCore -llcms -ltiff -lfreetype -ljpeg -llqr-1 -lglib-2.0 -lfontconfig -lXext -lSM -lICE -lX11 -lXt -lbz2 -lz -lm -lgomp -lpthread -lltdl
LIBS = $(LIBRUBYARG_SHARED) -lMagickCore  -lpthread -lrt -ldl -lcrypt -lm   -lc
SRCS = rmfill.c rmmain.c rmenum.c rmmontage.c rmimage.c rmagick.c rminfo.c rmpixel.c rmdraw.c rmilist.c rmstruct.c rmutil.c
OBJS = rmfill.o rmmain.o rmenum.o rmmontage.o rmimage.o rmagick.o rminfo.o rmpixel.o rmdraw.o rmilist.o rmstruct.o rmutil.o
TARGET = RMagick2
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR = /usr/cldstr/wagn.org/wagn/ws/gems2/ruby/1.8/gems/rmagick-2.13.1/lib$(target_prefix)
RUBYARCHDIR = /usr/cldstr/wagn.org/wagn/ws/gems2/ruby/1.8/gems/rmagick-2.13.1/lib$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).so $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



$(OBJS): ruby.h defines.h Makefile rmagick.h $(RUBY_EXTCONF_H)
