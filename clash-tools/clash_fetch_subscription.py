#!/usr/bin/env python3
import argparse
import base64
import re
import sys
import urllib.parse

import requests
import yaml

def parse_args():
    parser = argparse.ArgumentParser(
        description="Fetch Clash subscription and print YAML"
    )
    parser.add_argument("--url", required=True, help="订阅链接，需 http/https")
    parser.add_argument("--timeout", type=float, default=20, help="HTTP 超时秒数，默认 20")
    parser.add_argument(
        "--with-proxy",
        action="store_true",
        help="使用系统 HTTP(S)_PROXY 变量（类似 with_proxy）",
    )
    parser.add_argument(
        "--self-proxy",
        help="使用指定代理，如 http://127.0.0.1:7890（类似 self_proxy）",
    )
    parser.add_argument("--user-agent", help="自定义 UA")
    parser.add_argument("--insecure", action="store_true", help="允许无效证书")
    return parser.parse_args()

def build_proxies(args):
    if args.self_proxy:
        return {"http": args.self_proxy, "https": args.self_proxy}
    if args.with_proxy:
        # requests 默认已读取环境代理；显式返回 None 使用环境
        return None
    # 不走代理
    return {}

def detect_filename(url, headers):
    content_disposition = headers.get("Content-Disposition", "")

    # filename* 优先，支持 RFC 5987
    match_rfc5987 = re.search(
        r"filename\*\s*=\s*([^'\";]+''[^\s;]+)", content_disposition, re.IGNORECASE
    )
    if match_rfc5987:
        encoding_and_name = match_rfc5987.group(1)
        encoding, name_enc = encoding_and_name.split("''", 1)
        try:
            return urllib.parse.unquote(name_enc, encoding=encoding)
        except Exception:
            return urllib.parse.unquote(name_enc)

    match_simple = re.search(
        r"filename\s*=\s*\"?(?P<fn>[^\";]+)\"?", content_disposition, re.IGNORECASE
    )
    if match_simple:
        return match_simple.group("fn")

    # fallback: URL 最后一段
    last_part = url.rstrip("/").split("/")[-1]
    return urllib.parse.unquote(last_part or "Remote File")


def try_parse_yaml(text):
    try:
        data = yaml.safe_load(text)
    except Exception:
        return None
    if isinstance(data, dict) and (
        "proxies" in data or "proxy-providers" in data
    ):
        return data
    return None


def maybe_base64_decode(text):
    # 某些订阅返回 base64，需要解码后再尝试解析
    raw = text.strip()
    if not raw:
        return None
    # 补齐 padding
    missing = len(raw) % 4
    if missing:
        raw += "=" * (4 - missing)
    try:
        decoded = base64.b64decode(raw, validate=False)
    except Exception:
        return None
    if not decoded:
        return None
    try:
        return decoded.decode("utf-8", errors="replace")
    except Exception:
        return None


def looks_like_share_links(text):
    tokens = ("ss://", "vmess://", "trojan://", "vless://")
    return any(t in text for t in tokens)


def decode_base64_section(raw):
    # 补齐 padding
    missing = len(raw) % 4
    if missing:
        raw += "=" * (4 - missing)
    return base64.b64decode(raw)


def parse_ss_link(link):
    """
    支持两类 ss:
    1) ss://method:password@host:port?plugin=...#name
    2) ss://<base64(method:password@host:port)>#name
    """
    if not link.startswith("ss://"):
        return None

    # 处理 base64 主体
    body = link[len("ss://") :]
    frag = ""
    if "#" in body:
        body, frag = body.split("#", 1)
    decoded_body = body
    if "@" not in body:
        try:
            decoded_body = decode_base64_section(body).decode(
                "utf-8", errors="replace"
            )
        except Exception:
            return None

    rebuilt = "ss://" + decoded_body
    if frag:
        rebuilt += "#" + frag

    parsed = urllib.parse.urlparse(rebuilt)
    cipher = parsed.username or ""
    password = parsed.password or ""
    host = parsed.hostname or ""
    port = parsed.port
    name = urllib.parse.unquote(parsed.fragment) or host or "ss"

    if not cipher or not password or not host or not port:
        return None

    qs = urllib.parse.parse_qs(parsed.query, keep_blank_values=True)
    plugin = None
    plugin_opts = {}
    plugin_raw = qs.get("plugin", [None])[0]
    if plugin_raw:
        parts = plugin_raw.split(";")
        plugin = parts[0]
        for p in parts[1:]:
            if not p:
                continue
            if "=" in p:
                k, v = p.split("=", 1)
                plugin_opts[k] = v

    proxy = {
        "name": name,
        "type": "ss",
        "server": host,
        "port": int(port),
        "cipher": cipher,
        "password": password,
        "udp": True,
    }
    if plugin:
        proxy["plugin"] = plugin
        if plugin_opts:
            proxy["plugin-opts"] = plugin_opts
    return proxy


def share_links_to_clash_yaml(text):
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    proxies = []
    for ln in lines:
        if ln.startswith("ss://"):
            proxy = parse_ss_link(ln)
            if proxy:
                proxies.append(proxy)
    if proxies:
        return yaml.safe_dump({"proxies": proxies}, allow_unicode=True, sort_keys=False)
    return None

def main():
    args = parse_args()
    proxies = build_proxies(args)
    headers = {}
    if args.user_agent:
        headers["User-Agent"] = args.user_agent

    if not args.url.lower().startswith(("http://", "https://")):
        sys.stderr.write("URL 必须以 http/https 开头\n")
        sys.exit(1)

    try:
        response = requests.get(
            args.url,
            timeout=args.timeout,
            proxies=proxies,
            headers=headers,
            verify=not args.insecure,
        )
    except Exception as exc:
        sys.stderr.write(f"下载失败: {exc}\n")
        sys.exit(2)

    if not 200 <= response.status_code < 300:
        sys.stderr.write(f"下载失败，状态码 {response.status_code}\n")
        sys.exit(3)

    # 去掉 UTF-8 BOM
    text = response.text.lstrip("\ufeff")

    # 直接尝试 YAML
    yaml_data = try_parse_yaml(text)
    if yaml_data is not None:
        sys.stdout.write(text)
        return

    # 如失败，尝试 base64 解码后再判断
    decoded = maybe_base64_decode(text)
    if decoded:
        yaml_data = try_parse_yaml(decoded)
        if yaml_data is not None:
            sys.stdout.write(decoded)
            return
        if looks_like_share_links(decoded):
            clash_yaml = share_links_to_clash_yaml(decoded)
            if clash_yaml:
                sys.stdout.write(clash_yaml)
                return
            sys.stdout.write(decoded)
            return

    sys.stderr.write("订阅无法解析为 Clash YAML，且未检测到可用节点\n")
    sys.exit(5)

    # 如需额外元信息，可调用：
    #   detect_filename(args.url, response.headers)
    #   response.headers.get("profile-update-interval")
    #   response.headers.get("profile-web-page-url")
    #   遍历 headers 查找 *subscription-userinfo

if __name__ == "__main__":
    main()
