hashicorp-demo
==============

Some demo projects for [hashicorp](http://hashicorp.com) products

#consul

##consul1

This is a demo of consul, using Vagrant and Virtualbox.

![consul1.png](https://raw.githubusercontent.com/kikitux/hashicorp-demo/master/consul1.png)

### Filesystem structure

In order to keep things simple, and put the focus on `consul`, this demo came with 3 folder :

    |-- consul1
    |   |-- docker-dc1
    |   |-- docker-dc2
    |   `-- host

On each folder, there is a `Vagrantfile` so you can take this a module base, and adjust to a more complex scenario.

### First start docker host

On host directory, a multi-machine will take care to start 2 vms for docker.

These vms will be `host1` and `host2`, using [kikitux/oracle6](https://vagrantcloud.com/kikitux/boxes/oracle6) image from [vagrantcloud](http://vagrantcloud.com)

As tipical since Vagrant 1.5+ on first run, the base box will be downloaded and the provisioners will be executed.

As part of the setup, [kikitux/oracle6:latest](https://registry.hub.docker.com/u/kikitux/oracle6) docker image will be pull, and consul will be downloaded.

Consul zip files and the docker image will be exported to /vagrant, so the 2nd host machine and future run will be faster, not requiring to download these files again.

Each host will create his own datacenter, and using a shell provisioner they will try to join the other datacenter.

If on first run this doesn't happen, all the logic in the scripts is idempotent, so you are safe to run `vagrant provision` a 2nd time to make this to happen.

As part of this demo, in order to get exposure to the [consul-ui](http://www.consul.io/downloads_web_ui.html) each host machine will download and configure nginx with proxy-pass to `localhost:8500/ui` and `localhost:8500/v1`, and nginx port will be exposed to the host.

Using vagrant networking, we will map 

- `host:8001` to `host1:80`
- `host:8002` to `host2:80`

Once our base boxes have been createdm you cab access the consul ui, just point your browser on the host machine to `http://localhost:8001/ui`

![host1 dc1](https://lh5.googleusercontent.com/-68X2YSBqXFI/VDi7ZgJqSbI/AAAAAAAAAH4/8XnALOsWdvs/s0/2014-10-11_18-08-56.png)

![host2 dc2](https://lh5.googleusercontent.com/-61O-IMne90Y/VDi7qRozWiI/AAAAAAAAAIA/XObyNWt5nVU/s0/2014-10-11_18-10-03.png)

On mac mini this take around 8 minutes with ssd and fast internet pipe. YMMV

Now that both nodes are up and running we can run `vagrant provision` in order to ensure the 2 nodes connect to each other.

As we will connect 2 `dc`, this is done with a `consul join -wan <ip>`

on node1:

    ==> host2: Running provisioner: shell...
        host2: Running: inline script
    ==> host2: Node   Address             Status  Type    Build  Protocol
    ==> host2: host2  192.168.10.12:8301  alive   server  0.4.0  2
    ==> host2: Successfully joined cluster by contacting 1 nodes.

on node2:

    ==> host2: Running provisioner: shell...
        host2: Running: inline script
    ==> host2: Node   Address             Status  Type    Build  Protocol
    ==> host2: host2  192.168.10.12:8301  alive   server  0.4.0  2
    ==> host2: Successfully joined cluster by contacting 1 nodes.

Now both datacenters are connected, and they share what they manage, and both `dc` are available on the web, like this:

![both_dc](https://lh5.googleusercontent.com/-JnUkCgQF3fQ/VDi-7RSrZxI/AAAAAAAAAIM/q7U1aQ3obR8/s0/2014-10-11_18-24-00.png)

This is done with a simple shell provisioner common for both nodes:

    config.vm.provision "shell", inline: "/usr/local/bin/consul members && ([ ${HOSTNAME#host} -eq 2 ] && /usr/local/bin/consul join -wan 192.168.10.11 || /usr/local/bin/consul join -wan 192.168.10.12) || true "

As part of the configuration of the host machines, each node send consul logs to `/vagrant/consul_host<n>.log` so you can do a `tail -f consul_host*.log` to monitor what's going on in the hosts:

Example:

    ==> consul_host1.log <==
        2014/10/11 05:11:29 [INFO] serf: EventMemberJoin: host2.dc2 192.168.10.12
    ==> consul_host2.log <==
        2014/10/11 05:11:29 [INFO] consul: adding server host1.dc1 (Addr: 192.168.10.11:8300) (DC: dc1)

    ==> consul_host1.log <==

        2014/10/11 05:11:29 [INFO] agent: (WAN) joined: 1 Err: <nil>
        2014/10/11 05:11:29 [INFO] consul: adding server host2.dc2 (Addr: 192.168.10.12:8300) (DC: dc2)
        2014/10/11 05:11:32 [INFO] agent.rpc: Accepted client: 127.0.0.1:33553

    ==> consul_host2.log <==
        2014/10/11 05:11:35 [INFO] agent.rpc: Accepted client: 127.0.0.1:34095
        2014/10/11 05:11:35 [INFO] agent.rpc: Accepted client: 127.0.0.1:34096
        2014/10/11 05:11:35 [INFO] agent: (WAN) joining: [192.168.10.11]
        2014/10/11 05:11:35 [INFO] agent: (WAN) joined: 1 Err: <nil>
        2014/10/11 05:11:37 [INFO] agent.rpc: Accepted client: 127.0.0.1:34098

Checking our nodes on each `dc` we see this:

![nodes_dc1](https://lh5.googleusercontent.com/-bw5wW6LWNKg/VDi_eFJAcRI/AAAAAAAAAIU/KResI3INZx8/s0/2014-10-11_18-26-18.png)

![nodes_dc2](https://lh4.googleusercontent.com/-orZPGU4jrIg/VDi_nBG3EUI/AAAAAAAAAIc/mElbxR79Vjo/s0/2014-10-11_18-26-54.png)

Time to populate our datacenter with some docker containers:

###Docker containers on dc1

Go into the directory for dc1

    $ cd ../docker-dc1/
    $ vagrant status
    Current machine states:
    dc1-db                    not created
    dc1-web01                 not created
    dc1-web02                 not created
    dc1-web03                 not created


Let's create the boxes on `dc1` with `vagrant up --provider=docker`

The Dockerfile used for this is very simple:

    FROM kikitux/oracle6-consul:latest
    MAINTAINER Alvaro Miranda kikitux@gmail.com
    EXPOSE 22
    CMD service sshd restart && consul agent -data-dir=/var/tmp/consul/ -join=$JOIN -dc=$DC

The `service sshd restart` is optional, but handy. This will allow us to ssh into the container and do normal operations.

A nice trick for prototyping and getting your hands on these docker containers.

And, `kikitux/oracle6-consul` is created by this `Dockerfile`

    FROM kikitux/oracle6:latest
    MAINTAINER Alvaro Miranda kikitux@gmail.com
    RUN useradd vagrant && \
        mkdir ~vagrant/.ssh && \
        chmod 700 ~vagrant/.ssh && \
        echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' | tee -a ~vagrant/.ssh/authorized_keys && \
        chmod 600 ~vagrant/.ssh/authorized_keys && \
        chown -R vagrant: ~vagrant/.ssh && \
        sed -i -e '/# %wheel\tALL=(ALL)\tNOPASSWD: ALL/a vagrant\tALL=(ALL)\tNOPASSWD: ALL' /etc/sudoers
    RUN curl -L -o /usr/local/0.4.0_linux_amd64.zip https://dl.bintray.com/mitchellh/consul/0.4.0_linux_amd64.zip && \
        unzip /usr/local/0.4.0_linux_amd64.zip -d /usr/local/bin/ && \
        rm /usr/local/0.4.0_linux_amd64.zip

Few minutes later, you should see the following on the log files:

    ==> consul_host1.log <==
        2014/10/11 05:31:42 [INFO] serf: EventMemberJoin: dc1-db 172.17.0.2
        2014/10/11 05:31:42 [INFO] consul: member 'dc1-db' joined, marking health alive
        2014/10/11 05:31:44 [INFO] serf: EventMemberJoin: dc1-web03 172.17.0.3
        2014/10/11 05:31:44 [INFO] consul: member 'dc1-web03' joined, marking health alive
        2014/10/11 05:31:49 [INFO] serf: EventMemberJoin: dc1-web02 172.17.0.4
        2014/10/11 05:31:49 [INFO] consul: member 'dc1-web02' joined, marking health alive
        2014/10/11 05:31:49 [INFO] serf: EventMemberJoin: dc1-web01 172.17.0.5
        2014/10/11 05:31:49 [INFO] consul: member 'dc1-web01' joined, marking health alive

 A refresh on our node list on dc1 will came up with the following:

 ![nodes_dc1](https://lh3.googleusercontent.com/-w1Dae_qfpLM/VDjBNuqAUoI/AAAAAAAAAIo/5hnQkFzZ4Lc/s0/2014-10-11_18-33-44.png)

 Repeat for dc2

###Docker containers on dc2

    cd ../docker-dc2
    vagrant up --provider=docker

      Bringing machine 'dc2-web01' up with 'docker' provider...
      Bringing machine 'dc2-web02' up with 'docker' provider...
      Bringing machine 'dc2-web03' up with 'docker' provider...
      ==> dc2-web01: Docker host is required. One will be created if necessary...
      ==> dc2-db: Docker host is required. One will be created if necessary...
      ==> dc2-web03: Docker host is required. One will be created if necessary...

After few minutes, our log file will show:

    ==> consul_host2.log <==
        2014/10/11 05:36:47 [INFO] serf: EventMemberJoin: dc2-web02 172.17.0.2
        2014/10/11 05:36:47 [INFO] consul: member 'dc2-web02' joined, marking health alive
        2014/10/11 05:36:47 [INFO] serf: EventMemberJoin: dc2-web03 172.17.0.3
        2014/10/11 05:36:47 [INFO] consul: member 'dc2-web03' joined, marking health alive
        2014/10/11 05:36:51 [INFO] serf: EventMemberJoin: dc2-web01 172.17.0.4
        2014/10/11 05:36:51 [INFO] consul: member 'dc2-web01' joined, marking health alive
        2014/10/11 05:36:53 [INFO] serf: EventMemberJoin: dc2-db 172.17.0.5
        2014/10/11 05:36:53 [INFO] consul: member 'dc2-db' joined, marking health alive

 And we can check the node view on the `ui`, from any node as the information is propagated by `consul`

 ![nodes_dc2_from_dc1](https://lh3.googleusercontent.com/-YBCw5aapaFg/VDjCeJqCiYI/AAAAAAAAAIw/nLNZFvyb_DI/s0/2014-10-11_18-39-06.png)

### ssh into the containers

 From our directory for each dc, we can use `vagrant ssh <container>`, example:

    $ vagrant ssh dc1-db
    ==> dc1-db: SSH will be proxied through the Docker virtual machine since we're
    ==> dc1-db: not running Docker natively. This is just a notice, and not an error.
    Warning: Permanently added '172.17.0.4' (RSA) to the list of known hosts.
    Last login: Sat Oct 11 02:24:35 2014 from 172.17.42.1
    [vagrant@dc1-db ~]$ sudo su -
    [root@dc1-db ~]# hostname
    dc1-db

Each host serve the consul zone by `dnsmasq`, and each container inherit this, so `.consul` dns works out of the box.

    [root@dc1-db ~]# host dc1-db.node.dc1.consul
    dc1-db.node.dc1.consul has address 172.17.0.4
    [root@dc1-db ~]# host dc1-web01.node.dc1.consul
    dc1-web01.node.dc1.consul has address 172.17.0.5
    [root@dc1-db ~]# host dc1-web02.node.dc1.consul
    dc1-web02.node.dc1.consul has address 172.17.0.2
    [root@dc1-db ~]# host dc1-web03.node.dc1.consul
    dc1-web03.node.dc1.consul has address 172.17.0.3

Test `dc2-db` on `dc2`

		$ vagrant ssh dc2-db
		==> dc2-db: SSH will be proxied through the Docker virtual machine since we're
		==> dc2-db: not running Docker natively. This is just a notice, and not an error.
		Warning: Permanently added '172.17.0.5' (RSA) to the list of known hosts.
		[vagrant@dc2-db ~]$ sudo su -
		[root@dc2-db ~]# host dc2-db.node.dc2.consul
		dc2-db.node.dc2.consul has address 172.17.0.5
		[root@dc2-db ~]#

[Alvaro](http://github.com/kikitux)
