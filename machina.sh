#!/bin/bash

# Application configuration
APP_NAME="machina"
APP_VERSION="v0.3.1"
APP_DIR="$HOME/.machina"
IMGS_DIR="$APP_DIR/images"
VMS_DIR="$APP_DIR/vms"
SESSION_NAME="session"

# Machine configuration
DISTRO="ubuntu20.04"
DISTRO_LIST=("almalinux8.4" "centos8" "centos-stream9" "debian11" "fedora34" "rockylinux8.4" "ubuntu20.04")
CLOUD_IMAGE="focal-server-cloudimg-amd64.img"
OS_VARIANT="ubuntu20.04"
VM_NAME="${APP_NAME}"
VM_RAM="2"
VM_CPUS="1"
VM_DISK="20"
USERNAME="$APP_NAME"
PASSWORD="$APP_NAME"

# Shows the help menu
function show_help() {
    case "$1" in 
        (create)
            echo "USAGE: "
            echo " ${APP_NAME} create [action] [options]"
            echo "     Creates and starts a new ${APP_NAME} machine"
            echo ""
            echo "Options:"
            echo "  -c, --cpus <cpus>           Number of CPU's to allocate."
            echo "                              Default: ${VM_CPUS}"
            echo "  -d, --disk <disk>           Disk space to allocate. Positive integer, in GB."
            echo "                              Default: ${VM_DISK}"
            echo "  -i, --image <image>         Set's the image to use. Run '${APP_NAME} image list' for a list of available images"
            echo "                              Default: ubuntu20.04"
            echo "  -n, --mem <mem>             Amount of memory to allocate. Positive integer, in GB."
            echo "                              Default: ${VM_RAM}"
            echo "  -n, --name <name>           Name of the machine."
            echo "                              Default: ${VM_NAME}"
            echo "  -p, --password <password>   Username to be used on the machine."
            echo "  -s, --system                Creates the machine on the system session."
            echo "                              Default: session"
            echo "                              Default: $USERNAME}"
            echo "  -u, --username <username>   Password to be used on the machine."
            echo "                              Default: $PASSWORD}"
            echo ""
            exit
        ;;
        (destroy)
            echo "USAGE: "
            echo " ${APP_NAME} destroy [options]"
            echo "     Deletes an existing ${APP_NAME} machine"
            echo ""
            echo "Options:"
            echo "  name            Name of the machine."
            echo "                  Default: ${VM_NAME}"
            echo ""
            exit
        ;;
        (image)
            echo "USAGE: "
            echo " ${APP_NAME} image [options]"
            echo "     Deletes an existing ${APP_NAME} machine"
            echo ""
            echo "Options:"
            echo "  list                Shows a list of available images.update"
            # echo "  download <image>    Downloads an image. If the image exists locally, will be updated."
            echo ""
            exit
        ;;
        (shell)
            echo "USAGE: "
            echo " ${APP_NAME} shell [name]"
            echo "     Connects to a running ${APP_NAME} machine over SSH"
            echo ""
            echo "Options:"
            echo "  name            Name of the machine."
            echo "                  Default: ${VM_NAME}"
            echo ""
            exit
        ;;
        (start)
            echo "USAGE: "
            echo " ${APP_NAME} start [name]"
            echo "     Starts a stopped ${APP_NAME} machine"
            echo ""
            echo "Options:"
            echo "  name            Name of the machine."
            echo "                  Default: ${VM_NAME}"
            echo ""
            exit
        ;;
        (reboot)
            echo "USAGE: "
            echo " ${APP_NAME} reboot [name]"
            echo "     Reboots a running ${APP_NAME} machine"
            echo ""
            echo "Options:"
            echo "  name            Name of the machine."
            echo "                  Default: ${VM_NAME}"
            echo ""
            exit
        ;;
        (stop)
            echo "USAGE: "
            echo " ${APP_NAME} stop [name]"
            echo "     Stops a running ${APP_NAME} machine"
            echo ""
            echo "Options:"
            echo "  name            Name of the machine."
            echo "                  Default: ${VM_NAME}"
            echo ""
            exit
        ;;
        (*)
            echo "USAGE: "
            echo " ${APP_NAME} [action] [options]"
            echo "     Manages ${APP_NAME} machines through kvm"
            echo ""
            echo "Actions:"
            echo "  create              Creates a new machine."
            echo "  destroy             Deletes an existing machine."
            echo "  help [action]       Shows command help."
            echo "  image               Manage images."
            echo "  reboot              Reboots running machine."
            echo "  shell               SSH's to an existing machine."
            echo "  start               Starts a stopped machine."
            echo "  stop                Stops running machine."
            echo "  version             Shows the application version."
            # echo "  update              Downloads the latest ubuntu cloud image."
            echo ""
            exit
        ;;
    esac
}

# Function that dowloads the image from the web
function download_image() {
    mkdir -p ${IMGS_DIR}
    printf "Downloading latest image... "
    case "${DISTRO}" in
        (almalinux8.4)
            OS_VARIANT="centos8"
            CLOUD_IMAGE="AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
            wget -N -P ${IMGS_DIR} https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/${CLOUD_IMAGE} &>/dev/null
            shift
        ;;
        (centos8)
            printf "Downloading latest image... "
            OS_VARIANT="centos8"
            CLOUD_IMAGE="CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
            wget -N -P ${IMGS_DIR} https://cloud.centos.org/centos/8/x86_64/images/${CLOUD_IMAGE} &>/dev/null
            shift
        ;;
        (centos-stream9)
            OS_VARIANT="centos-stream9"
            CLOUD_IMAGE="CentOS-Stream-GenericCloud-9-20211021.0.x86_64.qcow2"
            wget -N -P ${IMGS_DIR} https://cloud.centos.org/centos/9-stream/x86_64/images/${CLOUD_IMAGE} &>/dev/null
            shift
        ;;
        (debian11)
            OS_VARIANT="debian10"
            CLOUD_IMAGE="debian-11-genericcloud-amd64.qcow2"
            wget -N -P ${IMGS_DIR} https://get.debian.org/cdimage/cloud/bullseye/latest/${CLOUD_IMAGE} &>/dev/null
            shift
        ;;
        (fedora34)
            OS_VARIANT="fedora34"
            CLOUD_IMAGE="Fedora-Cloud-Base-34-1.2.x86_64.qcow2"
            wget -N -P ${IMGS_DIR} https://download.fedoraproject.org/pub/fedora/linux/releases/34/Cloud/x86_64/images/${CLOUD_IMAGE} &>/dev/null
            shift
        ;;
        (rockylinux8.4)
            OS_VARIANT="centos8"
            CLOUD_IMAGE="Rocky-8-GenericCloud-8.4-20210620.0.x86_64.qcow2"
            wget -N -P ${IMGS_DIR} https://download.rockylinux.org/pub/rocky/8.4/images/${CLOUD_IMAGE} &>/dev/null
            shift
        ;;
        (ubuntu20.04)
            OS_VARIANT="ubuntu20.04"
            CLOUD_IMAGE="focal-server-cloudimg-amd64.img"
            wget -N -P ${IMGS_DIR} https://cloud-images.ubuntu.com/focal/current/${CLOUD_IMAGE} &>/dev/null
            shift
        ;;
        (*)
            printf " Failed!\n"
            echo "Image not available."
            echo "Run '${APP_NAME} image list' to get a list of available images."
            exit
        ;;
    esac
    printf " Done!\n"
}

# Creates a new kvm machine
function create_machine() {
    # Check if image already exists

    if [ -d ${VMS_DIR}/${VM_NAME} ]; then
        echo "Machine '${VM_NAME}' already exists."
        exit
    fi

    # Check passed values
    while (( $# > 0 )); do
        case "$1" in 
            (-c|--cpu)
                VM_CPUS=$2
                shift
            ;;
            (-d|--disk)
                VM_DISK=$2
                shift
            ;;
            (-i|--image)
                DISTRO=$2
                shift
            ;;
            (-m|--memory)
                VM_RAM=$2
                shift
            ;;
            (-n|--name)
                VM_NAME=$2
                shift
            ;;
            (-s|--system)
                SESSION_NAME="system"
                shift
            ;;
            (*)
                shift
            ;;
        esac
    done

    download_image $DISTRO
    # Creates machine structure directory
    printf "Creating the structure... "
    mkdir -p ${VMS_DIR}/${VM_NAME}
    # Create image disk from the image
    qemu-img create -F qcow2 -b ${IMGS_DIR}/${CLOUD_IMAGE} -f qcow2 ${VMS_DIR}/${VM_NAME}/${VM_NAME}.qcow2 ${VM_DISK}G &>/dev/null 
    printf "Done!\n"

    # Configuring network
    MAC_ADDRESS=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    INTERFACE=eth01
    IP_ADDRESS=$(printf '192.168.122.%2d' $((RANDOM%244 + 10)))

    # Generate SSH key
    printf "Generating the SSH key... "
    ssh-keygen -R "${IP_ADDRESS}" &>/dev/null
    ssh-keygen -t rsa -b 4096 -q -N "" -f ${VMS_DIR}/${VM_NAME}/id_rsa
    SSH_PUB_KEY=$(cat ${VMS_DIR}/${VM_NAME}/id_rsa.pub)
    printf "Done!\n"

    # Configures network
    printf "Configuring the machine... "
    cat >${VMS_DIR}/${VM_NAME}/network-config <<EOF
ethernets:
    $INTERFACE:
        addresses:
        - $IP_ADDRESS/24
        dhcp4: false
        gateway4: 192.168.122.1
        match:
            macaddress: $MAC_ADDRESS
        nameservers:
            addresses:
            - 1.1.1.1
            - 8.8.8.8
        set-name: $INTERFACE
version: 2
EOF

    # Configure cloud machine
    cat >${VMS_DIR}/${VM_NAME}/user-data <<EOF
#cloud-config
hostname: ${VM_NAME}
manage_etc_hosts: true
users:
  - name: ${USERNAME}
    ssh_authorized_keys:
      - ${SSH_PUB_KEY} 
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/${USERNAME}
    shell: /bin/bash
    lock_passwd: false
    password: ${PASSWORD}
ssh_pwauth: true
disable_root: false
chpasswd:
  list: |
    ${USERNAME}:${PASSWORD}
  expire: false
EOF

    touch ${VMS_DIR}/${VM_NAME}/meta-data
    cloud-localds \
        -v \
        --network-config=${VMS_DIR}/${VM_NAME}/network-config \
        ${VMS_DIR}/${VM_NAME}/${VM_NAME}-seed.qcow2 \
        ${VMS_DIR}/${VM_NAME}/user-data \
        ${VMS_DIR}/${VM_NAME}/meta-data \
        &>/dev/null 
    printf "Done!\n"

    # Create the machine
    printf "Creating the machine... "
    MEM=$(($VM_RAM * 1024))
    virt-install \
        --connect qemu:///${SESSION_NAME} \
        --virt-type kvm \
        --name ${VM_NAME} \
        --ram ${MEM} \
        --vcpus=${VM_CPUS} \
        --os-type linux \
        --os-variant ${OS_VARIANT} \
        --disk path=${VMS_DIR}/${VM_NAME}/${VM_NAME}.qcow2,device=disk \
        --disk path=${VMS_DIR}/${VM_NAME}/${VM_NAME}-seed.qcow2,device=disk \
        --import \
        --network bridge=virbr0,model=virtio,mac=$MAC_ADDRESS \
        --noautoconsole \
        &>/dev/null 
        # --network network=default,model=virtio,mac=$MAC_ADDRESS \
    printf "Done!\n"

    echo "{
    \"config\": {
        \"connection\": \"${SESSION_NAME}\",
        \"machine\": {
            \"name\": \"${VM_NAME}\",
            \"distro\": \"${DISTRO}\",
            \"username\": \"${USERNAME}\",
            \"password\": \"${PASSWORD}\"
        },
        \"network\": {
            \"mac_address\": \"${MAC_ADDRESS}\",
            \"ip_address\": \"${IP_ADDRESS}\"
        }
    }
}" > ${VMS_DIR}/${VM_NAME}/${APP_NAME}.json
    
}

# Destroys a machine
function destroy_machine() {
    # Set machine name to default if not specified
    if [ $# = 2 ]; then
        VM_NAME=$2
    fi
    printf "Destroying machine '${VM_NAME}'... "
    if [ -d ${VMS_DIR}/${VM_NAME} ]; then
        virsh --connect=qemu:///${SESSION_NAME} destroy ${VM_NAME} &>/dev/null
        virsh --connect=qemu:///${SESSION_NAME} undefine ${VM_NAME} &>/dev/null
        get_machine_ip $VM_NAME
        ssh-keygen -R "${IP_ADDRESS}" &>/dev/null
        rm -rf ${VMS_DIR}/${VM_NAME} 
        printf "Done!\n"
    else
        printf "Failed!\n"
        printf "The machine '${VM_NAME}' does not exist.\n"
    fi
}

# Manages images
function image() {
    if (( $# < 2  || $# > 3 )); then
        show_help image
        exit
    fi
    while (( $# > 1 )); do
        case "$2" in 
            (list)
                echo "Available images to download:"
                for distro in ${DISTRO_LIST[@]}; do
                    echo "  $distro"
                done
                shift
            ;;
            (download)
                if (( $# == 2 )); then
                    show_help image
                fi
                DISTRO="$3"
                download_image 
                shift
            ;;
            (*)
                shift
            ;;
        esac
    done
    
}

# Lists all created machines
function list_machines() {
    echo "List of ${APP_NAME} machines"
    printf "%-20s\t%-20s\t%-20s\t%-20s\n" "Name" "IP" "Status" "Distro"
    # Fix for empty directory when no machines are created
    shopt -s nullglob
    for m in ${VMS_DIR}/*/; do
        local vm_info=$(cat $m/${APP_NAME}.json)
        local vm_name=$(echo $vm_info | jq -r '.config.machine.name')
        local vm_ip=$(echo $vm_info | jq -r '.config.network.ip_address')
        local vm_variant=$(echo $vm_info | jq -r '.config.machine.distro')
        local status=$(virsh list --all | sed  '1,2d' | grep $vm_name | awk '{a=match($0, $3); print substr($0,a)}')
        if [ "$status" != "running" ]; then
            status="off"
        fi
        printf "%-20s\t%-20s\t%-20s\t%-20s\t%-20s\n" $vm_name $vm_ip $status $vm_variant
    done
}

# Shells into a machine
function shell_machine() {
    # Set machine name to default if not specified
    if [ $# == 2 ]; then
        VM_NAME=$2
    fi
    get_machine_ip $VM_NAME
    get_machine_username $VM_NAME

    ssh -o StrictHostKeyChecking=no -i ${VMS_DIR}/${VM_NAME}/id_rsa ${USERNAME}@${IP_ADDRESS}
}

# Start the machine
function start_machine() {
    # Set machine name to default if not specified
    if [ $# = 2 ]; then
        VM_NAME=$2
    fi

    printf "Starting machine '${VM_NAME}'... "
    if [ -d ${VMS_DIR}/${VM_NAME} ]; then
        virsh --connect=qemu:///${SESSION_NAME} start ${VM_NAME} &>/dev/null
        printf "Done!\n"
    else
        printf "Failed!\n"
        printf "The machine '${VM_NAME}' does not exist.\n"
    fi
}

# Stop the machine
function stop_machine() {
    # Set machine name to default if not specified
    if [ $# = 2 ]; then
        VM_NAME=$2
    fi

    printf "Stopping machine '${VM_NAME}'... "
    if [ -d ${VMS_DIR}/${VM_NAME} ]; then
        virsh --connect=qemu:///${SESSION_NAME} shutdown ${VM_NAME} &>/dev/null
        printf "Done!\n"
    else
        printf "Failed!\n"
        printf "The machine '${VM_NAME}' does not exist.\n"
    fi
}

# Reboot the machine
function reboot_machine() {
    # Set machine name to default if not specified
    if [ $# = 2 ]; then
        VM_NAME=$2
    fi

    printf "Rebooting machine '${VM_NAME}'... "
    if [ -d ${VMS_DIR}/${VM_NAME} ]; then
        virsh --connect=qemu:///${SESSION_NAME} reboot ${VM_NAME} &>/dev/null
        printf "Done!\n"
    else
        printf "Failed!\n"
        printf "The machine '${VM_NAME}' does not exist.\n"
    fi
}

# Gets the IP of the machine
function get_machine_ip(){
    VM_NAME=$1
    IP_ADDRESS=$(cat ${VMS_DIR}/${VM_NAME}/${APP_NAME}.json | jq -r '.config.network.ip_address')
}

# Gets the machine username
function get_machine_username(){
    VM_NAME=$1
    USERNAME=$(cat ${VMS_DIR}/${VM_NAME}/${APP_NAME}.json | jq -r '.config.machine.username')
}

# Creates a machine username
function get_machine_password(){
    VM_NAME=$1
    PASSWORD=$(cat ${VMS_DIR}/${VM_NAME}/${APP_NAME}.json | jq -r '.config.machine.password')
}

function show_version() {
    echo "${APP_NAME}: ${APP_VERSION}"
}

function get_connection(){
    if [ -f ${VMS_DIR}/${VM_NAME}/${APP_NAME}.json ]; then
        SESSION_NAME=$(cat ${VMS_DIR}/${VM_NAME}/${APP_NAME}.json | jq -r '.config.connection')
    fi
}

function main() {
    if (( $# < 1 )); then
        show_help
        return 1
    fi

    get_connection
    while (( $# > 0 )); do
        case "$1" in
            (create)
                create_machine "$@"
                exit
            ;;
            (destroy)
                destroy_machine "$@"
                exit
            ;;
            (help)
                show_help "${2:-0}"
                exit
            ;;
            (image)
                image "$@"
                exit
            ;;
            (list)
                list_machines
                exit
            ;;
            (reboot)
                reboot_machine "$@"
                exit
            ;;
            (shell)
                shell_machine "$@"
                exit
            ;;
            (start)
                start_machine "$@"
                exit
            ;;
            (stop)
                stop_machine "$@"
                exit
            ;;
            (update)
                download_image --force
                exit
            ;;
            (version)
                show_version
                exit
            ;;
            (*)
                show_help
                exit
            ;;
        esac
    done
}

main "$@"
