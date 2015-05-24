# Snowdrift setup instructions for Arch Linux

## Installing stuff

The Arch Wiki has documentation on the main dependent components:

*.  [Install Haskell][1], including the Haskell development tools
    and setting $PATH.
*.  [Install PostgreSQL][2]. You only need to go through the
    "installing" step. We have a script, `sdm`, that will take care of
    setting up a user, and everything thereafter.

With that done, clone the Snowdrift code:

**Important**: as of 2015-05-23, the mainline Snowdrift repository
doesn't support the newest version of GHC, which Arch has in its
official repositories. So, you have to use `pharpend`'s branch.

    git clone https://github.com/pharpend/snowdrift.git

Install and run Snowdrift:

    cd snowdrift
    cabal install yesod-bin
    ln -s cabal.config.7.10 cabal.config
    cabal sandbox init
    cabal install -fdev
    sdm init
    cabal install -fdev --enable-tests
    yesod devel

The site should now be running on <http://localhost:3000>.

Now you can play with Snowdrift locally.
To log into the site, use the built-in system with
user: `admin` pass: `admin`

## Workflow

Once going, `yesod devel` can stay running in one terminal while
you do work elsewhere.
It will rebuild and rerun the site whenever it detects file changes.

In cases where `yesod devel` fails to detect changes,
stop it with the Enter key, then run:

    cabal clean && yesod devel

If you add new dependencies (i.e. edit the `build-depends` field in
`Snowdrift.cabal`), you will need to run:

    cabal install -fdev

## More resources

See [BEGINNERS.md](BEGINNERS.md) for general info about contributing
and learning about the tools we use,
and see [GUIDE.md](GUIDE.md) for more technical details.

[1]: https://wiki.archlinux.org/index.php/Haskell
[2]: https://wiki.archlinux.org/index.php/Postgresql
