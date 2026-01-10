#!/usr/bin/env bash

: <<EOF
This is script to create disks for RHCSA env.
EOF

#Y:
# ./../../disks/ = var
# array=(foldernames)
# fn
#   1. if_dir_exists() => 1 if exists.
#   2. count_directory()
#   3. folders_print
# ----
#   3. delete_dir
#   4. create_dir
#   5. create_disk
#   6. select_disk_size
#   7. choose_delete {
#   exisit= choose delete=1/0?
#   if delete=1
#      delete
#      create_dir
#      create_disk
#   else
#       user aborted
#       exit 1
#   }
#
# B :
# if 1=false
#   4. create_dir
#   5. create_disk
# elif 1=true
#    6. choose_delete
# else
#   echo count_directory
#   exisisting folders,
#   3. folders_print
#   6. choose_delete
# fi

BASE_DIR="./../../disks"
EXPECTED_DIR=("1_arch" "2_rocky" "3_ubi" "4_ubuntu")
RED='\033[0;31m'
NC='\033[0m'

if_dirs_exists() {
  for dir in "${EXPECTED_DIR[@]}"; do
    [[ -d "${BASE_DIR}/${dir}" ]] || return 0 # || mean if not exists => 0 else 1
  done
  return 1
}

count_dirs() {
  local count
  for dir in "${EXPECTED_DIR[@]}"; do
    [[ -d "${BASE_DIR}/${dir}" ]] && ((count++))
  done
  echo "${count}"
}
count=$(count_dirs)

folders_print() {
  ls -al "${BASE_DIR}"
}

delete_dirs() {
  echo "-------------| delete_dirs |-------------"
  for dir in "${EXPECTED_DIR[@]}"; do
    rm -rfv "${BASE_DIR:?}/$dir"
  done
}

create_dirs() {
  echo "-------------| create_dirs |-------------"
  for dir in "${EXPECTED_DIR[@]}"; do
    mkdir -pv "${BASE_DIR:?}/$dir"
  done
}

create_disks() {
  for dir in "${EXPECTED_DIR[@]}"; do
    truncate -s "$1" "${BASE_DIR}/${dir}/disk1.img"
    truncate -s "$1" "${BASE_DIR}/${dir}/disk2.img"
    echo "${BASE_DIR}/${dir}/disk1.img and ${BASE_DIR}/${dir}/disk2.img creaded."
  done
}

select_disk_size() {
  echo -e "Please Select The size of Disk you want to create."
  echo -e " 1:50Mb | 2:100Mb | 3:200Mb | select 0 if you want to only clear disks."
  read -r -p "=> " size
  case "$size" in
  1) create_disks "50m" ;;
  2) create_disks "100m" ;;
  3) create_disks "200m" ;;
  *)
    echo "Please Select Valid Option."
    echo -e "${RED}Disks are not creted, Please try again."
    exit 1
    ;;
  esac
}

choose_delete_or_not() {
  echo -e "Directoris Exists Do You still want to continue."
  echo -e "${RED} ⚠️All Data in ${BASE_DIR} will be deleted !!!${NC}"
  echo -e "${RED}YES=1 ${NC}"
  read -r -p $" : " yes_delete

  if [[ ${yes_delete} == "1" ]]; then
    delete_dirs
    create_dirs
    select_disk_size
    echo "Disks Created successfully."
    exit 1
  else
    echo "|> User Aborted."
    exit 1
  fi
}

if [[ "${count}" -eq 0 ]]; then
  create_dirs
  select_disk_size
  echo "Directoris Created successfully."
  exit 1
elif if_dirs_exists; then
  echo "${count} Expected Directores out of 4 exists and there are other Directorys, which are as follows:"
  echo "| we will not touch other directories |"
  folders_print
  choose_delete_or_not
else
  choose_delete_or_not
fi
