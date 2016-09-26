## PHP quality assurance and metrics reports



### USAGE: 

`php-qa.sh {arguments and parameters}`
   


### DESCRIPTION:

This script generates quality assurance and metrics reports for your PHP project.


It calls several code analysis tools (if available), stores their output in a given directory and wraps it with an index page.


analysing tools

*   phpunit : https://github.com/sebastianbergmann/phpunit
*   php_CodeSniffer : https://github.com/squizlabs/PHP_CodeSniffer
*   phpmetrics : https://github.com/phpmetrics/PhpMetrics
*   pdepend : https://github.com/pdepend/pdepend
*   phpmd : https://github.com/phpmd/phpmd
*   phploc : https://github.com/sebastianbergmann/phploc
*   phpcpd : https://github.com/sebastianbergmann/phpcpd



### INSTALL

download the script and set it to be executable:


	$~/>  wget https://raw.githubusercontent.com/bb-drummer/php-qa/master/php-qa.sh

	$~/>  chmod -x php-qa.sh

	$~/>  sudo mv php-qa.sh /usr/local/bin/php-qa


to install dependend scripts/tools:


    $~/>  sudo su   (or any user having write priveliges to your bin-path)

    $~/>  php-qa -setup -v


if not exists, create your directory to store the report files, ex:


	$~/>  cd myproject/

	$myproject/>  mkdir -p ./public/.reports



### OPTIONS:

on command prompt type `php-qa --help` to see the list of options


*	`-src sourcepath`    source path to analyse (default './src/')
*	`--source-path sourcepath`
*	`--sourcepath sourcepath`


*	`-tests testspath`    path to (phpunit) test configuration (default './tests/')
*	`--tests-path testspath`
*	`--testspath testspath`


*	`-target targetpath`    target path to store reports in (default './public/.reports/')
*	`--target-path targetpath`
*	`--targetpath targetpath`


*	`-setup`    if set, download and install tools (you need sufficient writing privileges there)
*	`--install-dependencies`
*	`-bin binpath`    path to executable (default '/usr/local/bin/')
*	`--bin-path binpath`
*	`--binpath binpath`


*	`-l logfile`    target path to installer logfile
*	`--log-file logfile`
*	`--logfile logfile`
*	`-T tmppath`    installer path for temporary file storage
*	`--tmp-path tmppath`
*	`--tmppath tmppath`


*	`-n`    be non-interactive
*	`--non-interactive`
*	`--noninteractive`


*	`--skip-log`    do not write to logfile
*	`--disable-log`
*	`-h`    show help message
*	`--help`
*	`-v`    verbose output
*	`--verbose`




### DISCLAIMER:

THIS SCRIPT COMES WITH ABSOLUTELY NO WARRANTY !!! USE AT YOUR OWN RISK !!!




### CHANGELOG:

-	2016-09-24     : (bba) initial release 




