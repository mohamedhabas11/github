
# Import keys

HOSTS=$(host -al move.systems | grep 'K8s-infra' |  awk '{print $1}' | sed -e 's/\.$//')

for H in $HOSTS ; do echo $H ; sed -i '' "/${H}/d"  ~/.ssh/known_hosts ; IP=$(host $H | grep -v NXDOMAIN | awk '{print $4}') ;  if [ "${IP}" != "" ] ; then sed -i '' "/${IP}/d"  ~/.ssh/known_hosts ; fi ; done

for H in $HOSTS ; do echo $H ; ssh -o ConnectTimeout=1 -o ConnectionAttempts=1 -o StrictHostKeyChecking=no -o PasswordAuthentication=no $H date ; done
