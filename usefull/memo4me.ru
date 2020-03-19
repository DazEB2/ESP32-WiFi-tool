# --------------------------------------------------------------------------------------
# ��������� docker off-line  https://docs.docker.com/install/linux/docker-ce/ubuntu/ ------
# �������� ���� gpg � ������ �� �����������
cat docker.gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo dpkg -i docker-ce_19.03.5_3-0_ubuntu-bionic_amd64.deb 
sudo dpkg -i docker-ce-cli_19.03.5_3-0_ubuntu-bionic_amd64.deb 
sudo dpkg -i containerd.io_1.2.6-3_amd64.deb 
sudo /usr/sbin/service docker start
sudo systemctl status docker.socket
sudo docker version
sudo docker info
sudo systemctl status docker.socket

docker images
docker pa -a

# ��� �� �� ��������� ������ ��� sudo ��� ������������� docker
sudo groupadd docker
sudo usermod -aG docker $USER

# --------------------------------------------------------------------------------------
# ���������� samba ��� ����������� ������� � Windows � VM 
sudo docker load -i dperson_samba.tar
# ������� ��� ���������� �������:                              
sudo docker run -it --name samba -p 139:139 -p 445:445 -v /home/mm:/mount --name samba -e USERID=`id -u $USER` -e GROUPID=`id -g $USER` -d dperson/samba -s "public;/mount;yes;no;yes;all"
# ������� ��� ������� �� ������:
sudo docker run -it --name samba -p 139:139 -p 445:445 -v /home/mm:/mount --name samba -e USERID=`id -u $USER` -e GROUPID=`id -g $USER` -d dperson/samba -u "$USER;$USER" -s "public;/mount;yes;no;no;$USER"

# --------------------------------------------------------------------------------------
sudo docker load -i espressif_idf.tar
# ������ cmake 
docker run --rm --user=`id -u $USER`:`id -g $USER` -v $HOME/project:/project -w /project espressif/idf idf.py build
docker run --rm --user=`id -u $USER`:`id -g $USER` -v $HOME/project:/project -w /project espressif/idf idf.py --version

# ����� make (deprecated)
docker run --rm -v $HOME/project:/project -w /project espressif/idf make defconfig all

# ��� ��������� ���������� � ��� ���� ������ �� ���������/�������� ����������
docker run --name esp32 --user=`id -u $USER`:`id -g $USER` -v $HOME/project:/project -w /project espressif/idf idf.py build
docker start -ai esp32

# --------------------------------------------------------------------------------------
# �������� ESP32 (Windows) python3
pip install pyserial-3.4-py2.py3-none-any.whl
pip install ecdsa-0.14.1-py2.py3-none-any.whl
# ���������� esptool (setup.py)

# �������� ���������� � �����
esptool.py --port COM4 flash_id

# ������ ��������
esptool.py -p COM4 -b 460800 --before default_reset --after hard_reset --chip esp32  write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x1000 bootloader/bootloader.bin 0x8000 partition_table/partition-table.bin 0x10000 hello-world.bin
esptool.py -p COM4 -b 460800 --before default_reset --after hard_reset --chip esp32  write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x1000 build/bootloader/bootloader.bin 0x8000 build/partition_table/partition-table.bin 0x10000 build/blink.bin

# --------------------------------------------------------------------------------------
# ���������� �����. ������������ ������ �� ������������ idf. ������ ��� ����������� COM ����� ��� �������.
monitor.py --port COM4

# --------------------------------------------------------------------------------------
# ���������� ������ *.h ��� ������ Visual Studio Code
# include �������� ����������� ������ �� docker ������ espressif/idf
# include.txt - ��� ����������� ������ ��� c_cpp_properties.json "includePath"
cd $HOME
docker create --name idf4vsc --user=`id -u $USER`:`id -g $USER` -v $HOME/project:/project -w /project espressif/idf
docker export idf4vsc > $HOME/idf4vsc.tar
docker rm idf4vsc
rm -R $HOME/idf
mkdir $HOME/idf
cd $HOME/idf
tar xvf ../idf4vsc.tar opt/esp/idf/components
tar xvf ../idf4vsc.tar opt/esp/tools/xtensa-esp32-elf/esp-2019r2-8.2.0/xtensa-esp32-elf/xtensa-esp32-elf/include
tar xvf ../idf4vsc.tar opt/esp/tools/xtensa-esp32-elf/esp-2019r2-8.2.0/xtensa-esp32-elf/lib/gcc/xtensa-esp32-elf/8.2.0/include
cd $HOME
find $HOME/idf/opt/esp/idf/components -type f ! -name '*.h' -delete
find $HOME/idf/opt/esp/idf/components -type d -empty -delete
find $HOME/idf/opt/esp -type d | grep 'include$' | sed 's/\/home\/'$USER'/"${workspaceRoot}\/../' | sed 's/$/",/' > include.txt

cd 
tar --exclude "./.deleted" --exclude "./.*" -cvf $USER.tar . 


# --------------------------------------------------------------------------------------
# ��� �� ���������� libnet80211.a/ieee80211_output.o
# --------------------------------------------------------------------------------------

# ������� ieee80211_output.o (Cutter-v1.10.0-x64.Windows.zip)

rm -R $HOME/libnet80211_src
mkdir $HOME/libnet80211_src
docker run --rm --user=`id -u $USER`:`id -g $USER` -v $HOME/libnet80211_src:/project -w /project espressif/idf ar x /opt/esp/idf/components/esp_wifi/lib/esp32/libnet80211.a ieee80211_output.o


# ������ ���������� � ����������� ieee80211_output.o

docker run --rm -v $HOME/project:/project -w /project espressif/idf ./build_patched.sh
