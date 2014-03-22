# atom-ruby-bundler

Run `bundle install` directly from Atom with `alt-cmd-b`

![](http://f.cl.ly/items/2h3U3b3N461J421a2f2p/cero%202014-03-01%2003-53-42.jpg)

If you like it, and find it useful, and are rolling in money consider [buying it](https://gum.co/PdwU).


# Gotchas

If you're using rbenv, you need to make sure your PATH is set correctly for Atom.  You can do this inside of the `~/.atom/init.coffee` file.

Add a line like this for rbenv:

```coffee
process.env.PATH = "#{process.env.HOME}/.rbenv/shims:#{process.env.HOME}/.rbenv/bin:#{process.env.PATH}"
```

There may be a similar process to get RVM to work, but I don't have any experience with it.  Post an issue if you're having trouble getting RVM to load properly.
