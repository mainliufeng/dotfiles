## download zip
# git clone git@github.com:XX-net/XX-Net.git 3.1.19
# 
cp ~/Software/XX-Net-3.1.19.zip $XXNET_HOME

cd $XXNET_HOME

## unzip
echo "A" | unzip -q XX-Net-3.1.19.zip

## link
ln -svf XX-Net-3.1.19 current

# copy config
mkdir -p $XXNET_HOME/current/data/gae_proxy/
cp -f ~/dotfiles/tools/xxnet/resources/config.ini $XXNET_HOME/current/data/gae_proxy/
