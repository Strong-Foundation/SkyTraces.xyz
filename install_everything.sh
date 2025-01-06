#!/bin/bash

# Check if the script is running as root
function check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: This script must be run as root."
        exit 1
    fi
}

# Call the function to check root privileges
check_root

# Function to gather current system details
function system-information() {
    # This function fetches the ID, version, and major version of the current system
    if [ -f /etc/os-release ]; then
        # If /etc/os-release file is present, source it to obtain system details
        # shellcheck source=/dev/null
        source /etc/os-release
        CURRENT_DISTRO=${ID} # CURRENT_DISTRO holds the system's ID
    fi
}

# Invoke the system-information function
system-information

# Define a function to check system requirements
function installing_system_requirements() {
    # Check if the current Linux distribution is supported
    if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ]; }; then
        # Check if required packages are already installed
        if { [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v cut)" ]; }; then
            # Install required packages depending on the Linux distribution
            if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ]; }; then
                apt-get update
                apt-get install curl coreutils -y
            fi
        fi
    else
        echo "Error: Your current distribution ${CURRENT_DISTRO} is not supported by this script. Please consider updating your distribution or using a supported one."
        exit
    fi
}

# Call the function to check for system requirements and install necessary packages if needed
installing_system_requirements

# The following function checks if there's enough disk space to proceed with the installation.
function check_disk_space() {
    # This function checks if there is more than 1 GB of free space on the drive.
    FREE_SPACE_ON_DRIVE_IN_MB=$(df -m / | tr --squeeze-repeats " " | tail -n1 | cut --delimiter=" " --fields=4)
    # This line calculates the available free space on the root partition in MB.
    if [ "${FREE_SPACE_ON_DRIVE_IN_MB}" -le 10240 ]; then
        # If the available free space is less than or equal to 10240 MB (10 GB), display an error message and exit.
        echo "Error: You need more than 10 GB of free space to install everything. Please free up some space and try again."
        exit
    fi
}

check_disk_space
# Calls the check_disk_space function.

# sudo apt-get install rtl-sdr -y