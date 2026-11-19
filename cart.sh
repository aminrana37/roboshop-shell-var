component=cart
source common.sh
app_name="nodejs"
app_version="20"

copy_component_service_file &&

app_setup &&

setup_component && 

reload_and_start_service