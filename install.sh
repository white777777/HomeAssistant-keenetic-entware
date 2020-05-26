#!/bin/sh

#Compare the first version and the second version. If the first lower than the second return 0 , or return 1
CompareVersion() {
    fversion_1=`echo $1 | awk -F '.' '{print $1}'`
    fversion_2=`echo $1 | awk -F '.' '{print $2}'`
    fversion_3=`echo $1 | awk -F '.' '{print $3}'`
    sversion_1=`echo $2 | awk -F '.' '{print $1}'`
    sversion_2=`echo $2 | awk -F '.' '{print $2}'`
    sversion_3=`echo $2 | awk -F '.' '{print $3}'`


    if [ $fversion_1 -lt $sversion_1 ]; then
        return 0
    elif [ $fversion_1 -gt $sversion_1 ]; then
        return 1
    fi

    if [ $fversion_2 -lt $sversion_2 ]; then
        return 0
    elif [ $fversion_2 -gt $sversion_2 ]; then
        return 1
    fi

    if [ $fversion_3 -lt $sversion_3 ]; then
        return 0
    elif [ $fversion_3 -gt $sversion_3 ]; then
        return 1
    fi

    return 0
}

#Get into the installation path /root/
cd /root/
currentpath=`pwd`
if [ "$currentpath" != "/root" ]; then
    echo -e "\033[31m ERROR! Cannot get into installation path, exit. \033[0m"
    exit 0
fi

opkg update
opkg install python3-pip gcc python3-dev ffi libsodium 
#opkg install python3-openssl
pip3 install --upgrade pip

OPT=/opt
USR=$OPT/usr
INCLUDE=$OPT/include
PYTHON_INCLUDE=$OPT/include/python3.8

echo -e "\033[32m Install C library......libffi \033[0m"
cp ./ffi* $PYTHON_INCLUDE

echo -e "\033[32m Install C library......libopenssl \033[0m"
cp -r ./openssl $PYTHON_INCLUDE/


echo -e "\033[32m Install C library......libsodium \033[0m"
cp ./sodium.h $PYTHON_INCLUDE/ && \
cp -r ./sodium $PYTHON_INCLUDE

#ln -s $USR/lib/libffi.so.6.0.1 $USR/lib/libffi.so
#ln -s $USR/lib/libcrypto.so.1.0.0 $USR/lib/libcrypto.so && \
#ln -s $USR/lib/libssl.so.1.0.0 $USR/lib/libssl.so
#ln -s /usr/lib/libsodium.so.23.1.0 $USR/lib/libsodium.so

#Install dependent python module

echo -e "\033[33m Install python module: PyNaCl...... try $try. \033[0m"
SODIUM_INSTALL=system pip3 install pynacl

echo -e "\033[33m Download python module: cryptography...... try $try. \033[0m"
curl https://files.pythonhosted.org/packages/07/ca/bc827c5e55918ad223d59d299fff92f3563476c3b00d0a9157d9c0217449/cryptography-2.6.1.tar.gz > cryptography-2.6.1.tar.gz
if [ $? -ne 0 ]; then
    rm ./cryptography-2.6.1.tar.gz
    rm -rf ./.cache/
    continue
else
    break
fi

echo -e "\033[32m Install python module: cryptography...... \033[0m"
tar -xzvf cryptography-2.6.1.tar.gz && \
cd ./cryptography-2.6.1 && \
LDFLAGS=-pthread python3 setup.py install && \
cd ../
if [ $? -ne 0 ]; then
    echo -e "\033[31m ERROR! Install cryptography failed,  exit. \033[0m"
    exit 0
fi
rm -rf ./cryptography-2.6.1*

#Install Home Assistant
echo -e "\033[33m Install HomeAssistant...... try $try. \033[0m"
python3 -m pip install homeassistant
if [ $? -ne 0 ]; then
    rm -rf ./.cache/
    continue
else
    break
fi

#Config the homeassistant
mkdir -p ./.homeassistant
cp ./HomeAssistantOnOPENWRT/configuration/* ./.homeassistant/
#Install finished
echo -e "\033[32m HomeAssistant installation finished. Use command \"hass\" to start the HA. \033[0m"
echo -e "\033[32m Note that the firstly start will take 20~30 minutes. If failed, retry it. \033[0m"
