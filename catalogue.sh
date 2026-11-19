component=catalogue
source common.sh
app_name="nodejs"
app_version="20"

copy_component_service_file &&

cp mongo.repo /etc/yum.repos.d/mongo.repo &&

app_setup &&

setup_component && 

reload_and_start_service &&

dnf install mongodb-mongosh -y >> "$log_file" 2>&1 &&

mongosh --host mongo-dev.mdevsecops.online </app/db/master-data.js >> "$log_file" 2>&1