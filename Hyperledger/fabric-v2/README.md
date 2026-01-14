# Hyperledger Fabric

## 1. 安装
```sh
# 依赖
yum install jq git 
# 以及安装golang docker docker-compose java11

# 安装脚本
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh

# 安装
bash ./install-fabric.sh --fabric-version 2.5.7 docker samples binary
# 把bin目录加入环境变量PATH中

# 拉例子代码
wget http://github.com/hyperledger/fabric-samples/archive/refs/heads/main.zip
unzip main.zip
mv bin/ fabric-samples/bin
mv config/ fabric-samples/config

# 修改gradle项目源
# 设置fabric-samples/asset-transfer-basic/chaincode-java/gradle/wrapper/gradle-wrapper.properties里distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-7.6.6-bin.zip
# 设置fabric-samples/asset-transfer-basic/chaincode-java/gradle.properties里org.gradle.java.home=/usr/lib/jvm/java-11-openjdk-11.0.27.6-1.oe2403.x86_64
# 修改build.gradle为jdk11+gradle插件7.1.2(见build.gradle)

# 启动网络
cd fabric-samples/test-network
chmod +x organizations/*.sh
chmod +x scripts/*.sh
sh network.sh up createChannel
sh network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java

# 关停网络
sh network.sh down
docker volume prune -a
```

## 2. 交互
```sh
# Org1MSP
## 变量
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

## 初始化
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'

## 查询
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

## 改变资产所有者
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}'

# Org2MSP
## 变量2
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

## 查询
peer chaincode query -C mychannel -n basic -c '{"Args":["ReadAsset","asset6"]}'
```

## 3. 将链码作为外部服务
```sh
# 1）设置外部builder和launcher
vi fabric-samples/config/core.yaml
externalBuilders:
    - path: /opt/gopath/src/github.com/hyperledger/fabric-samples/asset-transfer-basic/chaincode-external/sampleBuilder
      name: external-sample-builder

# 2）挂载例子、配置
vi fabric-samples/test-network/compose/docker/docker-compose-test-net.yaml
# 每个peer的volumes下面增加
- ../..:/opt/gopath/src/github.com/hyperledger/fabric-samples
- ../../config/core.yaml:/etc/hyperledger/peercfg/core.yaml
# 注释掉- /var/run/docker.sock:/host/var/run/docker.sock

# 3）打包安装链码
chmod +x fabric-samples/asset-transfer-basic/chaincode-external/sampleBuilder/bin/*
cd fabric-samples/asset-transfer-basic/chaincode-external
tar cfz code.tar.gz connection.json
tar cfz asset-transfer-basic-external.tgz metadata.json code.tar.gz

# 4）启动测试网络
cd fabric-samples/test-network
./network.sh up createChannel -c mychannel -ca

# 5）安装外部链码
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
. ./scripts/envVar.sh

# 6）安装package
setGlobals 1
peer lifecycle chaincode install ../asset-transfer-basic/chaincode-external/asset-transfer-basic-external.tgz

setGlobals 2
peer lifecycle chaincode install ../asset-transfer-basic/chaincode-external/asset-transfer-basic-external.tgz

# 7）查询package ID
setGlobals 1
peer lifecycle chaincode queryinstalled --peerAddresses localhost:7051 --tlsRootCertFiles organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CHAINCODE_ID=basic_1.0:bdbbfbd79b4d3940c76894ecfe83474039fe0c8de158f5d2c634f81d7cb5f39f

# 8）运行外部服务
# 8.1）golang服务
cd fabric-samples/asset-transfer-basic/chaincode-external
docker build -t hyperledger/asset-transfer-basic .
docker run -it --rm --name asset-transfer-basic.org1.example.com --hostname asset-transfer-basic.org1.example.com --env-file chaincode.env --network=fabric_test hyperledger/asset-transfer-basic

# 8.2）java服务
cd fabric-samples/asset-transfer-basic/chaincode-java
# 放入chaincode.env
vi chaincode.env
CHAINCODE_ID=basic_1.0:bdbbfbd79b4d3940c76894ecfe83474039fe0c8de158f5d2c634f81d7cb5f39f
CORE_CHAINCODE_ID_NAME=basic_1.0:bdbbfbd79b4d3940c76894ecfe83474039fe0c8de158f5d2c634f81d7cb5f39f
# 重写Dockerfile和docker/docker-entrypoint.sh
# 修改build.gradle
# 打包
docker build -t chaincode:java .
# 运行
docker run -it --rm --name asset-transfer-basic.org1.example.com --hostname asset-transfer-basic.org1.example.com --env-file chaincode.env --network=fabric_test chaincode:java

# 9）部署外部链码定义到channel
setGlobals 2
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --channelID mychannel --name basic --version 1.0 --package-id $CHAINCODE_ID --sequence 1

setGlobals 1
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --channelID mychannel --name basic --version 1.0 --package-id $CHAINCODE_ID --sequence 1

peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --channelID mychannel --name basic --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --version 1.0 --sequence 1

# 10）使用外部链码
cd fabric-samples/asset-transfer-basic/application-gateway-go
go run .

# 11）开启TLS(链码/peer通信)
openssl req -nodes -x509 -newkey rsa:4096 -keyout crypto/key1.pem -out crypto/cert1.pem -subj "/C=IN/ST=KA/L=Bangalore/O=example Inc/OU=Developer/CN=asset-transfer-basic.org1.example.com/emailAddress=dev@asset-transfer-basic.org1.example.com"

openssl req -nodes -x509 -newkey rsa:4096 -keyout crypto/key2.pem -out crypto/cert2.pem -subj "/C=IN/ST=KA/L=Bangalore/O=example Inc/OU=Developer/CN=asset-transfer-basic.org2.example.com/emailAddress=dev@asset-transfer-basic.org2.example.com"

cp ../../test-network/organizations/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem crypto/rootcert1.pem
cp ../../test-network/organizations/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem crypto/rootcert2.pem

# 修改connection.json的root_cert
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto/cert1.pem
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto/cert2.pem
# 修改client_key和client_cert
{
  "address": "asset-transfer-basic.org1.example.com:9999",
  "dial_timeout": "10s",
  "tls_required": true,
  "client_auth_required": true,
  "client_key": "-----BEGIN PRIVATE KEY----- ... -----END PRIVATE KEY-----",
  "client_cert": "-----BEGIN CERTIFICATE---- ... -----END CERTIFICATE-----",
  "root_cert": "-----BEGIN CERTIFICATE---- ... -----END CERTIFICATE-----"
}
# CHAINCODE_ID写入chaincode1.env和chaincode2.env

docker-compose up -f docker-compose-chaincode.yaml up --build -d
```