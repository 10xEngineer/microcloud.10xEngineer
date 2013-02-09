Errata: Microcloud installation and setup

1. Vagrantfile

- comment out the shared cli and compile folders for now

2. npm install 
ZeroMQ doesn't build as is

- sudo add-apt-repository ppa:chris-lea/zeromq
- sudo add-apt-repository ppa:chris-lea/libpgm
- sudo apt-get update
- sudo apt-get install libzmq-dev

Need to install manually

- mongodb :  http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/
- redis : http://library.linode.com/databases/redis/ubuntu-12.04-precise-pangolin

3. Typo in README.md
for starting Microcloud API services (service/ not server/ ?)

- vagrant ssh
- cd /vagrant/service

4. Need to fix Nokogiri installation : libxml2 is missing

- sudo apt-get install libxslt-dev libxml2-dev
- sudo gem install nokogiri
- bundle install

5. Procfile not found but service/Procfile.sample exists

- cp service/Procfile.sample service/Procfile

6. Running foreman fails with function not found in libzmq

- wget http://download.zeromq.org/zeromq-3.2.2.tar.gz
- sudo apt-get install libtool autoconf automake
- sudo apt-get install uuid-dev
- tar xf zeromq-3.2.2.tar.gz 
- cd zeromq-3.2.2/
- ./configure
- make
- sudo make install
- sudo ldconfig

- sudo apt-get install ruby-rvm
- rvm get stable --auto
- rvm get head
- rvm install 1.9.3

Need to ensure that ffi = 1.3.1 and ffi-rzmq = 1.0.0

- updated service/Gemfile
- sudo gem install ffi  ffi-rzmq zmqmachine
- sudo bundle update ffi
- bundle exec foreman start

7. Cannot connect to mongodb database

- run mongo on a different server!!!!
