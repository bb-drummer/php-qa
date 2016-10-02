#!/bin/bash

##
## "php-qa.sh"
##
##  PHP quality assurance and metrics reports
##
##  This script generates quality assurance and metrics reports for your 
##  PHP project.
##
##  It calls several code analysis tools (if available), stores their 
##  output in a given directory and wraps it with an index page
##
## usage/info: ./php-qa.sh -h
##
## (c) Björn Bartels, coding@bjoernbartels.earth
## https://github.com/bb-drummer/php-qa
##


##
## global vars
##

## project info
##
TITLE="PHP quality assurance and metrics reports"
HOMEPAGE="https://github.com/bb-drummer/php-qa"
COPYRIGHT="(c) 2016 Björn Bartels, coding@bjoernbartels.earth"
LICENCE="Apache 2.0"
VERSION="1.0.0"


## init vars, parameter defaults
##
SOURCEPATH="./src/"
TESTSPATH="./tests/"
TARGETPATH="./public/.reports/"
BINPATH="~" # set so user's home since installing dependencies via composer

INSTALLDEPENDENCIES=0

TMPPATH="/tmp/"
LOGTIME=`date +%Y%m%d%H%M%S`
LOGFILE=$TMPPATH"/php-qa-${LOGTIME}.log"

## running steps config
##
STEP_PHPUNIT=1
STEP_PHPCODESNIFFER=1
STEP_PHPCODESNIFFERBEAUTIFIER=1
STEP_PHPMETRICS=1
STEP_PHPPDEPEND=1
STEP_PHPMD=1
STEP_PHPCPD=1
STEP_PHPLOC=1
STEP_PHPDOC=1

## generic config
##
SKIP_LOG=0
VERBOSE=0
NONINTERACTIVE=0
CDIR=`pwd`


cd ${CDIR};

##
## some info texts
##

DESCRIPTION="
    PHP quality assurance and metrics reports

    This script generates quality assurance and metrics reports for your 
    PHP project.

    It calls several code analysis tools (if available), stores their 
    output in a given directory and wraps it with an index page

    analysing tools

    *   phpunit : https://github.com/sebastianbergmann/phpunit
    *   php_CodeSniffer : https://github.com/squizlabs/PHP_CodeSniffer
    *   phpmetrics : https://github.com/phpmetrics/PhpMetrics
    *   pdepend : https://github.com/pdepend/pdepend
    *   phpmd : https://github.com/phpmd/phpmd
    *   phploc : https://github.com/sebastianbergmann/phploc
    *   phpcpd : https://github.com/sebastianbergmann/phpcpd
    *   phpDocumentor2 : https://github.com/phpDocumentor/phpDocumentor2

";

AVAILABLE_OPTIONS="
    -src sourcepath              path to source files (default ${SOURCEPATH})
    --source-path sourcepath
    --sourcepath sourcepath

    -tests testspath             path to (phpunit) test config (default ${TESTSPATH})
    --tests-path testspath
    --testspath testspath

    -target targetpath           target path script (default ${TARGETPATH})
    --target-path targetpath
    --targetpath targetpath

    -l logfile                   target path to script logfile (default ${LOGFILE})
    --log-file logfile
    --logfile logfile

    -setup                       try to install dependency script/tool if missing on current system 
    --setup
    --install-dependencies

    -bin                         with '-setup', path to install dependency script/tool executables
    --binpath 
    --bin-path

    -tmp tmppath                 path for temporary file storage (default ${TMPPATH})
    --tmp-path tmppath
    --tmppath tmppath

    -n                           be non-interactive
    --non-interactive
    --noninteractive

    --skip-log                   do not write to script logfile, alternatives: --disable-log
    -h                           show this message, alternatives: --help
    -v                           verbose output, alternatives: --verbose
";

EXAMPLES="
    
- to run a non-interactive and (nearly) silent report generation with default path settings, simply type:

    my-project/>  php-qa -n


- change the target for the report files:

    my-project/>  php-qa -n -target "/path/to/my/report/files"


- specify a different path to the test-files:

    my-project/>  php-qa -n -tests "./my/test/files"


- specify a different path to the source-files:

    my-project/>  php-qa -n -src "./module/src"


- turn off log-file:

    my-project/>  php-qa -n --skip-log

  or

    my-project/>  php-qa -n --skip-log

";

DISCLAIMER="
    THIS SCRIPT COMES WITH ABSOLUTELY NO WARRANTY !!! USE AT YOUR OWN RISK !!!
";

CHANGELOG="
    2016-09-24     : (bba) initial release 
";




##
## custom methods
##


## my custom script method...
##
my_script_method ()
{

    logMessage ">>> I do something here...";
    echo ">>> I do something here...";
    if [ "$SCRIPT_VERBOSE" == "1" ]; then 
        ## execute_something;
    	echo "execute something...";
    else
        ## execute_something > /dev/null;
    	echo "execute something..." > /dev/null;
    fi

    #setup_dependencies;

}



## dependencies
##

## CMD_... = ( list, of, analysis, commands )
## DEP_... = ( exec command, install command )

## phpunit
## https://phpunit.de/
CMD_PHPUNIT=
DEP_PHPUNIT=
setup_phpunit ()
{
    DEP_PHPUNIT=(
        [0]="phpunit"
        #[1]="wget --no-check-certificate https://phar.phpunit.de/phpunit.phar ; chmod +x phpunit.phar ; mv phpunit.php phpunit"
        #[1]="curl -OL https://phar.phpunit.de/phpunit.phar"
        [1]="composer global require 'phpunit/phpunit=*'" 
    )
}



## php code-sniffer and beautifier
## https://github.com/squizlabs/PHP_CodeSniffer
CMD_PHPCODESNIFFER=
DEP_PHPCODESNIFFER=
setup_phpcodesniffer ()
{
    DEP_PHPCODESNIFFER=(
        [0]="phpcs"
        #[1]="wget --no-check-certificate https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar ; chmod +x phpcs.phar ; mv phpcs.phar phpcs"
        #[1]="curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar"
        [1]="composer global require 'squizlabs/php_codesniffer=*'" 
    )
}



CMD_PHPCODESNIFFER_BEAUTIFIER=
DEP_PHPCODESNIFFER_BEAUTIFIER=
setup_phpcodesnifferbeautifier ()
{
    DEP_PHPCODESNIFFER_BEAUTIFIER=(
        [0]="phpcbf"
        #[1]="wget --no-check-certificate https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar ; chmod +x phpcbf.phar ; mv phpcbf.phar phpcbf"
        #[1]="curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar"
        [1]="composer global require 'squizlabs/php_codesniffer=*'" 
    )
}



## php-metrics
## https://github.com/phpmetrics/PhpMetrics
CMD_PHPMETRICS=
DEP_PHPMETRICS=
setup_phpmetrics ()
{
    DEP_PHPMETRICS=(
        [0]="phpmetrics"
        #[1]="wget --no-check-certificate https://github.com/phpmetrics/PhpMetrics/raw/master/build/phpmetrics.phar ; chmod +x phpmetrics.phar ; mv phpmetrics.phar phpmetrics"
        #[1]="curl -OL https://github.com/phpmetrics/PhpMetrics/raw/master/build/phpmetrics.phar"
        [1]="composer global require 'phpmetrics/phpmetrics=*'" 
    )
}



## pdepend
## https://pdepend.org
CMD_PDEPEND=
DEP_PDEPEND=
setup_pdepend ()
{
    DEP_PDEPEND=(
        [0]="pdepend"
        #[1]="wget --no-check-certificate http://static.pdepend.org/php/latest/pdepend.phar ; chmod +x pdepend.phar ; mv pdepend.phar pdepend"
        #[1]="curl -OL http://static.pdepend.org/php/latest/pdepend.phar"
        [1]="composer global require 'pdepend/pdepend=*'" 
    )
}



## php mess detector
## https://phpmd.org
CMD_PHPMD=
DEP_PHPMD=
setup_phpmd ()
{
    DEP_PHPMD=(
        [0]="phpmd"
        #[1]="wget --no-check-certificate -c http://static.phpmd.org/php/latest/phpmd.phar ; chmod +x phpmd.phar ; mv phpmd.phar phpmd"
        #[1]="curl -OL http://static.phpmd.org/php/latest/phpmd.phar"
        [1]="composer global require 'phpmd/phpmd=*'" 
    )
}



## php copy&paste detector
## https://github.com/sebastianbergmann/phpcpd
CMD_PHPCPD=
DEP_PHPCPD=
setup_phpcpd ()
{
    DEP_PHPCPD=(
        [0]="phpcpd"
        #[1]="wget --no-check-certificate https://phar.phpunit.de/phpcpd.phar ; chmod +x phpcpd.phar ; mv phpcpd.phar phpcpd"
        #[1]="curl -OL https://phar.phpunit.de/phpcpd.phar"
        [1]="composer global require 'sebastian/phpcpd=*'" 
    )
}



## phploc
## https://github.com/sebastianbergmann/phploc
CMD_PHPLOC=
DEP_PHPLOC=
setup_phploc ()
{
    DEP_PHPLOC=(
        [0]="phploc"
        #[1]="wget --no-check-certificate https://phar.phpunit.de/phploc.phar ; chmod +x phploc.phar ; mv phploc.phar phploc;"
        #[1]="curl -OL https://phar.phpunit.de/phploc.phar"
        [1]="composer global require 'phploc/phploc=*'" 
    )
}



## phpDocumentor2
## https://www.phpdoc.org/
CMD_PHPDOC=
DEP_PHPDOC=
setup_phpdoc ()
{
    DEP_PHPDOC=(
        [0]="phpdoc"
        #[1]="wget --no-check-certificate http://phpdoc.org/phpDocumentor.phar ; chmod +x phploc.phar ; mv phploc.phar phploc;"
        #[1]="curl -OL http://phpdoc.org/phpDocumentor.phar"
        [1]="composer global require 'phpdocumentor/phpdocumentor=~2.8.0' ; composer global require 'phpdocumentor/phpdocumentor=~2.8.0' ;" 
    )
}



## setup up dependencies
##
setupDependencies ()
{

    # if [ "${SCRIPT_STEP_PHPUNIT}" != "0" ]; then

        setup_phpunit;
        EXECCOMMAND=${DEP_PHPUNIT[0]};
        INSTALLCOMMAND=${DEP_PHPUNIT[1]};

        checkDependency "${EXECCOMMAND}" "${INSTALLCOMMAND}";

    # fi

    # if [ "${SCRIPT_STEP_PHPCODESNIFFER}" != "0" ]; then

        setup_phpcodesniffer;
        EXECCOMMAND=${DEP_PHPCODESNIFFER[0]};
        INSTALLCOMMAND=${DEP_PHPCODESNIFFER[1]};
        checkDependency "${EXECCOMMAND}" "${INSTALLCOMMAND}";

    # fi

    # if [ "${SCRIPT_STEP_PHPCODESNIFFERBEAUTIFIER}" != "0" ]; then

        setup_phpcodesnifferbeautifier;
        EXECCOMMAND=${DEP_PHPCODESNIFFER_BEAUTIFIER[0]};
        INSTALLCOMMAND=${DEP_PHPCODESNIFFER_BEAUTIFIER[1]};
        checkDependency "${EXECCOMMAND}" "${INSTALLCOMMAND}";

    # fi

    # if [ "${SCRIPT_STEP_PHPMETRICS}" != "0" ]; then

        setup_phpmetrics;
        EXECCOMMAND=${DEP_PHPMETRICS[0]};
        INSTALLCOMMAND=${DEP_PHPMETRICS[1]};
        checkDependency "${EXECCOMMAND}" "${INSTALLCOMMAND}";

    # fi

    # if [ "${SCRIPT_STEP_PDEPEND}" != "0" ]; then

        setup_pdepend;
        EXECCOMMAND=${DEP_PDEPEND[0]};
        INSTALLCOMMAND=${DEP_PDEPEND[1]};
        checkDependency "${EXECCOMMAND}" "${INSTALLCOMMAND}";

    # fi

    # if [ "${SCRIPT_STEP_PHPMD}" != "0" ]; then

        setup_phpmd;
        EXECCOMMAND=${DEP_PHPMD[0]};
        INSTALLCOMMAND=${DEP_PHPMD[1]};
        checkDependency "${EXECCOMMAND}" "${INSTALLCOMMAND}";

    # fi

    # if [ "${SCRIPT_STEP_PHPCPD}" != "0" ]; then

        setup_phpcpd;
        EXECCOMMAND=${DEP_PHPCPD[0]};
        INSTALLCOMMAND=${DEP_PHPCPD[1]};
        checkDependency "${EXECCOMMAND}" "${INSTALLCOMMAND}";

    # fi

    # if [ "${SCRIPT_STEP_PHPLOC}" != "0" ]; then

        setup_phploc;
        EXECCOMMAND=${DEP_PHPLOC[0]};
        INSTALLCOMMAND=${DEP_PHPLOC[1]};
        checkDependency "${EXECCOMMAND}" "${INSTALLCOMMAND}";

    # fi

    # if [ "${SCRIPT_STEP_PHPLOC}" != "0" ]; then

        setup_phpdoc;
        EXECCOMMAND=${DEP_PHPDOC[0]};
        INSTALLCOMMAND=${DEP_PHPDOC[1]};
        checkDependency "${EXECCOMMAND}" "${INSTALLCOMMAND}";

    # fi

}

## check for and install dependency
## @param exec-command
## @param install-command
##
PATHTOCMD=
checkDependency ()
{

    debugMessage ">>> check dependency '${EXECCOMMAND}'...";
    
    EXECCOMMAND="$1";
    INSTALLCOMMAND="$2";

    CMD_WHICH="which ${EXECCOMMAND}";
    PATHTOCMD=`${CMD_WHICH}`;

    if [ "$SCRIPT_VERBOSE" == "1" ]; then
            
            echo "cmd: ${EXECCOMMAND}";
            echo "which: ${PATHTOCMD}";
            echo "path: `${CMD_WHICH}`";

            if [ -z "$PATHTOCMD" ]; then 
                echo "dep: ${SCRIPT_INSTALLDEPENDENCIES}";

                if [ $SCRIPT_INSTALLDEPENDENCIES == 1 ]; then

                    debugMessage ">>> install dependency \"${EXECCOMMAND}\"...";
                    echo "inst: ${INSTALLCOMMAND}";

                    cd ${SCRIPT_BINPATH}

                    `${INSTALLCOMMAND}`;

                    chmod +x ${EXECCOMMAND}.phar ; 
                    mv ${EXECCOMMAND}.phar ${EXECCOMMAND}

                    cd ${CDIR}
                fi
            fi
        
    else ## quiet/none output...
            
            echo "path: ${PATHTOCMD}";

            if [ -z "$PATHTOCMD" ]; then 

                if [ $SCRIPT_INSTALLDEPENDENCIES == 1 ]; then

                    debugMessage ">>> install dependency \"${EXECCOMMAND}\"...";
                    echo "inst: ${INSTALLCOMMAND}";

                    cd ${SCRIPT_BINPATH}

                    # `${INSTALLCOMMAND}`;

                    chmod +x ${EXECCOMMAND}.phar ; 
                    mv ${EXECCOMMAND}.phar ${EXECCOMMAND}

                    cd ${CDIR}
                fi
            fi

    fi

}



## analysis steps...
##

## execute phpunit
##
perform_phpunit ()
{

    if [ "${SCRIPT_STEP_PHPUNIT}" != "0" ]; then

        setup_phpunit;
        EXECCOMMAND=${DEP_PHPUNIT[0]};
        
        debugMessage ">>> executing... '${EXECCOMMAND}' ";
        mkdir -p ${SCRIPT_TARGETPATH}phpunit
        phpunit ${SCRIPT_ADD_VERBOSE}--debug --configuration ${SCRIPT_TESTSPATH} --coverage-html ${SCRIPT_TARGETPATH}/phpunit --coverage-text=${SCRIPT_TARGETPATH}/phpunit/qa.phpunit.txt --coverage-clover=${SCRIPT_TARGETPATH}/phpunit/qa.phpunit.clover.xml --testdox-html ${SCRIPT_TARGETPATH}/phpunit/qa.phpunit.testdox.html

    fi
}

## execute codesniffer
## @param coding standart, run `phpcs -i` to show list
perform_phpcodesniffer ()
{
    CODINGSTD="Zend"
    if [ "$1" != "" ]; then
        CODINGSTD="$1";
    fi

    if [ "${SCRIPT_STEP_PHPCODESNIFFER}" != "0" ]; then

        setup_phpcodesniffer;
        EXECCOMMAND=${DEP_PHPCODESNIFFER[0]};

        debugMessage ">>> executing... '${EXECCOMMAND}' ";
        mkdir -p ${SCRIPT_TARGETPATH}codesniffer
        debugMessage ">>> executing... '${EXECCOMMAND}' - report ";
        phpcs ${SCRIPT_ADD_VERBOSE}-s --standard=${CODINGSTD} --report-file=${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.report.txt --error-severity=1 --warning-severity=8 ${SCRIPT_SOURCEPATH} ${SCRIPT_TESTSPATH} ; # > ${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.report.txt
        debugMessage ">>> executing... '${EXECCOMMAND}' - info ";
        phpcs ${SCRIPT_ADD_VERBOSE}-s --standard=${CODINGSTD} --report-info=${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.info.txt --error-severity=1 --warning-severity=8 ${SCRIPT_SOURCEPATH} ${SCRIPT_TESTSPATH} ; # > ${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.info.txt
        debugMessage ">>> executing... '${EXECCOMMAND}' - summary ";
        phpcs ${SCRIPT_ADD_VERBOSE}-s --standard=${CODINGSTD} --report-summary=${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.summary.txt --error-severity=1 --warning-severity=8 ${SCRIPT_SOURCEPATH} ${SCRIPT_TESTSPATH} ; # > ${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.summary.txt
        debugMessage ">>> executing... '${EXECCOMMAND}' - source ";
        phpcs ${SCRIPT_ADD_VERBOSE}-s --standard=${CODINGSTD} --report-source=${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.source.txt --error-severity=1 --warning-severity=8 ${SCRIPT_SOURCEPATH} ${SCRIPT_TESTSPATH} ; # > ${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.source.txt
        debugMessage ">>> executing... '${EXECCOMMAND}' - full ";
        phpcs ${SCRIPT_ADD_VERBOSE}-s --standard=${CODINGSTD} --report-full=${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.full.txt --error-severity=1 --warning-severity=8 ${SCRIPT_SOURCEPATH} ${SCRIPT_TESTSPATH} ; # > ${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.full.txt
        debugMessage ">>> executing... '${EXECCOMMAND}' - PEAR standard ";
        phpcs ${SCRIPT_ADD_VERBOSE}-s --standard=${CODINGSTD} --generator=HTML ${SCRIPT_SOURCEPATH} ${SCRIPT_TESTSPATH} > ${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.standards.html
        #debugMessage ">>> executing... '${EXECCOMMAND}' - xml ";
        #phpcs -s --report-xml=${SCRIPT_TARGETPATH}codesniffer/qa.codesniffer.report.xml --error-severity=1 --warning-severity=8 ${SCRIPT_SOURCEPATH}


    fi

}

## execute codesniffer beautifier
##
perform_phpcodesnifferbeautifier ()
{
    if [ "${SCRIPT_STEP_PHPCODESNIFFERBEAUTIFIER}" != "0" ]; then

        setup_phpcodesnifferbeautifier;
        EXECCOMMAND=${DEP_PHPCODESNIFFER_BEAUTIFIER[0]};

        debugMessage ">>> executing... '${EXECCOMMAND}' ";
        phpcbf ${SCRIPT_ADD_VERBOSE}${SCRIPT_SOURCEPATH} --standard=${CODINGSTD} -n --tab-width=4
        phpcbf ${SCRIPT_ADD_VERBOSE}${SCRIPT_TESTSPATH} --standard=${CODINGSTD} -n --tab-width=4
        # --report=diff -v > ${SCRIPT_TARGETPATH}/codesniffer/qa.codesniffer.code-beautifier-fixer.diff

    fi

}

## execute php-metrics
##
perform_phpmetrics ()
{
    if [ "${SCRIPT_STEP_PHPMETRICS}" != "0" ]; then

        setup_phpmetrics;
        EXECCOMMAND=${DEP_PHPMETRICS[0]};

        debugMessage ">>> executing... '${EXECCOMMAND}' ";
        phpmetrics ${SCRIPT_ADD_VERBOSE}--report-html=${SCRIPT_TARGETPATH}/qa.phpmetrics.html --report-xml=${SCRIPT_TARGETPATH}/qa.phpmetrics.xml ${SCRIPT_SOURCEPATH}

    fi

}

## execute pdepend
##
perform_pdepend ()
{
    if [ "${SCRIPT_STEP_PDEPEND}" != "0" ]; then

        setup_pdepend;
        EXECCOMMAND=${DEP_PDEPEND[0]};

        debugMessage ">>> executing... '${EXECCOMMAND}' ";
        mkdir -p ${SCRIPT_TARGETPATH}pdepend
        debugMessage ">>> executing... '${EXECCOMMAND}' - dependencies";
        pdepend ${SCRIPT_ADD_QUIET}--dependency-xml=${SCRIPT_TARGETPATH}/pdepend/dependencies.xml ${SCRIPT_SOURCEPATH}
        debugMessage ">>> executing... '${EXECCOMMAND}' - summary xml";
        pdepend ${SCRIPT_ADD_QUIET}--summary-xml=${SCRIPT_TARGETPATH}/pdepend/summary.xml ${SCRIPT_SOURCEPATH}
        debugMessage ">>> executing... '${EXECCOMMAND}' - jdepend xml";
        pdepend ${SCRIPT_ADD_QUIET}--jdepend-xml=${SCRIPT_TARGETPATH}/pdepend/jdepend.xml ${SCRIPT_SOURCEPATH}
        debugMessage ">>> executing... '${EXECCOMMAND}' - jdepend chart";
        pdepend ${SCRIPT_ADD_QUIET}--jdepend-chart=${SCRIPT_TARGETPATH}/pdepend/jdepend.svg ${SCRIPT_SOURCEPATH}
        debugMessage ">>> executing... '${EXECCOMMAND}' - overview pyramid";
        pdepend ${SCRIPT_ADD_QUIET}--overview-pyramid=${SCRIPT_TARGETPATH}/pdepend/pyramid.svg ${SCRIPT_SOURCEPATH}

    fi

}

## execute phpmd
##
perform_phpmd ()
{
    if [ "${SCRIPT_STEP_PHPMD}" != "0" ]; then

        setup_phpmd;
        EXECCOMMAND=${DEP_PHPMD[0]};

        debugMessage ">>> executing... '${EXECCOMMAND}' ";
        mkdir -p ${SCRIPT_TARGETPATH}phpmd
        debugMessage ">>> executing... '${EXECCOMMAND}' - cleancode ";
        phpmd ${SCRIPT_SOURCEPATH} html cleancode > ${SCRIPT_TARGETPATH}/phpmd/qa.phpmd.cleancode.html
        debugMessage ">>> executing... '${EXECCOMMAND}' - codesize ";
        phpmd ${SCRIPT_SOURCEPATH} html codesize > ${SCRIPT_TARGETPATH}/phpmd/qa.phpmd.codesize.html
        debugMessage ">>> executing... '${EXECCOMMAND}' - controverial ";
        phpmd ${SCRIPT_SOURCEPATH} html controversial > ${SCRIPT_TARGETPATH}/phpmd/qa.phpmd.controversial.html
        debugMessage ">>> executing... '${EXECCOMMAND}' - design ";
        phpmd ${SCRIPT_SOURCEPATH} html design > ${SCRIPT_TARGETPATH}/phpmd/qa.phpmd.design.html
        debugMessage ">>> executing... '${EXECCOMMAND}' - naming ";
        phpmd ${SCRIPT_SOURCEPATH} html naming > ${SCRIPT_TARGETPATH}/phpmd/qa.phpmd.naming.html
        debugMessage ">>> executing... '${EXECCOMMAND}' - unusedcode ";
        phpmd ${SCRIPT_SOURCEPATH} html unusedcode > ${SCRIPT_TARGETPATH}/phpmd/qa.phpmd.unusedcode.html
        debugMessage ">>> executing... '${EXECCOMMAND}' - full ";
        phpmd ${SCRIPT_SOURCEPATH} html "cleancode,codesize,controversial,design,naming,unusedcode" > ${SCRIPT_TARGETPATH}/phpmd/qa.phpmd.html

    fi

}

## execute phpcpd
##
perform_phpcpd ()
{
    if [ "${SCRIPT_STEP_PHPCPD}" != "0" ]; then

        setup_phpcpd;
        EXECCOMMAND=${DEP_PHPCPD[0]};

        debugMessage ">>> executing... '${EXECCOMMAND}' ";
        phpcpd ${SCRIPT_ADD_VERBOSE}${SCRIPT_SOURCEPATH} > ${SCRIPT_TARGETPATH}/qa.copy-paste-detection.txt

    fi

}

## execute phploc
##
perform_phploc ()
{
    if [ "${SCRIPT_STEP_PHPLOC}" != "0" ]; then

        setup_phploc;
        EXECCOMMAND=${DEP_PHPLOC[0]};

        debugMessage ">>> executing... '${EXECCOMMAND}' ";
        phploc ${SCRIPT_ADD_VERBOSE} -- ${SCRIPT_SOURCEPATH} ${SCRIPT_TESTSPATH} > ${SCRIPT_TARGETPATH}/qa.project-size.txt

    fi

}

## execute phpDocumentor
##
perform_phpdoc ()
{
    if [ "${SCRIPT_STEP_PHPDOC}" != "0" ]; then

        setup_phpdoc;
        EXECCOMMAND=${DEP_PHPDOC[0]};
        mkdir -p ${SCRIPT_TARGETPATH}phpdoc
        mkdir -p ${SCRIPT_TARGETPATH}phpdoc.md

        debugMessage ">>> executing... '${EXECCOMMAND}' ";
        phpdoc run ${SCRIPT_ADD_QUIET}${SCRIPT_ADD_VERBOSE} --template="clean" --template="checkstyle" --directory ${SCRIPT_SOURCEPATH} --target ${SCRIPT_TARGETPATH}phpdoc
        phpdoc run ${SCRIPT_ADD_QUIET}${SCRIPT_ADD_VERBOSE} --template="markdown-public" --directory ${SCRIPT_SOURCEPATH} --target ${SCRIPT_TARGETPATH}phpdoc.md
        cp ${SCRIPT_TARGETPATH}phpdoc.md/README.md  ${SCRIPT_TARGETPATH}phpdoc/API.md
        rm -rf ${SCRIPT_TARGETPATH}phpdoc.md

    fi

}

## execute phpunit
##
performAnalysises ()
{

    perform_phpcodesnifferbeautifier;

    perform_phpcodesniffer;

    perform_phpunit;

    perform_phpmetrics;

    perform_pdepend;

    perform_phpmd;

    perform_phpcpd;

    perform_phploc;

    perform_phpdoc;

}

## initialize storage directories
##
initReportDirs ()
{

    debugMessage ">>> create/clean-up reports target...";

    # create target if not exists
    mkdir -p ${SCRIPT_TARGETPATH} 
    # create tools bin directory if not exists
    mkdir -p ${SCRIPT_TARGETPATH}/bin
    mkdir -p ${SCRIPT_TARGETPATH}/phpunit
    mkdir -p ${SCRIPT_TARGETPATH}/pdepend
    mkdir -p ${SCRIPT_TARGETPATH}/phpmd
    mkdir -p ${SCRIPT_TARGETPATH}/phpdoc
    mkdir -p ${SCRIPT_TARGETPATH}/codesniffer

    # clear everything inside
    rm -rf ${SCRIPT_TARGETPATH}/*

    # ..or just some of it...
    #rm -rf ${SCRIPT_TARGETPATH}/*.diff
    #rm -rf ${SCRIPT_TARGETPATH}/*.txt
    #rm -rf ${SCRIPT_TARGETPATH}/*.html
    #rm -rf ${SCRIPT_TARGETPATH}/phpunit/*
    #rm -rf ${SCRIPT_TARGETPATH}/pdepend/*
    #rm -rf ${SCRIPT_TARGETPATH}/phpmd/*
    #rm -rf ${SCRIPT_TARGETPATH}/codesniffer/*

    # leave bin dir?
    #rm -rf ${SCRIPT_TARGETPATH}/bin/*

}

## create wrapping index page
##
debugMessage ()
{
    logMessage "$1";
    if [ "$SCRIPT_VERBOSE" == "1" ]; then 
        #echo "";
        #echo "================================================================================================";
        echo "$1";
        #echo ""; 
    fi

}


## create wrapping index page
##
createIndexPage ()
{
    # create a "nice" html page to wrap the reports in

    # see full source @ https://github.com/bb-drummer/php-qa
    HTMLPAGE='<!DOCTYPE html><html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <meta http-equiv="X-UA-Compatible" content="IE=edge"> <meta name="viewport" content="width=device-width, initial-scale=1"> <meta name="description" content="Test and QA reports wrapping page"> <meta name="author" content="Björn Bartels"> <link rel="icon" href="http://getbootstrap.com/favicon.ico"> <title>Test and QA reports</title> <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet"><!--[if lt IE 9]> <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script> <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script><![endif]--> <style type="text/css">/* html, body{display: block;position: relative;width: 100%;height: 100%;overflow: hidden;}*/html, body{display: block; position: absolute; width: auto; height: auto; overflow: auto; top: 0; left: 0; right: 0; bottom: 0;}.framePanel,nav,iframe[name=qaDisplay]{position: absolute;display: block;}.framePanel{left: 15px;right: 15px;top: 70px;bottom: 15px;}iframe[name=qaDisplay]{border-radius: 5px;border: 1px solid #e7e7e7;left: 0px !important;right: 0px !important;top: 0px !important;bottom: 0px !important; height: 100% !important; width: 100% !important;}</style> </head> <body class="_container container-fluid"><div class="nav-container"><nav class="navbar navbar-default" role="navigation"><div class="navbar-header"> <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#main-navbar-collapse"> <span class="sr-only">Toggle navigation</span><span class="icon-bar"></span><span class="icon-bar"></span><span class="icon-bar"></span></button> <a class="navbar-brand" href="./">Test/QA reports</a></div><div class="collapse navbar-collapse" id="main-navbar-collapse"><ul class="nav navbar-nav"><li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown" target="qaDisplay">Metrics<strong class="caret"></strong></a><ul class="dropdown-menu"><li><a href="qa.phpmetrics.html" target="qaDisplay">analysis</a></li><li><a href="qa.phpmetrics.xml" target="qaDisplay">xml export</a></li></ul></li><li class="dropdown"><a href="phpunit/" class="dropdown-toggle" data-toggle="dropdown" target="qaDisplay">Tests<strong class="caret"></strong></a><ul class="dropdown-menu"><li><a href="phpunit/dashboard.html" target="qaDisplay">code analysis</a></li><li><a href="phpunit/index.html" target="qaDisplay">code coverage</a></li><li class="divider"></li><li><a href="phpunit/qa.phpunit.testdox.html" target="qaDisplay">test dox</a></li><li class="divider"></li><li><a href="phpunit/qa.phpunit.clover.xml" target="qaDisplay">clover file</a></li><li><a href="phpunit/qa.phpunit.txt" target="qaDisplay">txt summary</a></li></ul></li><li class="dropdown"><a href="pdepend/" class="dropdown-toggle" data-toggle="dropdown" target="qaDisplay">Dependencies<strong class="caret"></strong></a><ul class="dropdown-menu"><li><a href="pdepend/jdepend.svg" target="qaDisplay">jdepend graph</a></li><li><a href="pdepend/pyramid.svg" target="qaDisplay">pyramid graph</a></li><li class="divider"></li><li><a href="pdepend/dependencies.xml" target="qaDisplay">dependencies (xml)</a></li><li><a href="pdepend/jdepend.xml" target="qaDisplay">jdepend (xml)</a></li><li><a href="pdepend/summary.xml" target="qaDisplay">xml summary</a></li></ul></li><li class="dropdown"><a href="phpmd/" class="dropdown-toggle" data-toggle="dropdown">Mess Detector<strong class="caret"></strong></a><ul class="dropdown-menu"><li><a href="phpmd/qa.phpmd.cleancode.html" target="qaDisplay">cleancode</a></li><li><a href="phpmd/qa.phpmd.codesize.html" target="qaDisplay">codesize</a></li><li><a href="phpmd/qa.phpmd.controversial.html" target="qaDisplay">controversial</a></li><li><a href="phpmd/qa.phpmd.design.html" target="qaDisplay">design</a></li><li><a href="phpmd/qa.phpmd.naming.html" target="qaDisplay">naming</a></li><li><a href="phpmd/qa.phpmd.unusedcode.html" target="qaDisplay">unused code</a></li><li class="divider"></li><li><a href="phpmd/qa.phpmd.html" target="qaDisplay">full</a></li></ul></li><li class="dropdown"><a href="codesniffer/" class="dropdown-toggle" data-toggle="dropdown">Style<strong class="caret"></strong></a><ul class="dropdown-menu"><li><a href="codesniffer/qa.codesniffer.info.txt" target="qaDisplay">info</a></li><li><a href="codesniffer/qa.codesniffer.summary.txt" target="qaDisplay">summary</a></li><li class="divider"></li><li><a href="codesniffer/qa.codesniffer.report.txt" target="qaDisplay">report</a></li><li><a href="codesniffer/qa.codesniffer.source.txt" target="qaDisplay">source</a></li><li class="divider"></li><li><a href="codesniffer/qa.codesniffer.code-beautifier-fixer.git-head.diff" target="qaDisplay">diff/patch</a></li><li class="divider"></li><li><a href="codesniffer/qa.codesniffer.standards.html" target="qaDisplay">Coding Standards</a></li></ul></li><li><a href="qa.copy-paste-detection.txt" target="qaDisplay">Copy&amp;Paste</a></li><li><a href="qa.project-size.txt" target="qaDisplay">LOC</a></li><li class="dropdown"><a href="phpdoc/" class="dropdown-toggle" data-toggle="dropdown">Docs<strong class="caret"></strong></a><ul class="dropdown-menu"><li><a href="phpdoc/" target="qaDisplay">API (HTML)</a></li><li><a href="phpdoc/API.md" target="qaDisplay">API (Markdown)</a></li></ul></li></ul></div></nav></div><div class="framePanel"><iframe name="qaDisplay" src="qa.project-size.txt"></iframe></div><script type="text/javascript" src="https://code.jquery.com/jquery-3.1.1.min.js"></script> <script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script></body></html>';

    # output decoded html to file
    echo "$HTMLPAGE" > ${SCRIPT_TARGETPATH}/index.html

}



## base64 decoding
##
base64_decode () {
  echo "$1" | base64 --decode ;
}


## ###
##
## >>> INTERNAL SCRIPT METHODS <<<
##
## ###


## show script config info
##
scriptinfo()
{
cat << EOF

CONFIGURATION:

    SOURCEPATH     = ${SOURCEPATH}
    TESTSPATH      = ${TESTSPATH}
    TARGETPATH     = ${TARGETPATH}

    VERSION        = ${VERSION} 
    TMPPATH        = ${TMPPATH}
    LOGFILE        = ${LOGFILE}

    CWD            = ${CDIR}

OS:
    OS             = ${OS}
    ID             = ${ID}
    CODENAME       = ${CODENAME}
    RELEASE        = ${RELEASE}

EOF
}


## show script vendor information
##
scriptvendor()
{
cat << EOF

DISCLAIMER:
${DISCLAIMER}

         
CHANGELOG:
${CHANGELOG}


SCRIPT INFO:
    homepage/        ${HOMEPAGE}
    support/bugs    
    copyright        ${COPYRIGHT}
    licence          ${LICENCE}

EOF
}


## show script usage help
##
scriptusage()
{
cat << EOF
${TITLE}, v${VERSION}

USAGE: 
    $0 {arguments}


DESCRIPTION:
${DESCRIPTION}


OPTIONS:
${AVAILABLE_OPTIONS}


EXAMPLES:
${EXAMPLES}
    

EOF
}


## detect current OS type
##
detectOS () 
{
    TYPE=$(echo "$1" | tr '[A-Z]' '[a-z]')
    OS=$(uname)
    ID="unknown"
    CODENAME="unknown"
    RELEASE="unknown"

    if [ "${OS}" == "Linux" ] ; then
        # detect centos
        grep "centos" /etc/issue -i -q
        if [ $? = '0' ]; then
            ID="centos"
            RELEASE=$(cat /etc/redhat-release | grep -o 'release [0-9]' | cut -d " " -f2)
        # could be debian or ubuntu
        elif [ $(which lsb_release) ]; then
            ID=$(lsb_release -i | cut -f2)
            CODENAME=$(lsb_release -c | cut -f2)
            RELEASE=$(lsb_release -r | cut -f2)
        elif [ -f "/etc/lsb-release" ]; then
            ID=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d "=" -f2)
            CODENAME=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d "=" -f2)
            RELEASE=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f2)
        elif [ -f "/etc/issue" ]; then
            ID=$(head -1 /etc/issue | cut -d " " -f1)
            if [ -f "/etc/debian_version" ]; then
                RELEASE=$(</etc/debian_version)
            else
                RELEASE=$(head -1 /etc/issue | cut -d " " -f2)
            fi
        fi

    elif [ "${OS}" == "Darwin" ]; then
        ID="osx"
        OS="Mac OS-X"
        RELEASE=""
        CODENAME="Darwin"
    fi

    ##ID=$(echo "${ID}" | tr '[A-Z]' '[a-z]')
    ##TYPE=$(echo "${TYPE}" | tr '[A-Z]' '[a-z]')
    ##OS=$(echo "${OS}" | tr '[A-Z]' '[a-z]')
    ##CODENAME=$(echo "${CODENAME}" | tr '[A-Z]' '[a-z]')
    ##RELESE=$(echo "${RELEASE}" | tr '[A-Z]' '[a-z]' '[0-9\.]')

}


## display confirm dialog
##
DIALOG__CONFIRM=0
confirm () {
    DIALOG__CONFIRM=0
    if [ "$1" != "" ] 
        then
            read -p ">>> $1 [(YJ)/n]: " CONFIRMNEXTSTEP
            case "$CONFIRMNEXTSTEP" in
                Yes|yes|Y|y|Ja|ja|J|j|"") ## continue installing...
                    logMessage ">>> '$1' confirmed...";
                    DIALOG__CONFIRM=1
                ;;
                *) ## operation canceled...
                    echo "WARNING: operation has been canceled through user interaction..."
                ;;
            esac
    fi
}


## write message to log-file...
##
logMessage () {
    if [ "$SCRIPT_SKIP_LOG" == "0" ] && [ "$1" != "" ]; then 
        echo "$1" >>${SCRIPT_LOGFILE}; 
    fi
}


## >>> START MAIN SHELL SCRIPT <<<
##


## init user parameters...
##
TYPE=
OS=
ID=
CODENAME=
RELEASE=

detectOS

## parse shell script arguments
##
CLI_ERROR=0
CLI_CMDOPTIONS_TEMP=`getopt -o d:p:t:i:l:H:I:s:u:T:envh --long displayname:,display-name:,php-version:,phpversion:,target-path:,targetpath:,path:,php-path:,phppath:,target-ini-path:,targetinipath:,ini-path:,inipath:,php-inipath:,phpinipath:,log-file:,logfile:,php-handler:,php-handler:,plesk-phphandler:,pleskphphandler:,plesk-id:,pleskid:,source-host:,sourcehost:,php-host:,phphost:,source-file:,sourcefile:,source-url:,sourceurl:,archive:,file:,sapi,apxs-path:,tmp-path:,tmppath:,edit-ini:,editini:,non-interactive,noninteractive,verbose,help,info,manual,man,skip-dependencies,disable-dependencies,skip-dependency-check,disable-dependency-check,skip-dependencycheck,disable-dependencycheck,skip-fetch,disable-fetch,skip-fetch-php,disable-fetch-php,skip-fetchphp,disable-fetchphp,skip-build,disable-build,skip-build-php,disable-build-php,skip-buildphp,disable-buildphp,skip-handler,disable-handler,skip-php-handler,disable-php-handler,skip-phphandler,disable-phphandler,apply-suhosin,suhosin,suhosin-host:,suhosin-version:,suhosin-url:,apply-xdebug,xdebug,xdebug-host:,xdebug-version:,xdebug-url:,apply-memcached,memcached,memcached-host:,memcached-version:,memcached-url:,configure: -n 'php2plesk.sh' -- "$@"`
while true; do
    case "${1}" in
    
## --- my script options --------

        ## paths ##

        -src|--source-path|--sourcepath)
        SOURCEPATH=${2}
            shift 2
        ;;

        -tests|--tests-path|--testspath)
        TESTSPATH=${2}
            shift 2
        ;;

        -target|--target-path|--targetpath)
        TARGETPATH=${2}
            shift 2
        ;;

        -bin|--bin-path|--binpath)
        BINPATH=${2}
            shift 2
        ;;

        ## flags ##

        -setup|--setup|--install-dependencies)    
            shift
            INSTALLDEPENDENCIES=1
            ;;


        ## --configure)
        ##     CONFIGURE_MODE=${2}
        ##     case "${CONFIGURE_MODE}" in
        ##         *default*)
        ##             ## no action required now
        ##         ;;
        ##         *none*)
        ##             ## no action required now
        ##         ;;
        ##         *full*)
        ##             ## no action required now
        ##         ;;
        ##         *custom*)
        ##             ## no action required now
        ##         ;;
        ##         *)
        ##             CONFIGURE_MODE=default
        ##         ;;
        ##     esac
        ##     
        ##     shift 2
        ##     ;;



## --- generic script options --------
        -T|--tmp-path|--tmppath)
            TMPPATH=${2}
            shift 2
            ;;

        -l|--log-file|--logfile)
            LOGFILE=${2}
            shift 2
            ;;

        -n|--non-interactive|--noninteractive)    
            shift
            NONINTERACTIVE=1
            ;;
            
        -v|--verbose)    
            shift
            VERBOSE=1
            ;;
            
        -q|--quiet)    
            shift
            VERBOSE=0
            ;;

        --skip-log|--disable-log)    
            shift
            SKIP_LOG=1
            ;;

## --- shell script info/help --------
        -h|--help|--info|--manual|--man)
            shift    
            scriptusage
            scriptvendor
            exit
            ;;

        -i|--info)
            shift    
            scriptinfo
            exit
            ;;

        --version)
            shift    
            echo "v"${VERSION}
            exit
            ;;

        --) 
            shift
            break
            ;;
        *)    
            ## halt on unknown parameters
            #echo "ERROR: invalid command line option/argument : ${1}!"
            #CLI_ERROR=1
            #break
            
            ## ignore unknown parameters
            shift
            break
            ;;

    esac
done
CLI_CMDARGUMENTS=( ${CLI_CMDOPTIONS[@]} )

## halt on command line error...
##
if [ $CLI_ERROR == 1 ]
    then
    	echo "!!! ERROR !!!";
        scriptusage
    	scriptinfo 
        scriptvendor
        exit 1
fi

## check for mandatory script argument values
##
if [[ -z $TARGETPATH ]] || [[ -z $LOGFILE ]]
    then
        echo "!!! ERROR !!!";
        scriptusage
        scriptinfo
        #scriptvendor
        exit 1
fi

## select/perform script operations...
##

    ## setting parameters, sampling paths and vars...
    ##
    clear;

    ## vars, defaults
    ##
    SCRIPT_SOURCEPATH=${SOURCEPATH}
    SCRIPT_TESTSPATH=${TESTSPATH}
    SCRIPT_TARGETPATH=${TARGETPATH}
    SCRIPT_BINPATH=${BINPATH}
    SCRIPT_INSTALLDEPENDENCIES=${INSTALLDEPENDENCIES}

    current_work_dir=`pwd`;
    DIALOG__CONFIRM=0
    
    ## running steps config
    ##
    SCRIPT_STEP_PHPUNIT=${STEP_PHPUNIT}
    SCRIPT_STEP_PHPCODESNIFFER=${STEP_PHPCODESNIFFER}
    SCRIPT_STEP_PHPCODESNIFFERBEAUTIFIER=${STEP_PHPCODESNIFFERBEAUTIFIER}
    SCRIPT_STEP_PHPMETRICS=${STEP_PHPMETRICS}
    SCRIPT_STEP_PHPPDEPEND=${STEP_PHPPDEPEND}
    SCRIPT_STEP_PHPMD=${STEP_PHPMD}
    SCRIPT_STEP_PHPCPD=${STEP_PHPCPD}
    SCRIPT_STEP_PHPLOC=${STEP_PHPLOC}
    SCRIPT_STEP_PHPDOC=${STEP_PHPDOC}

    ## generic config
    ##
    SCRIPT_VERSION=$VERSION
    SCRIPT_LOGFILE=$LOGFILE
    SCRIPT_TMPPATH=${TMPPATH}
    SCRIPT_VERBOSE=${VERBOSE}
    SCRIPT_NONINTERACTIVE=${NONINTERACTIVE}
    SCRIPT_KEEPFILES=${KEEP_FILES}
    SCRIPT_KEEPARCHIVE=${KEEP_ARCHIVE}
    
    SCRIPT_ADD_VERBOSE="";
    SCRIPT_ADD_QUIET="--quiet ";
    if [[ $SCRIPT_VERBOSE == 1 ]]; then
        SCRIPT_ADD_VERBOSE="-v ";
        SCRIPT_ADD_QUIET="";
    fi
    
    ## check parameters, if paths and targets are set properly...
    ##
    SETTINGERROR=0


    ## check for 'bin path'
    #if [[ ! -d $SCRIPT_BINPATH ]] 
    #   then
    #        MSG="ERROR: '$SCRIPT_BINPATH' does not exist or you have no permission to write there, please select another path using option '-bin path'...";
    #        echo $MSG;
    #        logMessage $MSG;
    #        SETTINGERROR=1
    #fi 
    
    ## check for 'source path'
    if [[ ! -d $SCRIPT_SOURCEPATH ]] 
        then
            MSG="ERROR: '$SCRIPT_SOURCEPATH' does not exist or you have no permission to read there, please select another path using option '-src path'...";
            echo $MSG;
            logMessage $MSG;
            SETTINGERROR=1
    fi 
    
    ## check for 'tests path'
    if [[ ! -d $SCRIPT_TESTSPATH ]] 
        then
            MSG="ERROR: '$SCRIPT_TESTSPATH' does not exist or you have no permission to read there, please select another path using option '-tests path'...";
            echo $MSG;
            logMessage $MSG;
            SETTINGERROR=1
    fi 
    
    ## check for 'target path'
    if [[ ! -d $SCRIPT_TARGETPATH ]] 
        then
            MSG="ERROR: '$SCRIPT_TARGETPATH' does not exist or you have no permission to write there, please select another path using option '-target path'...";
            echo $MSG;
            logMessage $MSG;
            SETTINGERROR=1
    fi 
    


    ## check for 'temporary file storage path'
    if [[ ! -d $SCRIPT_TMPPATH ]] 
        then
            MSG="ERROR: '$SCRIPT_TMPPATH' does not exist or you have no permission to write there, please select another path using option '-tmp path'...";
            echo $MSG;
            logMessage $MSG;
            SETTINGERROR=1
    fi 
    
    ## check for 'logfile'
    touch $SCRIPT_LOGFILE
    if [[ ! -w $SCRIPT_LOGFILE ]] 
        then
            MSG="ERROR: could not write to log-file '$SCRIPT_LOGFILE', please select another log-file using option '-l filepath'...";
            echo $MSG;
            logMessage $MSG;
            SETTINGERROR=1
    fi 
    
    ## prepare script execution
    ##
    ## prepare_script_execution_defined_as_a_function_in_the_beginning;
    
    if [[ $SETTINGERROR == 1 ]] 
        then
    		echo "!!! ERROR !!!";
            scriptinfo
            scriptusage
            scriptvendor
            exit
    fi 
    
    
    ## show shell script configuration, confirm execution
    ##
    scriptinfo
    
    CONTINUESCRIPT=0
    if [ $NONINTERACTIVE == 0 ]
        then
            confirm "Do you want to execute this script applying the given parameters and arguments?";
            CONTINUESCRIPT=$DIALOG__CONFIRM;
        else
            CONTINUESCRIPT=1;
    fi
    
    ## execute the script methods...
    ##
    if [ $CONTINUESCRIPT == 1 ]
        then
            
            debugMessage "init directories...";
            initReportDirs;
            createIndexPage;

            debugMessage "setup dependencies...";

            
            ## example of executing a sub-step of a 'real' script...
            ##
            SCRIPT_SKIP_THIS_STEP=0; # remove  in a real script ;)
            if [ $NONINTERACTIVE == 0 ] && [ $SCRIPT_SKIP_THIS_STEP == 0 ]
                then
                    confirm "Do you want to setup dependencies?";
                    CONTINUE_STEP=$DIALOG__CONFIRM;
                else
                    CONTINUE_STEP=1;
            fi
            if [ $CONTINUE_STEP == 1 ] && [ $SCRIPT_SKIP_THIS_STEP == 0 ]
                then
                    ## execute_next_step_defined_as_a_function_in_the_beginning();
                    setupDependencies;

            fi

            ###

            debugMessage "perform analysis...";
            
            ## example of executing a sub-step of a 'real' script...
            ##
            SCRIPT_SKIP_THIS_STEP=0; # remove  in a real script ;)
            if [ $NONINTERACTIVE == 0 ] && [ $SCRIPT_SKIP_THIS_STEP == 0 ]
                then
                    confirm "Do you want to perform analysison your code?";
                    CONTINUE_STEP=$DIALOG__CONFIRM;
                else
                    CONTINUE_STEP=1;
            fi
            if [ $CONTINUE_STEP == 1 ] && [ $SCRIPT_SKIP_THIS_STEP == 0 ]
                then
                    ## execute_next_step_defined_as_a_function_in_the_beginning();
                    performAnalysises;

            fi

    fi

    ## return to last working directory...
    cd ${current_work_dir}

    ## display script vendor info
    #scriptvendor;
    #scriptinfo;

## exit script
exit 0;

