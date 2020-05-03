#!/bin/bash

sudo apt-get update
sudo  apt-get install -y python-pip

cd home/flybird
curl https://raw.githubusercontent.com/jupyterhub/the-littlest-jupyterhub/master/bootstrap/bootstrap.py \
  | sudo python3 - \
    --admin jupyterhub

git clone https://github.com/flybirdgroup/faker_demo.git
cd faker_demo/
source venv/bin/activate

schema=./data/input/account_id_schema_new.csv
outAvro=./data/output/avro/account_id_schema_new.avro
schema1=./data/input/customer_id_schema_new.csv
outAvro1=./data/output/avro/customer_id_schema_new.avro

cat > $schema <<EOF
name,type,length
ACNO,ACNO_ID_POOL,"004000001,004100001"
EOF

for i in {1..8}
do
cat <<EOF >> $schema
FIELD_$i,decimal,"21,3,1000,9999"
EOF
done

cat > $schema1 <<EOF
name,type,length
CUSTNO,CUST_ID_POOL,"00400020,004100001"
EOF

for i in {1..8}
do
cat <<EOF >> $schema1
FIELD_$i,decimal,"21,3,1000,9999"
EOF
done

python main.py --record_count 1000 --input $schema --output $outAvro

python main.py --record_count 1000 --input $schema1 --output $outAvro1


gsutil cp ./data/output/avro/*.avro gs://zhao_michael_bucket


bq load --source_format=AVRO fakedatas.customer "gs://zhao_michael_bucket/customer_id_schema_new.avro"
bq load --source_format=AVRO fakedatas.account "gs://zhao_michael_bucket/account_id_schema_new.avro"