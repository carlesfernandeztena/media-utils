#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $0 <generation_id>"
    exit -1
fi
GEN=$1

# Get job_id, provide it to prod server
curl --request GET --url https://mind.oxolo.com/api/generations/$GEN --header 'token: NAUaJc6VcNprWnC6frW2ErM4kupr7WgbeKvGrvSEjbUy2jFt7LLngqLVRTSb7ert' | jq .generation.cortex_composer_job_id | tr -d '"' > job
scp job ec2-user@development:/home/ec2-user/job

# Get job from cortex
ssh production << EOF
JOB=`cat job`
echo ":: Downloading JOB=${JOB} -> ${GEN}.json (production)"
cortex get composer `cat job` -o json > temp.json
cat temp.json | jq .job_status > ${GEN}.json
rm temp.json job
EOF
de 
# Copy the file back
scp ec2-user@development:/home/ec2-user/$GEN.json .

# Remove it once copied 
ssh production << EOF
rm ${GEN}.json
EOF
rm job