Pre-reqs:

Have ChefDK installed.

Usage:

From the command line run `chef exec ruby report.rb automate.fqdn automate-enterprise automate-token automate-user role`

for example, if I wanted to run a report against the automate.awesome.co Automate server, on the success enterprise, with a token of abc123, as the awesome user searching on the "web_server" role, I'd do the following:

`chef exec ruby report.rb automate.awesome.co success abc123 awesome web_server`
