[![Build Status](https://travis-ci.org/relistan/troll-opt.png)](https://travis-ci.org/relistan/troll-opt)
Troll-opt
=========

A powerful-but-simple command line parser for Node.js apps, 
inspired by William Morgan's awesome [Trollop](http://trollop.rubyforge.org/) 
gem for Ruby.

Troll-opt allows you to define and parse command line args in one
simple definition. One line per opt: that's all you need. No chaining
long series of commands together, no multiline parsing definitions.

Using it
--------

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
  troll.banner('Web listener that always responds with a defined message');
  troll.opt('errors',  'Issue random errors to some responses', { default: true });
  troll.opt('name',    'The name of the application', { type: 'string', required: true });
  troll.opt('code',    'The normal response code to generate', { short: 'o', default: 200 });
});
```

This in turn will supply the following help document when the calling
application is invoked with the help flag: `app.js --help`.

```
Usage: app.js [options]
  Web listener that always responds with a defined message
  --code, -o <n>: The normal response code to generate (default: 200)
    --errors, -e: Issue random errors to some responses (default: false)
  --name, -n <s>: The name of the application (required)
          --help: Display this help text
```

If we pass that a command line like:

```bash
$ ./test.js --name="something" --errors --code 201
```

or:

```bash
$ ./test.js --name something --errors --code 201
```

or:

```bash
$ ./test.js -n something -e -o 201
```

we then get the following contents of `opts` as defined above:

```javascript
{ name: 'something', errors: true, code: 201 }
```

Multi-Word Arguments
--------------------

Troll-opt will do camelCase conversion of options for you for mulit-word
command line arguments.

```bash
$ ./test.js --lib-path /usr/lib
```

Generates the options object:

```javascript
{ libPath: '/usr/lib' }
```

You assign these in the definition in camelCase and the command line parser does
the translation from ```lib-path``` to ```libPath``` before doing the lookup:

```javascript
opts = (new Troll()).options(function(troll) {
  troll.opt('libPath', 'Path to the libraries', { default: '/usr/lib/' });
```

Remaining Arguments
-------------------

Any arguments that are supplied at the end of the command line, but which are not
options to the previous argument are available via the following mechanism.

Given that the following command is issued:

```bash
$ ./test.js --lib-path /usr/lib some-extra-argument another-one
```

You will need to keep the handle on the original `Troll` instance. This can then
be used to access the remaining arguments on the command line like so:

```javascript
troll = new Troll()
troll.options(function(troll) {
  troll.opt('libPath', 'Path to the libraries', { default: '/usr/lib/' });
```

`troll.argv` will then contain:

```javascript
[ 'some-extra-argument', 'another-one' ]
```

Features
--------

Troll-opt, like Trollop, gives you a lot of win for not much work.  Here 
are some of the things you get for free:

 * Automatic assignment of defaults
 * Automatic assignment of short flags (e.g. -n for --now)
 * Automatic checking for required args
 * Automatic type conversion for basic types
 * Multiple command line syntaxes (getopt short, getopt long with and without =)
 * Nice looking usage output
 * Conversion of multi-word command line arguments to camelCase

Future Additions
---------------

 * Trollop 2.0-like --no-option and --option handling for flags
