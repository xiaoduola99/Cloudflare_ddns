# Cloudflare_ddns
Cloudflare的动态域名解析脚本支持v4和v6
### 使用方法
1.打开命令窗口，下载脚本：
```shell
wget https://github.com/xiaoduola99/Cloudflare_ddns/releases/download/v1.0/Cloudflare_ddns.sh
sudo chmod 775 /home/ddns/Cloudflare_ddns.sh       #目录根据实际用户等进行更改
```
2.对脚本内的个人配置信息进行更改，目录记得和上一条命令保持一致。
```shell
sudo vi /home/ddns/Cloudflare_ddns.sh     #目录根据实际用户等进行更改
```
找到如下内容进行更改。
```shell
auth_email="admin@gmail.com"    #你的CloudFlare注册账户邮箱
auth_key="652p4q8x8jk6fmeoazvxrzkptzdd729q"   #你的CloudFlare账户Globel ID
zone_name="google.com"     #你的主域名
record_name="photos.google.com"    #你需要的完整的DDNS解析域名
record_type="AAAA"             #A或AAAA及ipv4或ipv6解析
ip_index="local"     #internet 或 local,通过网络获取 或 本地网卡获取ip
#信息必填区
####################################################################################
ipv4_api="ipv4.icanhazip.com"     #备用ipv4 api：ipv4.icanhazip.com，api.ipify.org
ipv6_api="api6.ipify.org"    #备用ipv6 api：ipv6.icanhazip.com，api6.ipify.org
#信息选填区     网络获取ip地址的api
####################################################################################
```
**必填区是必须要填写的**
以要动态解析”photos.google.com“这个域名为例，zone_name填写`google.com`,record_name填写`photos，google.com`更改完成后，保存退出。
**选填区是可填可不填的**
选填区是`网络`解析ip所用到api，你可以找一个你认为快的api填写上去，让解析速度变得更快。


在命令行中输入以下内容运行脚本：
```shell
bash /home/ddns/Cloudflare_ddns.sh     #目录根据实际用户等进行更改
```
**定时运行脚本**
为了能一直解析新的ip，必须让脚本每隔几分钟运行一下，所以使用系统的定时任务来让脚本自动运行，输入`crontab -e`进入系统定时任务。
```
*/5 * * * *  /home/ddns/Cloudflare_ddns.sh >/dev/null 2>&1    #目录根据实际用户等进行更改
```
**感谢**:本脚本参考 [wherelse的树莓派IPV6 DDNS解决方案](https://github.com/wherelse/cloudflare-ddns-script) 


```
**感谢**:本脚本参考 [wherelse的树莓派IPV6 DDNS解决方案](https://github.com/wherelse/cloudflare-ddns-script) 
