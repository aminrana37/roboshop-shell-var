component=mongo
source=common.sh

copy_component_repo &&

dnf install mongodb-org -y >> "$log_file" 2>&1 &&

systemctl enable mongod >> "$log_file" 2>&1 &&
systemctl start mongod >> "$log_file" 2>&1 &&

sed -i 's/127\.0\.0\.1/0.0.0.0/g' /etc/mongod.conf &&

systemctl restart mongod >> "$log_file" 2>&1 