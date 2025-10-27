sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl status docker
nano Dockerfile
docker build -t docker4191/wisecow:latest .
docker ps
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker
# Add your user to the docker group
sudo usermod -aG docker $USER
docker ps
logout
