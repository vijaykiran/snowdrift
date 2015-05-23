# Snowdrift setup instructions for Arch Linux

Arch has the benefit of being very well-documented, so this document is
very short!

1.  [Install Haskell][1]. While you are at it, make sure you have the
    `base-devel` group installed.
2.  [Install PostgreSQL][2]. You don't need to go through setting up a
    user or anything like that. Snowdrift will do that for you.
3.  Run these commands:

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
