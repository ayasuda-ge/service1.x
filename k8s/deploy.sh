
#!/bin/bash
#
#  Copyright (c) 2020 General Electric Company. All rights reserved.
#
#  The copyright to the computer software herein is the property of
#  General Electric Company. The software may be used and/or copied only
#  with the written permission of General Electric Company or in accordance
#  with the terms and conditions stipulated in the agreement/contract
#  under which the software has been supplied.
#
#  author: apolo.yasuda@ge.com

#functional interface to be implemented
# function name: int_a
#
# param1: a base64 string of a custom json object (custom-obj) from script api
# param2: a base64 string of a custom json object during sac instantiation. format: {\"region1-userpool1\":[\"service1\":\"service2\"],\"region1-userpool2\":[\"service1\":\"service2\"]}
# 
# return: stdout. 
# i.e. printf "%s" "{\"decision\":\"PERMIT\"}";return 0;
# i.e. printf "%s" "{\"error\":\"error from aws token verification.\"}";return -1;
# ex: int_a "$EXEC_DAT" "$EXEC_MAP"
 
function int_a() {
  
  echo " [+] install dep pkgs"
  pip list | grep -i pyyaml && pip install pyyaml
  apt-get -y install git
  
  #printf "{\"req\":%s,\"env\":%s,\"hello\":\"world\"}" "$1" "$2"
  #echo "$2" | jq -r '.CT_GHB_TKN'
  echo " [+] acquiring scripts/assets"
  mkdir -p tmp && cd tmp
  wget -q -O ./dpl.yaml https://raw.githubusercontent.com/ayasuda-ge/service1.x/1.1/k8s/tmpl/dpl.yaml 
  wget -q -O ./svc.yaml https://raw.githubusercontent.com/ayasuda-ge/service1.x/1.1/k8s/tmpl/svc.yaml 
  wget -q -O ./igs.yaml https://raw.githubusercontent.com/ayasuda-ge/service1.x/1.1/k8s/tmpl/igs.yaml
  
  #sid=$(echo "$1" | jq -r '.SVC_ID')  
  #sed -i "" "s|{{SVC_ID}}|$sid|g" dpl.yaml
  
  gbt=$(echo "$2" | jq -r '.CT_GHB_TKN')
  curl -Ss -o ~list "https://${gbt}@github.build.ge.com/raw/Enterprise-Connect/backup-cf-service-content/main/cf-ec-service-env-content.txt"
  git clone "https://${gbt}@github.build.ge.com/digital-connect-devops/ec-service-argo-cd-apps.git"
  
  while read -r line; do
    
    if [[ ! -z "$line" ]]; then
      if [[ "$line" != *"service instance"* ]]; then
        ref1=$(echo $line | cut -d '=' -f 1)
        ref2=$(echo $line | cut -d '=' -f 2)
        case $ref1 in
         ZONE)
         
          echo " [+] svc id: ${ref2}"
          ;;
         *)
          echo " [-] unhandled val ${ref1}: ${ref2}"
          ;;
        esac
      fi      
    fi
  done < ~list
  
  tree ./ && cd - && rm -Rf tmp
  exit 0
}
