#!/bin/sh
# 校验自建仓库的签名与指纹（需要有 openssl + sha256sum）
set -e
cd "$(dirname "$0")"

echo "== 公钥指纹 =="
sha256sum repository-public.pem
echo "expected: $(cat repository-public.sha256)"

echo "== catalog 签名 =="
openssl dgst -sha256 -verify repository-public.pem -signature catalog.json.sig catalog.json

echo "== 插件包签名 =="
for sig in bundles/*.sig; do
  bundle="${sig%.sig}"
  printf '%s: ' "$bundle"
  openssl dgst -sha256 -verify repository-public.pem -signature "$sig" "$bundle"
done

echo "== catalog 里的 sha256 =="
python3 - <<'PY'
import hashlib, json
catalog = json.load(open("catalog.json", encoding="utf-8"))
for pkg in catalog["packages"]:
    digest = hashlib.sha256(open(pkg["bundle"], "rb").read()).hexdigest()
    print(pkg["id"], "OK" if digest == pkg["sha256"] else "MISMATCH")
PY
