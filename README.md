# Guignol

Be the puppeteer. Order your EC2 instances to start, stop, die, or be created from the command line. Let Guignol deal with DNS mappings and attaching EBS volumes.



## Getting started

Install `guignol`:

    $ gem install guignol

Guignol relies on the excellent [Fog gem](http://fog.io/) to connect to Amazon's APIs.
Start by setting up your `~/.fog`:

    ---- ~/.fog ----
    :default:
      :aws_access_key_id:      ABCDEF....
      :aws_secret_access_key:  123456....



## Creating, starting and stopping machines

Guignol doesn't care about the list of instances that live on your EC2 account,
only what it's configured to deal with.

This should prevent destroying other's instances when using (for instance) a
shared AWS/IAM account !

Teach Guignol about your instances by adding them to its config file.
Each instance needs at least a name an a UUID (both will become tags on your
instance):

    ---- ~/.guignol.yml ----
    --- 
    - :name: hello-world
      :uuid: AF123799-3F55-4F0B-8E58-87C67A5977BA

Guignol will read it's configuration from `./config/guignol.yml`, `./guignol.yml`, or `~/.guignol.yml`.

`guignol uuid` will output a new UUID if you need one.
You can also use `uuidgen` if your distro come with it.

And that's it for configuration!

Now create your instance:

    $ guignol create hello-world
    hello-world: building server...
    hello-world: updating server tags
    hello-world: waiting for public dns to be set up...
    hello-world: updating root volume tags
    hello-world: created as ec2-46-137-53-32.eu-west-1.compute.amazonaws.com

You can log in as soon as the command returns.

Of course, you can `stop`, `start`, or `kill` your instance.


### One more thing

You can run any command against multiple instances by listing names and (ruby)
regular expressions to designate lists of instances.

    $ guignol kill "hello.*"
    hello-world: tearing server down...
    hello-world: waiting for instance to become stopped or terminated...
    hello-world: instance now shutting-down
    hello-world: instance now terminated

If targeting multiple machines, guignol will run **in parallel**.



## Optional configuration

- `:domain`
  The machine's domain name. If specified, Guignol will setup a 
  CNAME in Route53 mapping *name*.*domain* to your EC2 instance where it
  starts it (and tear it down when stopping it.)

- `:region`
  The EC2 region. Defaults to `eu-west-1`.

- `:image_id`
  The AMI to use when creating this instance. Defaults to whatever Amazon defaults it to.
  
- `:flavor_id`
  The type of instance to start. Defaults to `t1.micro` (the one with a free tier).
  
- `:key_name`
  The keypair to deploy to this instance. Default to not deploying any for security reasons (meaning you probably won't be able to log in if unset, depending on the AMI you're using).
  
- `:security_group_ids`
  A list of security groups you want your instance to be a member of.

- `:user_data`
  A script to run when an instance is created.



## EBS Volumes

Yes, Guignol will also create and attach your EBS volumes when starting up instances.
Just add a `:volumes` entry to your instance configuration:

    :volumes:
      - :name: fubar-swap
        :uuid: 9D5A278E-432C-41DB-9FB5-8AF5C1BD021F
        :dev:  /dev/sdf
        :size: 4
        :delete_on_termination: true
      - :name: fubar-data
        :uuid: E180203F-9DE1-4C6A-B09B-33B2FAC8F36E
        :dev:  /dev/sdg
        :size: 20
        :delete_on_termination: false

Guignol will take care of creating your instances in the right availability zone if its volumes already exist.

Note that Guignol does not delete volumes when tearing down instances.



## Managing existing instances


You can start/stop instances even if you didn't create them with Guignol.

Simply

1. declare them in your `guignol.yml` ;
2. go to the console and add the corresponding UUID tag to the existing intances ;
3. there is no step three.

Now you can `guignol stop` your instances from the command line when not using them and save money.



## Complete config example

This one just contains 2 machines, `fubar.housetripdev.com.` and `gargantua.hosuetirpdev.com.`

    ---- ~/.guignol.yml ----
    --- 
    - :name: hello-world
      :uuid: AF123799-3F55-4F0B-8E58-87C67A5977BA
    - :name:                fubar
      :domain:              housetripdev.com.
      :uuid:                68C3C0C2-1BA3-465F-8626-E065E4EF9048
      :region:              eu-west-1
      :image_id:            ami-15f7c961                            # 32 bits
      :flavor_id:           m1.small
      :key_name:            jtl-laptop
      :security_group_ids:  
        - sg-7e638109                                               # housetrip-basic
      :volumes:
        - :name: fubar-swap
          :uuid: 9D5A278E-432C-41DB-9FB5-8AF5C1BD021F
          :dev:  /dev/sdf
          :size: 4
          :delete_on_termination: true
        - :name: fubar-data
          :uuid: E180203F-9DE1-4C6A-B09B-33B2FAC8F36E
          :dev:  /dev/sdg
          :size: 20
          :delete_on_termination: false
      :user_data: |
        #!/bin/sh
        set -x
        if test -z "$LOGGING" ; then
          export LOGGING=YES
          exec "$0" > /tmp/user_data.log 2>&1
        fi
    
        mkswap -f /dev/xvdf > /dev/null && swapon /dev/xvdf
    
        mount_data() {
          mount -t ext4 /dev/xvdg /mnt
        }
        mount_data || { mkfs.ext4 /dev/xvdg && mount_data ; }
        date >> /tmp/stamp

