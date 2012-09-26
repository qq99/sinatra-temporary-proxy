Overview
========

This sample Sinatra application aims to provide a basic proxying method from obfuscated routes to internal routes.  Please see the examples to understand some potential use-cases.  I do not have any plans at this time to convert this code into a formal module of any kind.

Usage
=====

The easiest way is to use the development server:
    
	ruby app.rb

From there, define your named routes however you normally would.  /:name, /index, and /404 have been created as examples of routes you might have.

In the `/views/temp` (or the path referred to by @proxy_directory), you will create JSON objects that correspond to named routes.

Examples
========

A single-use proxy:
-------------------

`#{app_root}/#{proxy_directory}/this_link_will_self_desctruct.json` :

	{
		"to": "/index",
		"remainingUsages": 1
	}

The idea is that you'd give the visitor a URL, `/temp/this_link_will_self_destruct`, the user visits the link, the proxy (the JSON file) is parsed and modified, and then any subsequent GETs will be impossible.  The JSON file is never destroyed, so you can easily verify that it is working or was consumed.

A single-IP proxy:
-------------------

`#{app_root}/#{proxy_directory}/your_eyes_only.json` :

	{
		"to": "/index",
		"maxIPs": 1,
	}

In this case, a list of IPs is logged inside the JSON file.  If the requester's IP is not found in the file, he is rejected.

Mixing and matching:
--------------------

Mix parameters of the above for your odd use-case scenarios.

Time-limited:
-------------

Not implemented yet.  Should be very easy to make

Disclaimer
==========

This is not vetted for any kind of serious production environment.  It might be horribly insecure!  I make no guarantees of the security of this software, nor any recommendations to use it.  