#!/bin/bash

# Script to patch Vagrant configuration and Ansible files
# Exit on error
set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Check if files exist
check_file() {
    if [ ! -f "$1" ]; then
        log_error "File $1 not found!"
    fi
}

# Check if directories exist
check_directory() {
    if [ ! -d "$1" ]; then
        log_info "Directory $1 does not exist. Creating it..."
        mkdir -p "$1" || log_error "Failed to create directory $1"
    fi
}

# Main function to patch Vagrantfile
patch_vagrantfile() {
    log_info "Checking Vagrantfile..."
    check_file "Vagrantfile"
    
    # Create backup
    cp Vagrantfile Vagrantfile.bak || log_error "Failed to create backup of Vagrantfile"
    log_success "Created backup at Vagrantfile.bak"
    
    # Check if ansible galaxy configuration already exists
    if grep -q "ansible.galaxy_role_file = \"provisioning/requirements.yml\"" Vagrantfile; then
        log_info "Ansible galaxy configuration already exists in Vagrantfile, skipping"
    else
        # Add ansible galaxy configuration
        log_info "Adding ansible galaxy configuration..."
        sed -i '/device\.vm\.provision "ansible_local" do |ansible|/,/ansible\.limit = /s/ansible\.limit = .*/&\n      ansible.galaxy_role_file = "provisioning\/requirements.yml"\n      ansible.galaxy_roles_path = "provisioning\/roles"\n      ansible.galaxy_command = "sudo ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --force"/' Vagrantfile
        
        # Verify the change was applied
        if grep -q "ansible.galaxy_role_file = \"provisioning/requirements.yml\"" Vagrantfile; then
            log_success "Ansible galaxy configuration added to Vagrantfile"
        else
            log_error "Failed to add ansible galaxy configuration to Vagrantfile"
        fi
    fi
    
    # Check and set boot timeout
    if grep -q "config.vm.boot_timeout = 9999" Vagrantfile; then
        log_info "Boot timeout already set to 9999"
    else
        log_info "Setting boot timeout to 9999..."
        sed -i '/Vagrant.configure.*do |config|/a \  config.vm.boot_timeout = 9999' Vagrantfile
        log_success "Added boot timeout configuration"
    fi
    
    # Update rsync exclude list
    if grep -q 'rsync__exclude:.*topology.yml' Vagrantfile; then
        log_info "rsync exclude list already updated"
    else
        log_info "Updating rsync exclude list..."
        # Use Ruby syntax-aware replacement
        sed -i -E '/rsync__exclude:/ {
            s/"\.git\/"/[".git\/", "topology.yml", "patch.sh", "training.json"]/
            s/: "([^"]*)"/: \1/  # Remove quotes if present around string
        }' Vagrantfile
        
        # Final verification
        if ruby -e 'File.read("Vagrantfile") =~ /rsync__exclude:\s*\[.*topology.yml.*\]/ ? exit(0) : exit(1)' ; then
            log_success "rsync exclusions updated with array syntax"
        else
            log_error "Failed to update rsync exclusions - manual edit required"
        fi
    fi
}

# Create required directories and files
setup_directories_and_files() {
    # Check and create provisioning directory
    check_directory "provisioning"
    
    # Create empty files if they don't exist
    for file in "provisioning/requirements.yml" "training.json"; do
        if [ ! -f "$file" ]; then
            touch "$file" || log_error "Failed to create $file"
            log_success "Created $file"
        else
            log_info "File $file already exists, skipping"
        fi
    done
}

# Main execution
echo "=== Starting Vagrant/Ansible patch script ==="
patch_vagrantfile

echo "=== Patch completed successfully ==="