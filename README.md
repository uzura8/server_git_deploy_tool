# subversion deploy tool

This script is use for deploy files by subviersion.

-----------
How to use
-----------

###　1. set config file ###
* Copy config file from sample and edit it for your enviroment

~~~
$ cp setup.conf.sample setup.conf
$ vi setup.conf
$ chmod 600 setup.conf
$ chmod 700 execute_deploy.sh
~~~


### 2. execute script or set on cron ###

* execute
~~~
# sh execute_deploy.sh
~~~

* cron setting
~~~
#*/5 * * * * username /path_to_set_dir/execute_deploy.sh
~~~


