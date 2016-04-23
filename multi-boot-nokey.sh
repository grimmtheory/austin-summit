#!/bin/bash
clear

# Variables
# CREDS = OpenStack cred file to source for the operation
# KEY_NAME = your key
# FLAVOR =
## cloudpharma = 6 core x 4 gb ram - 366766f9-6e82-464f-9418-4ab284d82462 
## m1.small = 1 core x 2 gb ram - e0e3d365-f495-43f9-b0ea-7037ea337576
## m1.medium = 2 core x 4 gb ram - 2c8f5c26-9ecb-4351-b11e-8a3008e7a53e
## m1.xlarge = 8 core x 16 gb ram - 9c6460db-ba32-4dfa-ae11-ab946ff6eaf2
## m1.xxlarge = 16 core x 16 gb ram - 7cbbfa6a-c515-40e6-932a-fc0cb73d8cf8
## m1.xxxlarge = 32 core x 16 gb ram - bfc7222b-98e5-458b-adb9-26b7165bbf97
# IMAGE = 8b07434f-c161-4cd4-a61b-b80722217c7e (Ubuntu 14.04)
# NET_ID = efe53604-adcf-4914-a267-b3b08f204e2d (cusps project default network)
# AVAILABILITY_ZONE = cusps1:mhv2.cusps1.pv.metacloud.in (if "pinning" workloads to specific hosts, set to just "cusps" with no host if not pinngin)
# COUNT = 1 (if booting multiple instances)
# MACHINE_NAME = cloudpharma (machine name prefix)
# USER_DATA = user_data.file (if passing cloud-init / user_data during boot)

CREDS="./credrc-cusps1"
KEY_NAME="jtg-keypair"
FLAVOR="e0e3d365-f495-43f9-b0ea-7037ea337576"
IMAGE="8b07434f-c161-4cd4-a61b-b80722217c7e"
NET_ID="efe53604-adcf-4914-a267-b3b08f204e2d"
AVAILABILITY_ZONE="cusps1:mhv2.cusps1.pv.metacloud.in"
COUNT=60
MACHINE_NAME="cloudpharma-hpctest"
USER_DATA="./user_data.file"
RUN_NAME="60x1x2"

cat <<'EOF' > $USER_DATA
#!/bin/bash
cd /root
wget http://184.94.252.50/upload/test.tgz
sleep 30
tar -zxvf test.tgz
sleep 30
HOME="/root"
export MOPAC_LICENSE=$HOME/MOPAC2007/
export LD_LIBRARY_PATH=$HOME/openbabel-2.3.2/build/lib/
export BABEL_LIBDIR=$HOME/openbabel-2.3.2/build/lib/
export BABEL_DATADIR=$HOME/openbabel-2.3.2/data/
# . The root of the program.
PDYNAMO_ROOT=$HOME/pdynamo-1.5 ; export PDYNAMO_ROOT
# . Package paths.
PDYNAMO_PBABEL=$PDYNAMO_ROOT/pBabel-1.5 ; export PDYNAMO_PBABEL           
PDYNAMO_PCORE=$PDYNAMO_ROOT/pCore-1.5 ; export PDYNAMO_PCORE            
PDYNAMO_PMOLECULE=$PDYNAMO_ROOT/pMolecule-1.5 ; export PDYNAMO_PMOLECULE       
PDYNAMO_PMOLECULESCRIPTS=$PDYNAMO_ROOT/pMoleculeScripts-1.5 ; export PDYNAMO_PMOLECULESCRIPTS 
# . Additional paths.
PBABEL_PDBDATA=$PDYNAMO_ROOT/pBabel-1.5/parameters ; export PBABEL_PDBDATA   
PDYNAMO_SCRATCH=$PDYNAMO_ROOT/scratch ; export PDYNAMO_SCRATCH   
PDYNAMO_STYLE=$PDYNAMO_ROOT/pCore-1.5/parameters/styles/defaultstyle.css ; export PDYNAMO_STYLE     
PMOLECULE_PARAMETERS=$PDYNAMO_ROOT/pMolecule-1.5/parameters ; export PMOLECULE_PARAMETERS
# . The python path.
PYTHONPATH=:$PDYNAMO_ROOT/pBabel-1.5:$PDYNAMO_ROOT/pCore-1.5:$PDYNAMO_ROOT/pMolecule-1.5:$PDYNAMO_ROOT/pMoleculeScripts-1.5 ; export PYTHONPATH
cd ramp_rate_inputs 
date > execution_time.txt
./test.sh > wjs-stdout.txt 
date >> execution_time.txt
cp execution_time.txt $HOME/.
cd $HOME
cat <<'KEY' > ./key.pem
-----BEGIN RSA PRIVATE KEY-----
PUT RSA KEY HERE
-----END RSA PRIVATE KEY-----
KEY
chmod 400 ./key.pem
scp -i ./key.pem -o StrictHostKeyChecking=no execution_time.txt cloud@184.94.252.50:/home/cloud/output/$HOSTNAME.txt
exit 0
EOF

. $CREDS

counter=1
while [ $counter -le $COUNT ]; do
nova boot --key-name $KEY_NAME --flavor $FLAVOR --image $IMAGE --nic net-id=$NET_ID --availability-zone $AVAILABILITY_ZONE --user-data $USER_DATA $MACHINE_NAME-$counter
counter=$(( $counter + 1 ))
sleep 10
done

# Check progress
sleep 10
nova list

# Cleanup
rm -rf $USER_DATA

# Exit
exit 0
