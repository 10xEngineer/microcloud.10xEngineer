maintainer        "Radim Marek"
maintainer_email  "radim@opsfactory.com"
license           "Apache 2.0"
description       "Installs/Configures nodejs using package manager"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.1.0"
recipe            "default", "Installs node.js and npm"
depends           "apt"
