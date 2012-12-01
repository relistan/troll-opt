util = require('util')

class CaptureIO

  # Coffeescript port of: https://gist.github.com/729616
  #
  # Usage:
  #   unhook = test.hookStdout((string, encoding, fd) ->
  #     util.debug('stdout: ' + util.inspect(string))
  #   )
  # Restoring stdout:
  #   unhook()

  hookStdout: (callback) ->
    old_write = process.stdout.write
  
    process.stdout.write = ((write) ->
      (string, encoding, fd) ->
        callback string, encoding, fd
    )(process.stdout.write)
  
    -> process.stdout.write = old_write

exports.CaptureIO = CaptureIO
