# Bootstrap

Part of the Discovery Service
 
### To generate new client / server configs ###

Bootstrap uses the 'ArgumentParser' library to parse and execute command line arguments.

From the Bootstrap directory in your macOS / Linux command line terminal;

• To see what subcommands you have available to you:

$ swift run

```
example print out
USAGE: Bootstrap <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  new
  run

  See 'Bootstrap help <subcommand>' for detailed help.
```
===

• To create new client / server configs:

$ swift run Bootstrap new <exampleConfigName> <port>

```
Wrote config to ~/Bootstrap-server.json
Wrote config to ~/Bootstrap-client.json
```
===

• To run the server:

$ swift run Bootstrap run

```
...
Server started 🚀
Server listening 🪐
...
```
