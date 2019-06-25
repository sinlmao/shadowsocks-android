#!/bin/bash -e

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/gen.XXXXXX)

GFWLIST_URL="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"
CHNROUTE_URL="https://pexcn.me/daily/chnroute/chnroute.txt"

function fetch_data() {
  cd $TMP_DIR
  curl -sSL $GFWLIST_URL > gfwlist.txt
  curl -sSL $CHNROUTE_URL > chnroute.txt
  cd $CUR_DIR
}

function gen_gfwlist_acl() {
  cd $TMP_DIR
  python $CUR_DIR/parse.py -i gfwlist.txt -f gfwlist.tmp
  sed -i 's/.*\((^|\\.)blogspot\\.\).*/\(^|\\.)blogspot(\\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?){1,2}$/' gfwlist.tmp
  sed -i 's/.*\((^|\\.)google\\.\).*/\(^|\\.)google(\\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?){1,2}$/' gfwlist.tmp
  sed -i 's/.*\((^|\\.)googleapis\\.\).*/\(^|\\.)googleapis(\\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?){1,2}$/' gfwlist.tmp
  uniq gfwlist.tmp > gfwlist.acl
  cd $CUR_DIR
}

function gen_chinalist_acl() {
  cd $TMP_DIR
  cp $CUR_DIR/template/china-list.acl .
  sed -i "s/___CHNROUTE_LIST_PLACEHOLDER___/cat chnroute.txt/e" china-list.acl
  cd $CUR_DIR
}

function gen_bypass_acls() {
  cd $TMP_DIR
  cp $CUR_DIR/template/bypass-china.acl .
  cp $CUR_DIR/template/bypass-lan-china.acl .
  sed -e "1,/proxy_list/d" gfwlist.acl > proxylist.txt
  sed -i "s/___CHNROUTE_LIST_PLACEHOLDER___/cat chnroute.txt/e" bypass-china.acl bypass-lan-china.acl
  sed -i "s/___GFWLIST_PROXY_LIST_PLACEHOLDER___/cat proxylist.txt/e" bypass-china.acl bypass-lan-china.acl
  cd $CUR_DIR
}

function dist_release() {
  mkdir -p gh-pages/acl
  cp $TMP_DIR/gfwlist.acl gh-pages/acl/
  cp $TMP_DIR/china-list.acl gh-pages/acl/
  cp $TMP_DIR/bypass-china.acl gh-pages/acl/
  cp $TMP_DIR/bypass-lan-china.acl gh-pages/acl/
  cp template/bypass-lan.acl gh-pages/acl/
}

fetch_data
gen_gfwlist_acl
gen_chinalist_acl
gen_bypass_acls
dist_release
