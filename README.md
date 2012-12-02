Troll.opt
=========

(work in progress, but largely functioning)

A simple command line parser in CoffeeScript for Node applications inspired
by William Morgan's outstanding [Trollop](http://trollop.rubyforge.org/)
library for Ruby.

Troll.opt allows you to define and parse command line args in one simple
definition.

```coffeescript
Troll = require('troll').Troll

(new Troll).options (troll) ->
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
