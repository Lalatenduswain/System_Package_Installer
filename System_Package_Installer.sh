#!/bin/bash
# Author: Lalatendu Swain
# License: MIT

# Function to check if a package is installed
check_installed() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "$1 is already installed."
        return 0
    else
        return 1
    fi
}

# Function to check the version of a package
check_version() {
  local package=$1
  local version=$(dpkg -l | grep "^ii  $package" | awk '{print $3}')
  if [ -z "$version" ]; then
    echo "$package | Not installed"
  else
    echo "$package | $version"
  fi
}

# Function to install Cloudflared
install_cloudflared() {
    echo "Downloading and installing Cloudflared..."
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    if dpkg -i cloudflared.deb; then
        echo "Cloudflared installed successfully."
    else
        echo "Failed to install Cloudflared. Fixing dependencies and retrying..."
        apt --fix-broken install -y
        dpkg -i cloudflared.deb
        if [ $? -eq 0 ]; then
            echo "Cloudflared installed successfully after fixing dependencies."
        else
            echo "Failed to install Cloudflared. Exiting."
            exit 1
        fi
    fi
    rm -f cloudflared.deb
}

# Function to install Tailscale
install_tailscale() {
    echo "Downloading and installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
    if [ $? -eq 0 ]; then
        echo "Tailscale installed successfully."
    else
        echo "Failed to install Tailscale. Exiting."
        exit 1
    fi
}

# Function to handle package installation
install_package() {
  local package=$1
  if ! dpkg -l | grep -q "^ii  $package"; then
    echo "$package is not installed. Installing $package..."
    apt install -y $package
  else
    echo "$package is already installed."
  fi
}

# Updating package lists
echo "Updating package lists..."
apt update

# Checking installed versions
echo "Checking installed versions:"
echo "| Package    | Version |"
echo "|------------|---------|"

# List of packages to check
packages=("cloudflared" "tailscale" "postfix" "mailutils" "nload" "net-tools" "libsasl2-modules" "htop" "xsensors")

# Loop through packages and check versions
for pkg in "${packages[@]}"; do
  check_version $pkg
done

# Options to install packages
echo ""
echo "Select packages to install:"
echo "1) Cloudflared"
echo "2) Tailscale"
echo "3) htop"
echo "4) xsensors"
echo "5) nload"
echo "6) net-tools"
echo "7) libsasl2-modules"
echo "8) mailutils"
echo "9) postfix"
echo "10) All"
echo "0) Exit"
read -p "Enter choice (1/2/3/4/5/6/7/8/9/10/0): " choice

# Handling exit option
if [ "$choice" -eq 0 ]; then
    echo "Exiting the script."
    exit 0
fi

# Handling installation logic based on choice
case $choice in
  1)
    install_cloudflared
    ;;
  2)
    install_tailscale
    ;;
  3)
    install_package "htop"
    ;;
  4)
    install_package "xsensors"
    ;;
  5)
    install_package "nload"
    ;;
  6)
    install_package "net-tools"
    ;;
  7)
    install_package "libsasl2-modules"
    ;;
  8)
    install_package "mailutils"
    ;;
  9)
    install_package "postfix"
    ;;
  10)
    for pkg in "${packages[@]:0:9}"; do
      install_package $pkg
    done
    ;;
  *)
    echo "Invalid choice. Please select a valid option."
    ;;
esac

# Final message
echo "Installation completed. You can now configure selected packages as needed."
