# Snowdrift setup instructions for Arch Linux

The Arch Wiki already has documentation on the individual components, so
I'll just link to those sequentially.

1.  [Install Haskell][1].
2.  `pacman -S base-devel`
3.  [Install PostgreSQL][2]. You only need to go through the
    "installing" step. We have a script, `sdm`, that will take care of
    setting up a user, and everything thereafter.
4.  Run these commands:

        git clone https://git.gnu.io/snowdrift/snowdrift.git
        cd snowdrift
        ln -s cabal.config.7.10 cabal.config
        cabal sandbox init
        cabal install -j -fdev --enable-tests
        sdm init
        Snowdrift Development

The site should now be running on <http://localhost:3000>.

[1]: https://wiki.archlinux.org/index.php/Haskell
[2]: https://wiki.archlinux.org/index.php/Postgresql
