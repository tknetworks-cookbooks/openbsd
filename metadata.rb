maintainer       "TKNetworks"
maintainer_email "nabeken@tknetworks.org"
license          "Apache 2.0"
description      "Installs/Configures openbsd"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.2"
name             "openbsd"
supports         "openbsd"

%w{sysctl chef-openbsd}.each do |dep|
  depends dep
end
