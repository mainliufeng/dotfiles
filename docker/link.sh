sudo mkdir -p /etc/systemd/system/docker.service.d
sudo cp ~/dotfiles/docker/http-proxy.conf /etc/systemd/system/docker.service.d/http-proxy.conf

sudo systemctl daemon-reload
sudo systemctl restart docker
