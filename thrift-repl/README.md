EzBake Thrift REPL
===

Overview
---

The thrift read-eval-print-loop (REPL) for EzBake allows users to call methods on thrift services dynamically in an 
interactive shell.  The base language is JRuby to interact with the shell but primarily everything can be called 
in a straightforward manner of the form:

    method_name parameter1, parameter2, ...

Requirements
---

 * JRuby 1.7.x -> http://www.jruby.org/download
 * Maven (needs to be on the path as `mvn`)

Usage
---

The REPL can run in one of two modes and always targets a single service. The `target` parameter determines whether the 
REPL will create a service handler locally or try to use ezDiscovery to find the service.

The default is to create a service handler locally.  Any backend services that may need to be set up (elasticsearch or 
ezSecurity for example) that the target service depends on must be running or it will fail to start.  

The ezbake-config.properties.default file lists the default properties used to start the service.  If you need to modify
the properties edit the generated ezbake-config.properties file.

To start you must initialize the jars; if the service you wish to run has a maven group:artifact of 'ezbake:test-service'
you can run the following to initialize the jars and connect locally:

    jruby shell.rb -i ezbake:test-service
    
Once you initialize the jars you don't need to do it again unless your target service or jars change.

To use EzDiscovery to connect you'll need the service name it was deployed with:

    jruby shell.rb -t discover:serviceName group:artifact

To get more command help run:

    jruby shell.rb --help
    
### In the shell

If you're not familiar with Ruby syntax you can read up on that here: 
http://www.smashingmagazine.com/2012/05/24/beginners-guide-ruby/

Visibility has become more complicated as of 2.0 and thus there is special syntax supported for creating visibilities.

    <formal authorizations/CAPCO>:<external auths boolean string>:<platform visibilities>:<provenance id>:<composite flag>
    
Where the fields are described below:

 1. *Formal authorizations/CAPCO* - Formal authorizations string, a CAPCO classification would be an example. 
   * UNCLASSIFIED//REL TO FVEY
 1. *External auths* - A string of external groups with boolean combinations supported.  
   * A|B|(C&D)
 1. *Platform visibilities* - Separate read/write/discover/manage groups for internal platform groups.  Each one of these
    visibilies is a set of 64-bit integers representing the group memberships that are required to perform the given action.
    Some data layers will ignore these groups for some operations.
   * r(1,2,3)w(1,3,5)
   * d(1,2,3,4,5)m(3,5,8)
 1. *Provenance ID* - A 64-bit integer from the provenance service.  This is used for purge and dependency tracking.
 1. *Composite Flag* - A boolean value (true/false) indicating if the item is a composite object.

Once you're in the shell there are some special commands you can use:

 * Call any methods on the service using their name: `> some_method a, b, c`
 * Get help on the available service methods: `> help`
 * Get a fake security token: `> fake_token` or with a auths: `> fake_token(%w(U S TS))
 * Get a fake Visibility: `> fake_vis` or with a visibility string: `> fake_vis('U:A|B|C::12345:false')`
 * Turn coloring on/off: `> allow_colors true/false`
 * Exit: `exit/quit`
 

