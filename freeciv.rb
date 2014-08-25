require 'formula'

class Freeciv < Formula
  homepage 'http://freeciv.wikia.com'
  url 'https://downloads.sourceforge.net/project/freeciv/Freeciv%202.4/2.4.3/freeciv-2.4.3.tar.bz2'
  sha1 'ed7473e28c53e4bfbfc2535c15c7ef17d4e34204'
  head 'svn://svn.gna.org/svn/freeciv/trunk'

  option 'disable-nls' , 'Disable NLS support'
  option 'disable-sdl' , 'Disable the SDL Freeciv client'
  option 'disable-gtk' , 'Disable the GTK Freeciv client'
  option 'enable-gtk3' , 'Enable the GTK3 Freeciv client'

  depends_on 'pkg-config' => :build
  depends_on 'readline'
  depends_on :x11
  depends_on 'gettext' unless build.include? 'disable-nls'

  if !build.include? 'disable-sdl'
    depends_on 'sdl'
    depends_on 'sdl_image'
    depends_on 'sdl_mixer'
  end
  if !build.include? 'disable-gtk'
    depends_on 'glib'
    depends_on 'gtk+'
  end
  if build.include? 'enable-gtk3'
    depends_on 'glib'
    depends_on 'gtk+3'
  end

  def install
    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}"]

    if build.include? 'disable-nls'
      args << "--disable-nls"
    else
      gettext = Formula["gettext"]
      args << "CFLAGS=-I#{gettext.include}"
      args << "LDFLAGS=-L#{gettext.lib}"
    end

    build_client = []
    if !build.include? 'disable-sdl'
      build_client << "sdl"
    end
    if !build.include? 'disable-gtk'
      build_client << "gtk"
    end
    if build.include? 'enable-gtk3'
      build_client << "gtk3"
    end
    args << "--enable-client=" + build_client.join(",") unless build_client.empty?
    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/freeciv-server", "-v"
  end
end
