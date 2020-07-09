export GOPATH=$HOME/workdir/go
export PATH="$GOPATH/bin:$PATH"

export WORKDIR=$HOME/workdir
alias cdtet="pushd $WORKDIR/go/src/github.com/TetrationAnalytics/tetration/"
alias cdsensor="pushd $WORKDIR/go/src/github.com/TetrationAnalytics/tetration/sensor-go/appliance"
alias cdams="pushd $WORKDIR/java/tetration/java/adhoc/scheduler"
alias cdamsgo="pushd $WORKDIR/java/tetration/golang/src/tetration/ams"
alias cde2e="pushd $WORKDIR/regression/tetration/test_framework/src/connectors_regression"

alias gcp="git cherry-pick -x -s"
alias gmm="git merge main_dev"
alias gcom="git checkout main_dev"

erpm-full(){
    rpm2cpio $1 | cpio -idmv
}
alias erpm=erpm-full

replace-rpm() {
    rm -rf /tmp/usr
    erpm $1
    cp /tmp/usr/local/tet-netflow/tet-netflowsensor /usr/local/tet-netflow
}
alias rrpm=replace-rpm

chrome-full() {
    open -a /Applications/Google\ Chrome.app http://$1
}
alias chrome=chrome-full

chromes-full() {
    open -a /Applications/Google\ Chrome.app https://$1
}
alias chromes=chromes-full

chromecluster-full() {
    open -a /Applications/Google\ Chrome.app https://$1.tetrationanalytics.com
}
alias chromecluster=chromecluster-full

alias startnf='systemctl restart tet-netflowsensor.service'
alias statusnf='systemctl status tet-netflowsensor.service'
alias stopnf='systemctl stop tet-netflowsensor.service'
alias startaws='systemctl restart tet-awsvpclogs-downloader.service'
alias statusaws='systemctl status tet-awsvpclogs-downloader.service'
alias stopaws='systemctl stop tet-awsvpclogs-downloader.service'

# ssh access to happobat server
function happobat() {
  if [[ "$1" == "" ]] || [[ "$2" == "" ]]; then
    echo "Usage: ${funcstack[1]} <happobat instance id> <cluster name/id>"
    return
  fi
  ssh -t tetter@orch-"$2".tetrationanalytics.com "sudo su - tetinstall -c 'ssh happobat-$1'"
}

# alias for ssh to specific happobat instance
alias happobat1="happobat 1"
alias happobat2="happobat 2"

# turnoff services in happobat
function turnoff-happobat() {
  if [[ "$1" == "" ]] || [[ "$2" == "" ]] || [[ "$3" == "" ]]; then
    echo "Usage: ${funcstack[1]} <happobat instance id> <component> <cluster name/id>"
    return
  fi
  ssh -t tetter@orch-"$3".tetrationanalytics.com "sudo su - tetinstall -c 'ssh happobat-$1 sudo sv stop $2'"
}

# alias for turn off specific service on specific happobat instance
alias turnoff-ams1="turnoff-happobat 1 adhocsched"
alias turnoff-ams2="turnoff-happobat 2 adhocsched"
alias turnoff-amsgo1="turnoff-happobat 1 adhoc_ams_ext"
alias turnoff-amsgo2="turnoff-happobat 2 adhoc_ams_ext"

# deploy a service to happobat (AMS/AMS-go/AQS...)
function deploy-happobat() {
  if [[ "$1" == "" ]] || [[ "$2" == "" ]] || [[ "$3" == "" ]] || [[ "$4" == "" ]]; then
    echo "Usage: ${funcstack[1]} <happobat instance id> <component_path> <component_service> <cluster name/id> <binary_to_scp_path>"
    echo "Example: ${funcstack[1]} 1 /opt/tetration/adhocsched/adhoc-scheduler.jar adhocsched beretta target/adhoc-scheduler-SNAPSHOT-1.0.jar"
    return
  fi

  ams="happobat-$1"
  component_path="$2"
  component_service="$3"
  cluster="orch-$4.tetrationanalytics.com"
  binary="$5"

  tmp_loc="/tmp/ams.tmp"

  echo "Copying $binary to cluster $cluster -- $ams:$component_path"

  read -r "response?Are you sure ? [Y/n] "
  response=${response:l} #tolower
  if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    scp "$binary" tetter@"$cluster:$tmp_loc"
    ssh tetter@"$cluster" "sudo su - tetinstall -c 'scp $tmp_loc $ams:/tmp'"
  else
    return 1
  fi

  ssh tetter@"$cluster" "sudo su - tetinstall -c 'ssh $ams sudo mv $tmp_loc $component_path'"
  ssh tetter@"$cluster" "sudo su - tetinstall -c 'ssh $ams sudo sv restart $component_service'"
}

# deploy ams to a cluster
AMS_SERVICE=adhocsched
AMS_PATH=/opt/tetration/$AMS_SERVICE/adhoc-scheduler.jar
alias deploy-ams1="deploy-happobat 1 $AMS_PATH $AMS_SERVICE"
alias deploy-ams2="deploy-happobat 2 $AMS_PATH $AMS_SERVICE"

# deploy aqs to a cluster
AQS_SERVICE=appset_query_server
AQS_PATH=/opt/tetration/$AQS_SERVICE/appset-query-server.jar
alias deploy-aqs1="deploy-happobat 1 $AQS_PATH $AQS_SERVICE"
alias deploy-aqs2="deploy-happobat 2 $AQS_PATH $AQS_SERVICE"

# deploy ams-go to a cluster
AMSGO_SERVICE=adhoc_ams_ext
AMSGO_PATH=/opt/tetration/$AMSGO_SERVICE/ams_ext_server
alias deploy-amsgo1="deploy-happobat 1 $AMSGO_PATH $AMSGO_SERVICE"
alias deploy-amsgo2="deploy-happobat 2 $AMSGO_PATH $AMSGO_SERVICE"

# ssh access to mongodb
function mongo_db() {
  if [[ "$1" == "" ]] || [[ "$2" == "" ]]; then
    echo "Usage: ${funcstack[1]} <mongodb instance id> <cluster name/id>"
    return
  fi
  ssh -t tetter@orch-$2.tetrationanalytics.com "sudo su - tetinstall -c 'ssh -t mongodb-$1 mongo'"
}

# legacy alias support
alias mgo1="mongo_db 1"
alias mgo2="mongo_db 2"
alias mgo=mgo1

# ssh access to orchestrator
function cluster() {
  if [ "$1" = "" ]; then
    echo "Usage: ${funcstack[1]} <cluster name/id>"
    return
  fi
  if [ "$2" = "" ]; then
    ssh -t tetter@orch-$1.tetrationanalytics.com "sudo su - tetinstall"
  else
    ssh -t tetter@orch-$1.tetrationanalytics.com "sudo su - tetinstall -c 'ssh $2'"
  fi
}

# scp file to orchestrator
function clusterScp() {
  if [ "$1" = "" ]; then
    echo "Usage: ${funcstack[1]} <cluster name/id> <binary_to_scp_path>"
    return
  fi
  if [ "$2" = "" ]; then
    echo "Usage: ${funcstack[1]} <cluster name/id> <binary_to_scp_path>"
    return
  fi
  scp $2 tetter@orch-$1.tetrationanalytics.com:/tmp/
}

function tunnel() {
  if [ "$1" = "" ]; then
    echo "Usage: ${funcstack[1]} <cluster name/id>"
    return
  fi
  ssh -f -N -L 8090:druid-broker.service.consul:8090 -L 8091:haproxy-internal.service.consul:80 -L 8080:happobat-1:8080 -L 8087:happobat-1:8087 -l tetter orch-$1.tetrationanalytics.com
}

# start tunnel for ams/amsgo etc..
function mdev() {
  if [ "$1" = "" ]; then
    echo "Usage: $funcstack[1] <cluster name/id>"
    return
  fi
  ssh -N -C -vv \
    -L 9196:1.1.1.12:9196 \
    -L 8090:druidHistoricalBroker-1:8090 \
    -L 8889:orchestrator-1:8889 \
    -L 9696:appserver-1:9696 \
    -L 7733:appserver-1:7733 \
    -L 4242:tsdbBosunGrafana-1:4242 \
    -L 8086:happobat-1:8086 \
    -L 8080:happobat-1:8080 \
    -L 8118:appserver-1:8118 \
    -L 38017:mongodb-2:27017 \
    -l tetter orch-$1.tetrationanalytics.com
}

function deploy-appserver1-openapi()
{
    if [ "$1" = "" ]; then
        echo "Usage: $funcstack[1] <cluster name/id> <binary_to_scp_path>";
        return;
    fi
    if [ "$2" = "" ]; then
        echo "Usage: $funcstack[1] <cluster name/id> <binary_to_scp_path>";
        return;
    fi

    cluster="orch-$1.tetrationanalytics.com"
    appserver="appserver-1"
    tmp_loc="/tmp/api.tmp"

    echo "Copying $2 to cluster $1 -- $appserver:/opt/h4/api/api_server"

    read "response?Are you sure ? [Y/n] "
    response=${response:l} #tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        scp $2 tetter@$cluster:$tmp_loc
        ssh tetter@$cluster "sudo su - tetinstall -c 'scp $tmp_loc $appserver:/tmp'"
    else
        return 1
    fi

    ssh tetter@$cluster "sudo su - tetinstall -c 'ssh $appserver sudo mv $tmp_loc /opt/h4/api/api_server'"
    ssh tetter@$cluster "sudo su - tetinstall -c 'ssh $appserver sudo sv restart api_server'"
}

function deploy-appserver2-openapi()
{
    if [ "$1" = "" ]; then
        echo "Usage: $funcstack[1] <cluster name/id> <binary_to_scp_path>";
        return;
    fi
    if [ "$2" = "" ]; then
        echo "Usage: $funcstack[1] <cluster name/id> <binary_to_scp_path>";
        return;
    fi

    cluster="orch-$1.tetrationanalytics.com"
    appserver="appserver-2"
    tmp_loc="/tmp/api.tmp"

    echo "Copying $2 to cluster $1 -- $appserver:/opt/h4/api/api_server"

    read "response?Are you sure ? [Y/n] "
    response=${response:l} #tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        scp $2 tetter@$cluster:$tmp_loc
        ssh tetter@$cluster "sudo su - tetinstall -c 'scp $tmp_loc $appserver:/tmp'"
    else
        return 1
    fi

    ssh tetter@$cluster "sudo su - tetinstall -c 'ssh $appserver sudo mv $tmp_loc /opt/h4/api/api_server'"
    ssh tetter@$cluster "sudo su - tetinstall -c 'ssh $appserver sudo sv restart api_server'"
}

function deploy-appserver-openapi(){
    deploy-appserver1-openapi $1 $2
    deploy-appserver2-openapi $1 $2
}


function deploy-appserver1-wss()
{
    if [ "$1" = "" ]; then
        echo "Usage: $funcstack[1] <cluster name/id> <binary_to_scp_path>";
        return;
    fi
    if [ "$2" = "" ]; then
        echo "Usage: $funcstack[1] <cluster name/id> <binary_to_scp_path>";
        return;
    fi

    cluster="orch-$1.tetrationanalytics.com"
    appserver="appserver-1"
    tmp_loc="/tmp/api.tmp"

    echo "Copying $2 to cluster $1 -- $appserver:/opt/wss/wss"

    read "response?Are you sure ? [Y/n] "
    response=${response:l} #tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        scp $2 tetter@$cluster:$tmp_loc
        ssh tetter@$cluster "sudo su - tetinstall -c 'scp $tmp_loc $appserver:/tmp'"
    else
        return 1
    fi

    ssh tetter@$cluster "sudo su - tetinstall -c 'ssh $appserver sudo mv $tmp_loc /opt/wss/wss'"
    ssh tetter@$cluster "sudo su - tetinstall -c 'ssh $appserver sudo sv restart wss'"
}

function deploy-appserver2-wss()
{
    if [ "$1" = "" ]; then
        echo "Usage: $funcstack[1] <cluster name/id> <binary_to_scp_path>";
        return;
    fi
    if [ "$2" = "" ]; then
        echo "Usage: $funcstack[1] <cluster name/id> <binary_to_scp_path>";
        return;
    fi

    cluster="orch-$1.tetrationanalytics.com"
    appserver="appserver-2"
    tmp_loc="/tmp/api.tmp"

    echo "Copying $2 to cluster $1 -- $appserver:/opt/wss/wss"

    read "response?Are you sure ? [Y/n] "
    response=${response:l} #tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        scp $2 tetter@$cluster:$tmp_loc
        ssh tetter@$cluster "sudo su - tetinstall -c 'scp $tmp_loc $appserver:/tmp'"
    else
        return 1
    fi

    ssh tetter@$cluster "sudo su - tetinstall -c 'ssh $appserver sudo mv $tmp_loc /opt/wss/wss'"
    ssh tetter@$cluster "sudo su - tetinstall -c 'ssh $appserver sudo sv restart wss'"
}

function deploy-appserver-wss(){
    deploy-appserver1-wss $1 $2
    deploy-appserver2-wss $1 $2
}
