[![Build Status](https://travis-ci.org/relistan/troll.opt.png)](https://travis-ci.org/relistan/troll.opt)
Troll.opt
=========

A powerful-but-simple command line parser in CoffeeScript for Node.js
apps inspired by William Morgan's awesome
[Trollop](http://trollop.rubyforge.org/) gem for Ruby.

Troll.opt allows you to define and parse command line args in one
simple definition. One line per opt: that's all you need. No chaining
long series of commands together, no multiline parsing definitions.

A simple single option defintion looks like this:

```javascript
(new Troll()).options(function(t) {
  t.opt("word", "something to talk about", {default: 'cake'})
});
```

Or, a slightly more complicated definition that takes
three different arguments and defines a help banner:

```javascript
Troll = require('troll-opt').Troll

opts = (new Troll()).options(function(troll) {
  troll.banner('Totally rad app that does something cool');
  troll.opt('awesome', 'Turn on the awesome', { default: true });
  troll.opt('name',    'The name of the application', { type: 'string', required: true });
  troll.opt('add',     'Add some more awesome', { short: 'd', default: true });
});
```

This in turn will supply the following help document when the calling
application is invoked with the help flag: `app.js --help`.

```
Usage: app.js [options]
  A great program that everyone should run every day
       --add, -d: Add some more awesome
   --awesome, -a: Turn on the awesome (default: true)
  --name, -n <s>: The name of the application (required)
          --help: Display this text
```

If we pass that a command line like:

```bash
$ ./test.js --name="something" --add
```

or:

```bash
$ ./test.js --name something --add
```

or:

```bash
$ ./test.js -n something -d
```

If we then inspect the contents of `opts` as defined above we see:

```javascript
{ name: 'something', add: true, awesome: true }
```

Features
--------

Troll.opt, like Trollop, gives you a lot of win for not much work.  Here 
are some of the things you get for free:

 * Automatic assignment of defaults
 * Automatic assignment of short flags (e.g. -n for --now)
 * Automatic checking for required args
 * Automatic type conversion for basic types
 * Multiple command line syntaxes (getopt short, getopt long with and without =)
 * Nice looking usage output

Future Additions
---------------

 * Conversion of dashes in argument names to underscores
 * Trollop 2.0-like --no-option and --option handling for flags
