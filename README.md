Troll.opt
=========

A simple command line parser in CoffeeScript for Node applications inspired
by William Morgan's outstanding [Trollop](http://trollop.rubyforge.org/)
library for Ruby.

Troll.opt allows you to define and parse command line args in one simple
definition.

```coffeescript
Troll = require('troll').Troll

opts = (new Troll).options (troll) ->
  troll.banner "A great program that everyone should run every day"
  troll.opt 'awesome', 'Turn on the awesome', default: true
  troll.opt 'name',    'The name of the application', type: 'String', required: true
  troll.opt 'add',     'Add some more awesome', short: 'd'
```

This in turn will supply the following help document when the calling
application is invoked with the help flag: `app.coffee --help`.

```
Usage: app.coffee [options]
  A great program that everyone should run every day
       --add, -d: Add some more awesome
   --awesome, -a: Turn on the awesome (default: true)
  --name, -n <s>: The name of the application (required)
          --help: Display this text
```

If we pass that a command line like:

```bash
$ coffee test.coffee --name="something" --add
```

or:

```bash
$ coffee test.coffee --name something --add
```

or:

```bash
$ coffee test.coffee -n something -d
```

If we then inspect the contents of `opts` as defined above we see:

```coffeescript
{ name: 'something', add: true, awesome: true }
```

Features
--------

Troll.opt, like Trollop, gives you a lot of win for not much work.  Here 
are some of the things you get for free:

 * Automatic assignment of defaults
 * Automatic checking for required args
 * Multiple command line syntaxes (short opts, long opts, long opts with =)
 * Nice looking usage output

Future Additions
---------------

 * Automatic type conversion as specified with type:
 * Conversion of dashes in argument names to underscores
 * Trollop 2.0-like --no-option and --option handling for flags
