#!/bin/bash
#/*请先在CloudFlare上面解析一个你需要DDNS的记录,ip随便填写一个就行,否则将会报错*/
#/*如果你要更换DDNS域名或者没在CloudFlare添加解析就运行了脚本,请先删除cloudflare_ddns.ids这个文件后重新运行*/
#/*本地网卡获取ip是查看你网卡获取的ip,如果你连接的有路由器并且网卡获取的ip是内网的,请使用网络获取方式*/
auth_email="admin@gmail.com"    #你的CloudFlare注册账户邮箱
auth_key="652p4q8x8jk6fmeoazvxrzkptzdd729q"   #你的CloudFlare账户Globel ID
zone_name="google.com"     #你的主域名
record_name="photos.google.com"    #你需要的完整的DDNS解析域名
record_type="AAAA"             #A或AAAA及ipv4或ipv6解析
proxied_flag="true" #是否启动代理
ip_index="local"     #internet 或 local,通过网络获取 或 本地网卡获取ip
#信息必填区
####################################################################################
ipv4_api="ipv4.icanhazip.com"     #备用ipv4 api：ipv4.icanhazip.com，api.ipify.org
ipv6_api="api6.ipify.org"    #备用ipv6 api：ipv6.icanhazip.com，api6.ipify.org
#信息选填区     网络获取ip地址的api
####################################################################################
ip_file="ip.txt"                       #保存ip地址信息
id_file="cloudflare_ddns.ids"          #保存主域名和需要解析域名的ID
log_file="cloudflare_ddns.log"         #保存运行日志
# 日志
log() {
    if [ "$1" ]; then
        echo -e "[$(date)] - $1" >> $log_file
    fi
}
#获取域名和授权
if [ -f $id_file ] && [ $(wc -l $id_file | cut -d " " -f 1) == 2 ]; then
    zone_identifier=$(head -1 $id_file)
    record_identifier=$(tail -1 $id_file)
else
    zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
    record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json"  | grep -Po '(?<="id":")[^"]*' | head -1 )
    echo "$zone_identifier" > $id_file
    if [ $zone_identifier == $(head -1 $id_file) ] && [ -n "$zone_identifier" ]; then
        echo "获取zone_id成功!"
         log "获取zone_id成功!"
    else 
         echo "获取zone_id失败!请检查网络和Globel ID是否正确并删除cloudflare_ddns.ids文件后从新运行."
         log "获取zone_id失败!请检查网络和Globel ID是否正确并删除cloudflare_ddns.ids文件后从新运行."
         exit
    fi
    echo "$record_identifier" >> $id_file
    if [ $record_identifier == $(tail -1 $id_file) ] && [ -n "$record_identifier" ]; then
         echo "获取record_id成功!"
         log "获取record_id成功!"
         echo "第一次运行,无上次IP." > $ip_file
         echo "创建ip.txt文件成功!"
    else 
         echo "获取record_id失败!请检查网络和Globel ID是否正确并删除cloudflare_ddns.ids文件后从新运行."
         log "获取record_id失败!请检查网络和Globel ID是否正确并删除cloudflare_ddns.ids文件后从新运行."
         exit
    fi
    
fi
# 判断是A记录还是AAAA记录
if [ $record_type = "A" ];then
    if [ $ip_index = "internet" ];then
        ip=$(curl -s $ipv4_api)
        echo "网络获取IPV4成功!IP:$ip"
        log "网络获取IPV4成功!IP:$ip"
    elif [ $ip_index = "local" ];then
        ip=$(/sbin/ifconfig $eth_card | grep 'inet'| grep -v '127.0.0.1' | grep -v 'inet6'|cut -f2 | awk '{ print $2}' | head -1)
         if [ -n "$ip" ];then
         echo "本地获取IPV4成功!IP:$ip"
         log "本地获取IPV4成功!IP:$ip"
         else 
         echo "IP获取错误,请输入正确的获取方式!"
         log "IP获取错误,请输入正确的获取方式!"
         exit
         fi
    fi
elif [ $record_type = "AAAA" ];then
    if [ $ip_index = "internet" ];then
        ip=$(curl -s $ipv6_api)
        echo "网络获取IPV6成功!IP:$ip"
        log "网络获取IPV6成功!IP:$ip"
    elif [ $ip_index = "local" ];then
       ip=$(/sbin/ifconfig $eth_card | grep 'inet6'| grep -v '::1'|grep -v 'fe80' | cut -f2 | awk '{ print $2}' | tail -1)
         if [ -n "$ip" ];then
         echo "本地获取IPV6成功!IP:$ip"
         log "本地获取IPV6成功!IP:$ip"
         else 
         echo "IP获取错误,请输入正确的获取方式!"
         log "IP获取错误,请输入正确的获取方式!"
        exit
        fi
    fi
else
    echo "DNS类型错误!"
    log "DNS类型错误!"
    exit
fi
# 检查开始
log "检查中!"
#判断ip是否发生变化
if [ -f $ip_file ]; then
    old_ip=$(cat $ip_file)
    if [ $ip == $old_ip ]; then
        echo "IP没有更改!"
        log "IP没有更改!"
        log "----------------------------------------------------------------------"
        exit
    fi
fi
#更新DNS记录
update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" --data "{\"type\":\"$record_type\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":120,\"proxied\":$proxied_flag}")
#反馈更新情况
if [ "$update" != "${update%success*}" ] && [ "$(echo $update | grep "\"success\":true")" != "" ]; then
  echo "更新成功啦!"
  echo "上次IP:$(cat $ip_file)"
  echo "本次IP:$ip"
  log "更新成功啦!"
  log "上次IP:$(cat $ip_file)"
  log "本次IP:$ip"
  log "----------------------------------------------------------------------"
  echo $ip > $ip_file
  exit
else
  echo '更新失败啦!回复为空请检查网络,回复为1001获取record_id失败,回复7000获取zone_id失败.'
  echo "回复: $update"
  log "更新失败啦!"
  log "回复: $update"
  log "----------------------------------------------------------------------"
  exit
fi
