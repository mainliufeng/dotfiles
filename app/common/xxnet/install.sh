mkdir -p $XXNET_HOME

cd $XXNET_HOME

## download zip
git clone https://github.com/XX-net/XX-Net 3.1.19

## unzip
echo "A" | unzip -q XX-Net-3.1.19.zip

## link
ln -svf XX-Net-3.1.19 current

# copy config
mkdir -p $XXNET_HOME/current/data/gae_proxy/
cp -f ~/dotfiles/tools/xxnet/resources/config.ini $XXNET_HOME/current/data/gae_proxy/
