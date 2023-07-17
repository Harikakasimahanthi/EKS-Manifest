#!/bin/bash

# Function to install AWS CLI on Ubuntu/Debian
install_awscli_debian() {
  echo "Installing AWS CLI on Ubuntu/Debian..."
  sudo apt-get update
  sudo apt-get install -y awscli
}

# Function to install AWS CLI on CentOS/RHEL
install_awscli_rhel() {
  echo "Installing AWS CLI on CentOS/RHEL..."
  sudo yum install -y awscli
}

# Function to install AWS CLI on macOS
install_awscli_macos() {
  echo "Installing AWS CLI on macOS..."
  brew install awscli
}

# Function to install AWS CLI on Windows
install_awscli_windows() {
  echo "Installing AWS CLI on Windows..."
  curl "https://awscli.amazonaws.com/AWSCLIV2.msi" -o "AWSCLIV2.msi"
  msiexec /i AWSCLIV2.msi
  rm AWSCLIV2.msi
}

# Function to install kubectl on Ubuntu/Debian
install_kubectl_debian() {
  echo "Installing kubectl on Ubuntu/Debian..."
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl
}

# Function to install kubectl on CentOS/RHEL
install_kubectl_rhel() {
  echo "Installing kubectl on CentOS/RHEL..."
  sudo yum install -y curl
  sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
}

# Function to install kubectl on macOS
install_kubectl_macos() {
  echo "Installing kubectl on macOS..."
  brew install kubectl
}

# Function to install kubectl on Windows
install_kubectl_windows() {
  echo "Installing kubectl on Windows..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/windows/amd64/kubectl.exe"
  move kubectl.exe C:\Windows\System32
}

# Check if AWS CLI is installed
if ! command -v aws &>/dev/null; then
  echo "AWS CLI not found. Installing AWS CLI..."
  
  # Check the operating system
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux OS
    if [[ -f "/etc/os-release" ]]; then
      # Check if Ubuntu/Debian
      if grep -q "ubuntu\|debian" /etc/os-release; then
        install_awscli_debian
      else
        # Assuming it is CentOS/RHEL
        install_awscli_rhel
      fi
    else
      echo "Unsupported Linux distribution. Please install AWS CLI manually."
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    install_awscli_macos
  elif [[ "$OSTYPE" == "msys" ]]; then
    # Windows
    install_awscli_windows
  else
    echo "Unsupported operating system. Please install AWS CLI manually."
    exit 1
  fi
  
  # Verify AWS CLI installation
  if ! command -v aws &>/dev/null; then
    echo "AWS CLI installation failed. Please check the installation."
    exit 1
  fi
  
  echo "AWS CLI is installed successfully."
else
  echo "AWS CLI is already installed."
  aws --version
fi

# Check if kubectl is installed
if ! command -v kubectl &>/dev/null; then
  echo "kubectl not found. Installing kubectl..."
  
  # Check the operating system
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux OS
    if [[ -f "/etc/os-release" ]]; then
      # Check if Ubuntu/Debian
      if grep -q "ubuntu\|debian" /etc/os-release; then
        install_kubectl_debian
      else
        # Assuming it is CentOS/RHEL
        install_kubectl_rhel
      fi
    else
      echo "Unsupported Linux distribution. Please install kubectl manually."
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    install_kubectl_macos
  elif [[ "$OSTYPE" == "msys" ]]; then
    # Windows
    install_kubectl_windows
  else
    echo "Unsupported operating system. Please install kubectl manually."
    exit 1
  fi
  
  # Verify kubectl installation
  if ! command -v kubectl &>/dev/null; then
    echo "kubectl installation failed. Please check the installation."
    exit 1
  fi
  
  echo "kubectl is installed successfully."
else
  echo "kubectl is already installed."
  kubectl version --client
fi

# Check if kubectl can access the cluster
if ! kubectl cluster-info &>/dev/null; then
  echo "Unable to access Kubernetes cluster. Please configure kubectl properly."
  exit 1
fi

# Check if pods are running before applying deployments
echo "Running pods before applying deployments:"
kubectl get pods -A

# Change to the downloads directory
cd ~/Downloads

# Apply deployments
kubectl apply -f prysmconfig.yaml
kubectl apply -f prysmbeacon2.yaml

# Check if pods are running after applying deployments
echo "Running pods after applying deployments:"
kubectl get pods -A

# Read the Prysm deployment name from user input
read -p "Enter the Prysm deployment name: " prysm_deployment_name

# Display logs
kubectl logs "$prysm_deployment_name" 