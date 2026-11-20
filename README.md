# 自建插件仓库（静态站）

这是小米智能存储「插件市场」可直接添加的签名插件仓库。整个目录就是仓库根，丢到任意静态托管（GitHub Pages / Cloudflare Pages / 对象存储）即可。

## 仓库信息

| 项 | 值 |
|---|---|
| 仓库名 | JeremyRhys 插件仓库 |
| 已部署地址 | `https://jeremyrhys.github.io/minas-plugin-repo/` |
| 源码仓库 | `https://github.com/JeremyRhys/minas-plugin-repo` |
| 公钥指纹（SHA-256） | `0d92c24c7b96ff55a068058d8cfd6c80dc494f2698dcbf6dbe2eeae06bdf63e1` |
| 签名算法 | ECDSA P-256 + SHA-256（分离签名） |
| 插件 | `nasmonitor` 1.0.0（性能监控） |

> 指纹以 `repository-public.sha256` 为准。别人添加时看到的第一串指纹必须和这里**逐字一致**，否则不要确认。

## 文件

```
catalog.json               插件清单（名称、版本、sha256、相对路径）
catalog.json.sig           catalog.json 的分离签名
repository-public.pem      仓库公钥（发布用，不含私钥）
repository-public.sha256    公钥指纹
bundles/<id>-<ver>.bundle.zip{,.sig}   插件包 + 各自签名
icons/<id>.png            插件图标
```

**私钥不在这里**。私钥只在制作者的 `keys/repo-key.pem`，丢失 = 必须换钥、所有使用者重新导入指纹。

## 部署到 GitHub Pages

1. 新建仓库（公开），把本目录**全部内容**放到仓库根（不是子目录）。
2. 仓库 Settings → Pages → Source 选 `Deploy from a branch`，分支 `main`，目录 `/ (root)`，保存。
3. 等 1–2 分钟，地址形如 `https://<用户名>.github.io/<仓库名>/`。
4. 用浏览器打开 `<地址>/catalog.json`，能看到 JSON 即成功。

## 部署到 Cloudflare Pages

1. Cloudflare Dashboard → Workers & Pages → Create → Pages → Upload assets。
2. 把本目录整个上传（或连 Git 仓库，构建命令留空，输出目录填 `/`）。
3. 得到 `https://<项目名>.pages.dev/`。

## 别人怎么添加

小米智能存储客户端 → 全部应用 → 插件市场 → **来源** 标签 → **添加签名源**：

1. 填仓库地址，**以 `/` 结尾**，例如 `https://example.github.io/plugin-repo/`。
2. 点「验证地址」，核对显示的公钥指纹与上面一致。
3. 点「确认添加」。之后「精选」里会出现本仓库的插件。

添加只接受 HTTPS；商店会拒绝解析到内网/回环的地址，也不会跟随重定向。

## 更新仓库

1. 改插件源码 → 跑 `python build_repo.py --source plugins/<id> --name "<名称>" --summary "<一句话>"`（版本号必须递增）。
2. 用新生成的 `catalog.json`、`catalog.json.sig`、`bundles/`、`icons/` 覆盖本目录对应文件。
3. 推送到托管。使用者的商店刷新后即可看到新版本；已装插件的升级仍走同一个验签流程。

## 安全说明

- 包是声明式 `bundle-v1`：只有 `manifest.json` / `runtime/` / `ui/` / `icon/` / `config/<service>` / `config/<nginx>`，没有安装 shell。
- 商店安装前会校验：catalog 签名 → 包 SHA-256 → 包签名 → manifest 规则 → 健康检查，任一步失败自动回滚。
- 本仓库只包含「性能监控」，安装后是独立应用，不依赖系统中心，也不会覆盖它。
