astrails-safe
=============

Simple database and filesystem backups with S3 support (with optional encryption)

Home: github.com/astrails/safe

Motivation
----------

We needed a backup solution that will satisfy the following requirements:

* opensource
* simple to install and configure
* support for simple ‘tar’ backups of directories (with includes/excludes)
* support for simple mysqldump of mysql databases
* support for symmetric or public key encryption
* support for local filesystem and Amazon S3 for storage
* support for backup rotation. we don’t want backups filling all the diskspace or cost a fortune on S3

And since we didn't find any, we wrote our own :)

Contributions
-------------

The following functionality was contributed by astrails-safe users:

* PostgreSQL dump using pg_dump (by Mark Mansour <mark@stateofflux.com>)
* Subversion dump using svndump (by Richard Luther <richard.luther@gmail.com>)
* SFTP remote storage (by Adam <adam@mediadrive.ca>)
* benchmarking output (By Neer)


Thanks to all :)

Reporting problems
------------------

Please report problems at the [Issues tracker](http://github.com/astrails/safe/issues)

Usage
-----

    Usage:
       astrails-safe [OPTIONS] CONFIG_FILE
    Options:
      -h, --help           This help screen
      -v, --verbose        be verbose, duh!
      -n, --dry-run        just pretend, don't do anything.
      -L, --local          skip S3

Note: CONFIG_FILE will be created from template if missing

Encryption
----------

If you want to encrypt your backups you have 2 options:
* use simple password encryption
* use GPG public key encryption

For simple password, just add password entry in gpg section.
For public key encryption you will need to create a public/secret keypair.

We recommend to create your GPG keys only on your local machine and then
transfer your public key to the server that will do the backups.

This way the server will only know how to encrypt the backups but only you
will be able to decrypt them using the secret key you have locally. Of course
you MUST backup your backup encryption key :)
We recommend also pringing the hard paper copy of your GPG key 'just in case'.

The procedure to create and transfer the key is as follows:

1. run 'gpg --gen-key' on your local machine and follow onscreen instructions to create the key
   (you can accept all the defaults).

2. extract your public key into a file (assuming you used test@example.com as your key email):
   gpg -a --export test@example.com > test@example.com.pub

3. transfer public key to the server
   scp test@example.com.pub root@example.com:

4. import public key on the remote system:
<pre>
   $ gpg --import test@example.com.pub
   gpg: key 45CA9403: public key "Test Backup <test@example.com>" imported
   gpg: Total number processed: 1
   gpg:               imported: 1
</pre>

5. since we don't keep the secret part of the key on the remote server, gpg has
   no way to know its yours and can be trusted.
   To fix that we can sign it with other trusted key, or just directly modify its
   trust level in gpg (use level 5):
   <pre>
     $ gpg --edit-key test@example.com
     ...
     Command> trust
     ...
     1 = I don't know or won't say
     2 = I do NOT trust
     3 = I trust marginally
     4 = I trust fully
     5 = I trust ultimately
     m = back to the main menu

     Your decision? 5
     ...
     Command> quit
   </pre>

6. export your secret key for backup
   (we recommend to print it on paper and burn to a CD/DVD and store in a safe place):
   <pre>
   $ gpg -a --export-secret-key test@example.com > test@example.com.key
   </pre>


Example configuration
---------------------
<pre>
  safe do
    local :path => "/backup/:kind/:id"

    s3 do
      key "...................."
      secret "........................................"
      bucket "backup.astrails.com"
      path "servers/alpha/:kind/:id"
    end
    
    rcloud do
      username "username"
      api_key "key"
      container "backups"
      path ":kind/"
    end

    sftp do
      host "sftp.astrails.com"
      user "astrails"
      password "ssh password for sftp"
    end

    gpg do
      # symmetric encryption key
      # password "qwe"

      # public GPG key (must be known to GPG, i.e. be on the keyring)
      key "backup@astrails.com"
    end

    keep do
      local 2
      s3 2
    end
    
    notification do
      subject "safe backup failure"
      host "mail.example.com"
      domain "example.com"
      username "safe@example.com"
      password "example"
      authentication :login
      port 25
      from "example@example.com"
      recipients "developement_staff@example.com"
    end

    mysqldump do
      options "-ceKq --single-transaction --create-options"

      user "root"
      password "............"
      socket "/var/run/mysqld/mysqld.sock"

      database :blog
      database :servershape
      database :astrails_com
      database :secret_project_com

    end

    svndump do
      repo :my_repo do
        repo_path "/home/svn/my_repo"
      end
    end

    pgdump do
      options "-i -x -O"   # -i => ignore version, -x => do not dump privileges (grant/revoke), -O => skip restoration of object ownership in plain text format

      user "username"
      password "............"  # shouldn't be used, instead setup ident.  Current functionality exports a password env to the shell which pg_dump uses - untested!

      database :blog
      database :stateofflux_com
    end

    tar do
      archive "git-repositories", :files => "/home/git/repositories"
      archive "dot-configs",      :files => "/home/*/.[^.]*"
      archive "etc",              :files => "/etc", :exclude => "/etc/puppet/other"

      archive "blog-astrails-com" do
        files "/var/www/blog.astrails.com/"
        exclude ["/var/www/blog.astrails.com/log", "/var/www/blog.astrails.com/tmp"]
      end

      archive "astrails-com" do
        files "/var/www/astrails.com/"
        exclude ["/var/www/astrails.com/log", "/var/www/astrails.com/tmp"]
      end
    end
  end
</pre>

Reporting problems
------------------

http://github.com/astrails/safe/issues

Copyright
---------

Copyright (c) 2009 Astrails Ltd. See LICENSE for details.
