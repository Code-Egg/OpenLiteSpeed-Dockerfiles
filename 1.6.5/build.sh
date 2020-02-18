#!/usr/bin/env bash
OLS_VERSION=''
PHP_VERSION=''
PUSH=''

help_message(){
    echo 'Command [-ols XX] [-php lsphpXX]'
    echo 'Command [-ols XX] [-php lsphpXX] --push'
    echo 'Example: build.sh -ols 1.6.5 -php lsphp73 --push'
}

check_input(){
    if [ -z "${1}" ]; then
        help_message
        exit 1
    fi
}

build_image(){
    echo $1 $2
    docker build . --tag litespeedtech/openlitespeed-beta:$1-$2 --build-arg OLS_VERSION=$1 --build-arg PHP_VERSION=$2
}

test_image(){
    ID=$(docker run -d litespeedtech/openlitespeed-beta:$1-$2)

    docker exec -it $ID su -c 'mkdir -p /var/www/vhosts/localhost/html/ && echo "<?php phpinfo();" > /var/www/vhosts/localhost/html/index.php && /usr/local/lsws/bin/lswsctrl restart'

    HTTP=$(docker exec -it $ID curl -s -o /dev/null -Ik -w "%{http_code}" http://localhost)
    HTTPS=$(docker exec -it $ID curl -s -o /dev/null -Ik -w "%{http_code}" https://localhost)
    docker kill $ID

    if [[ "$HTTP" != "200" || "$HTTPS" != "200" ]]; then
        echo "Test failed, localhost didn't return the right http code"
        echo "http://localhost" returned "$HTTP"
        echo "https://localhost" returned "$HTTPS"
        exit 1
    fi
    echo "Tests passed"
}

push_image(){
    if [ -f ~/.docker/litespeedtech/config.json ]; then
        CONFIG=$(echo --config ~/.docker/litespeedtech)
    else
        CONFIG=''
    fi
    docker ${CONFIG} push litespeedtech/openlitespeed-beta:$1-$2
}

main(){
    if [ -z "${OLS_VERSION}" ]; then
        help_message
        exit 1
    fi
    if [ -z "${PHP_VERSION}" ]; then
        help_message
        exit 1
    fi
    build_image ${OLS_VERSION} ${PHP_VERSION}
    test_image ${OLS_VERSION} ${PHP_VERSION}
    if [ ! -z "${PUSH}" ]; then
        push_image ${OLS_VERSION} ${PHP_VERSION}
    fi
    
}

check_input ${1}
while [ ! -z "${1}" ]; do
    case ${1} in
        -[hH] | -help | --help)
            help_message
            exit 1
            ;;
        -ols | -OLS_VERSION | -O) shift
            check_input "${1}"
            OLS_VERSION="${1}"
            ;;
        -php | -PHP_VERSION | -P) shift
            check_input "${1}"
            PHP_VERSION="${1}"
            ;;
        --push ) shift
            PUSH=true
            ;;            
        *) 
            help_message
            exit 1
            ;;              
    esac
    shift
done

main