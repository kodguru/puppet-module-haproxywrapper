#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Parameters - Description of functional parameters](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Haproxywrapper is a module that utilizes the classes provided by puppetlabs-haproxy
and allows you to configure haproxy with the usage of hiera.


## Module Description

Puppetlabs-haproxy module does not allow for configuration via hiera and therefore
this wrapper script aims to resolve those.

So if you are a believer of hiera and its potential. Then look no further, heres
a module you can use to configue haproxy with the greatest creation known to mankind, hiera!

## Usage

```
haproxywrapper::global_options:
  log: '/dev/log local2'
  chroot: '/var/lib/haproxy'
  pidfile: '/var/run/haproxy.pid'
  maxconn: '4000'
  user: 'haproxy'
  group: 'haproxy'
  daemon: ''
  stats:
    - 'socket /var/lib/haproxy/stats level admin'

haproxywrapper::defaults_options:
  mode: 'http'
  log: 'global'
  option:
    - 'httplog'
    - 'dontlognull'
    - 'http-server-close'
    - 'redispatch'
  retries: '3'
  timeout:
    - 'http-request 10s'
    - 'queue 1m'
    - 'connect 10s'
    - 'client 30m'
    - 'server 30m'
    - 'http-keep-alive 10s'
    - 'check 10s'
  maxconn: '3000'

haproxywrapper::listen:
  stats:
    bind:
      '0.0.0.0:9090': ''
    mode: 'http'
    options:
      balance: ''
      stats:
        - 'uri /'
        - 'enable'
        - 'auth admin:admin'
  puppetdb_http:
    bind:
      '0.0.0.0:8080': ''
    mode: 'tcp'
    options:
      balance: 'leastconn'
      server:
        - 'puppetdb01 1.2.3.4:8080 check'
        - 'puppetdb02 1.2.3.4:8080 check port 8082'
  puppetdb_https:
    bind:
      '0.0.0.0:8081': ''
    mode: 'tcp'
    options:
      balance: 'leastconn'
      server:
        - 'puppetdb01 1.2.3.4:8081 check'
        - 'puppetdb02 1.2.3.4:8081 check port 8082'
```

## Parameters

---
#### balancermember_active (array)
Provide a list of active balancemembers to be added to the catalog. Takes the same key names provided via $balancermember.
If specified, it acts like a filter that removes all $balancermember not listed here.

Using this parameter you can deactivate balance members without needing to manipulate $balancemember.
This enables you to use a global list for $balancemember and decide specificly which members are available.
Also you can use $balancermember_active to easily disable members temporarily only.

If not specified (the default), $balancemember will not be modified.

- *Default*: undef

---


## Limitations

This module should have the same limitations as puppetlabs/puppetlabs-haproxy
this is just a wrapper.

## Development

If you feel that improvement can be made, go for it. PR's are welcome.
