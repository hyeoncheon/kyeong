# Kyeong

Event collector and forwarder for Hyeoncheon Elastic.
But basically, It is just a simple plugin executor for ruby.

## Features

* Configure with standard json syntax.
* Initialize and run configured class with given argument.
* Daemonize and controlled by start/stop commands.

## Install

Just clone it.

## Usage

Start daemon:

```console
$ ./kyeong.rb start
Loading configuration from config.json...
  - Loading plugin echo... OK.
  - Loading plugin echo... OK.
  2 workers are configured.
Starting Kyeong workers...
$ 
```

Stop daemon:

```console
$ ./kyeong.rb stop
Terminate the process... done!
$ 
```

Sample config:

```json
[
  {
    "plugin": "echo",
    "arguments": { "say": "Hello", "interval": 10 }
  },
  {
    "plugin": "echo",
    "arguments": { "say": "World", "interval": 5 }
  }
]
```

## Author

Yonghwan SO <https://github.com/sio4>

## Copyright

Copyright 2016 Yonghwan SO

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

