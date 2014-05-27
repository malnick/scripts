Preparing your environment

You will need a C compiler installed. I believe that OS X ships by default with GNU make, but if not, then you will need to obtain it or use Xcode.

Download the sources

While I'm putting all this together, I like to keep everything neatly tucked away in a build directory.
mkdir ~/build
cd ~/build
curl -OL http://downloads.sourceforge.net/tmux/tmux-1.5.tar.gz
curl -OL http://downloads.sourceforge.net/project/levent/libevent/libevent-2.0/libevent-2.0.16-stable.tar.gz
Unpack the sources

tar xzf tmux-1.5.tar.gz
tar xzf libevent-2.0.16-stable.tar.gz
Compiling libevent

cd libevent-2.0.16-stable
./configure --prefix=/opt
make
sudo make install
Compiling tmux

cd ../tmux-1.5
LDFLAGS="-L/opt/lib" CPPFLAGS="-I/opt/include" LIBS="-lresolv" ./configure --prefix=/opt
make
sudo make install
