# Snowdrift setup instructions for Arch Linux

## Installing stuff

The Arch Wiki already has documentation on the individual components, so
I'll just link to those sequentially.

1.  [Install Haskell][1].
2.  [Install PostgreSQL][2]. You only need to go through the
    "installing" step. We have a script, `sdm`, that will take care of
    setting up a user, and everything thereafter.
3.  Run these commands:

        git clone https://github.com/pharpend/snowdrift.git

    **Important**: as of 2015-05-23, the mainline Snowdrift repository
    doesn't support the newest version of GHC, which Arch has in its
    official repositories. So, you have to use `pharpend`'s branch.

        cd snowdrift
        ln -s cabal.config.7.10 cabal.config
        cabal sandbox init
        cabal install -fdev
        sdm init
        cabal install -fdev --enable-tests
        yesod devel

The site should now be running on <http://localhost:3000>.

If you get an error "command not found: sdm", or "command not found:
yesod", when you try to run those respective commands, make sure that
`.cabal-sandbox/bin` is in your path. Note that this is a relative path,
not an absolute path.

## Workflow

`yesod devel` will stay running in one terminal while you do work
elsewhere. It will rebuild the site whenever you change certain
files. Often times, it won't detect changes. In which case, stop `yesod
devel` by hitting `Return` a few times, then start it up again.

If that doesn't work, try killing `yesod devel`, then

    cabal clean && cabal install -fdev --enable-tests && yesod devel

## More resources

See [BEGINNERS.md](BEGINNERS.md) for general info about contributing
and learning about the tools we use,
and see [GUIDE.md](GUIDE.md) for more technical details.

[1]: https://wiki.archlinux.org/index.php/Haskell
[2]: https://wiki.archlinux.org/index.php/Postgresql
