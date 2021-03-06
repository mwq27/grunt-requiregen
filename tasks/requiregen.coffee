module.exports = (grunt) ->

  grunt.registerMultiTask 'requiregen', 'generate requirejs dependency tree', ->
    options = @options
      order: ['.*']
      define: false
    for group in @files
      order = options.order #  list of minimatch matching each layer
      layers = []           # the list of list of modules, ordered by load time
      chosen_modules = {}   # remember which modules were already chosen
      for rule in order
        modules = []
        matcher = grunt.file.minimatch.makeRe(rule)
        for s in group.src
          if chosen_modules.hasOwnProperty(s)
            continue
          if matcher.test(s)
            chosen_modules[s] = 1
            s = s.toString().slice(0, -3) # remove ".js" from filename before adding to the shim
            modules.push(s)
        if modules.length > 0
          layers.push modules
          grunt.log.writeln('modules "' + modules.join(", ") + '" loaded together.');
      last_layer = []
      shim = {}
      for layer in layers
        for module in layer
          shim[module] = last_layer
        last_layer = layer
      shim = JSON.stringify(shim, null, 1)
      last_layer = JSON.stringify(last_layer, null, 1)
      if options.define
        requirejs_code = "requirejs.config( { shim: #{shim} }); define(#{last_layer}, function(){})"
      else
        requirejs_code = "require( { shim: #{shim} }, #{last_layer} )"

      # Write the destination file.
      grunt.file.write(group.dest, requirejs_code);
      # Print a success message.
      grunt.log.writeln('File "' + group.dest + '" created.');
