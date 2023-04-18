#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $0 <generation_id>"
    exit -1
fi
GEN=$1

# Get job_id, provide it to prod server
curl --request GET --url https://mind.development.oxolo.com/api/generations/${GEN} --header 'token: NAUaJc6VcNprWnC6frW2ErM4kupr7WgbeKvGrvSEjbUy2jFt7LLngqLVRTSb7ert' | jq .generation.cortex_composer_job_id | tr -d '"' > job
JOB=`cat job`
echo ":: Downloaded JOB = ${JOB} (locally)"
scp job ec2-user@development:/home/ec2-user/job

# Get job from cortex
ssh development << EOF
JOB=`cat job`
echo ":: Getting cortex job -> ${GEN}.json (development)"
cortex get composer `cat job` -o json > temp.json
cat temp.json | jq .job_status > ${GEN}.json
rm temp.json job
EOF

# Copy the file back
scp ec2-user@development:/home/ec2-user/$GEN.json .

# Remove it once copied 
ssh development << EOF
rm ${GEN}.json
EOF
rm job