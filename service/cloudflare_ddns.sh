#!/bin/bash

# 配置 Cloudflare 信息
auth_token="xxxxxxxxxx"                       # Cloudflare API Token
zone_identifier="xxxxxxxxxx"                    # Cloudflare 区域 ID
record_configs=(
  "ipv4.cuijianzhuang.com:A"
  # 在此添加更多需要同步的记录，例如:
  # "ipv6.cuijianzhuang.com:AAAA"
)        # 要同步的记录 (格式: 域名:记录类型)

# 开始脚本
echo "正在检查 IP 更新..."

need_ipv4=false
need_ipv6=false
for config in "${record_configs[@]}"; do
  record_type="${config##*:}"
  case "$record_type" in
    A) need_ipv4=true ;;
    AAAA) need_ipv6=true ;;
    *)
      echo "错误: 不支持的记录类型 $record_type (配置: $config)" >&2
      exit 1
      ;;
  esac
done

if [[ "$need_ipv4" == true ]]; then
  ipv4=$(curl -s4 https://icanhazip.com/ | tr -d '\r\n')
  if [[ -z "$ipv4" ]]; then
    echo "错误: 无法获取外部 IPv4。" >&2
    exit 1
  fi
  echo "当前外部 IPv4: $ipv4"
fi

if [[ "$need_ipv6" == true ]]; then
  ipv6=$(curl -s6 https://icanhazip.com/ | tr -d '\r\n')
  if [[ -z "$ipv6" ]]; then
    echo "错误: 无法获取外部 IPv6。" >&2
    exit 1
  fi
  echo "当前外部 IPv6: $ipv6"
fi

# 设置认证头
auth_header=(-H "Authorization: Bearer $auth_token")

for config in "${record_configs[@]}"; do
  record_name="${config%%:*}"
  record_type="${config##*:}"
  case "$record_type" in
    A) current_ip="$ipv4" ;;
    AAAA) current_ip="$ipv6" ;;
    *)
      echo "错误: 不支持的记录类型 $record_type (配置: $config)" >&2
      continue
      ;;
  esac

  if [[ -z "$current_ip" ]]; then
    echo "错误: 无法获取 $record_type 类型的 IP，跳过 $record_name。" >&2
    continue
  fi

  echo "------------------------------"
  echo "正在处理记录: $record_name ($record_type)"

  # 获取当前 DNS 记录
  record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name&type=$record_type" \
    "${auth_header[@]}" -H "Content-Type: application/json")

  # 检查记录是否存在
  if [[ -z "$record" ]] || [[ "$record" == *'"count":0'* ]]; then
    echo "DNS 记录不存在，正在创建新记录..."

    # 创建新的 DNS 记录
    create=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records" \
      "${auth_header[@]}" -H "Content-Type: application/json" \
      --data "{\"type\":\"$record_type\",\"name\":\"$record_name\",\"content\":\"$current_ip\",\"ttl\":120,\"proxied\":false}")

    # 检查创建结果
    if echo "$create" | grep -q '"success":true'; then
      echo "DNS 记录创建成功。IP: $current_ip"
    else
      echo "错误: DNS 记录创建失败。响应: $create" >&2
      continue
    fi
    continue
  fi

  # 提取记录 ID 和当前的 IP 地址
  record_identifier=$(echo "$record" | sed 's/.*"id":"\([^"]*\)".*/\1/')
  old_ip=$(echo "$record" | sed 's/.*"content":"\([^"]*\)".*/\1/')
  echo "当前 DNS IP: $old_ip"

  # 如果 IP 没有变化，则跳过
  if [[ "$current_ip" == "$old_ip" ]]; then
    echo "IP 地址未更改，跳过更新。"
    continue
  fi

  # 更新 DNS 记录
  update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
    "${auth_header[@]}" -H "Content-Type: application/json" \
    --data "{\"type\":\"$record_type\",\"name\":\"$record_name\",\"content\":\"$current_ip\",\"ttl\":120,\"proxied\":false}")

  # 检查更新结果
  if echo "$update" | grep -q '"success":true'; then
    echo "更新成功。旧 IP: $old_ip, 新 IP: $current_ip"
  else
    echo "错误: 更新失败。响应: $update" >&2
  fi
done
