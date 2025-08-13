/*
Clash for Windows 版本: v0.20.21
Settings → Profiles → Parsers 填写如下内容
```
parsers:
    - url: "VPN链接"
      file: 指向parser.js（本文件）的路径
```
*/


module.exports.parse = async (raw, { axios, yaml, notify, console }, { name, url, interval, selected }) => {
    const config = yaml.parse(raw);
    config["external-controller"] = "0.0.0.0:9099";
    config["external-ui"] = "/nas/public/app/clash/clash-for-linux/dashboard/public";

    // ======== 节点模板配置 ========
    const nodeTemplates = {
        ss: { // SSR节点模板
            type: "ss",
            port: 111,
            password: "111",
            cipher: "aes-256-gcm",
            udp: false
        },
        vmess: { // V2Ray节点模板
            type: "vmess",
            port: 111,
            uuid: "11111111-2222-3333-4444-555555555555",
            alterId: 0,
            cipher: "chacha20-poly1305",
            udp: false
        }
    };
    const customNodes = [
        { name: "name", server: "server.com", type: "ss" },
    ];
    const newNodeConfigs = customNodes.map(node => ({
        name: node.name,
        server: node.server,
        ...nodeTemplates[node.type]
    }));
    // 添加到配置最前面
    config.proxies.unshift(...newNodeConfigs);

    // ======== 修改代理组 ========

    const newNodeNames = customNodes.map(node => node.name);
    config['proxy-groups'].forEach(group => {
        group.proxies.push(...newNodeNames);
    });
    // 查找并修改
    let proxyGroup = config['proxy-groups'][0]
    config['proxy-groups'].splice(1, 0, {  // 添加在第一个proxy-group后面
        name: "🚀自动选择",
        type: "url-test",
        url: "http://www.gstatic.com/generate_204",
        interval: 600,
        proxies: proxyGroup.proxies
    }, {
        name: "🔰手动选择",
        type: "select",
        proxies: proxyGroup.proxies
    });
    proxyGroup.proxies = ["🚀自动选择", "🔰手动选择"];

    proxyGroup = config['proxy-groups'].find(group => group.name === "📲Telegram");
    proxyGroup.type = "url-test";
    proxyGroup.url = "http://www.gstatic.com/generate_204";
    proxyGroup.interval = 600;
    const proxiesToDelete = ["🔰Proxy"];  // 删除无法访问ChatGPT的proxy
    proxyGroup.proxies = proxyGroup.proxies.filter(proxy => !proxy.startsWith("HK") && !proxiesToDelete.includes(proxy));


    // ======== 添加自定义规则 ========
    const customRules = [
        'DOMAIN-SUFFIX,anthropic.com,📲Telegram',
        'DOMAIN-SUFFIX,claude.ai,📲Telegram',
        'DOMAIN-SUFFIX,bard.google.com,📲Telegram',
        'DOMAIN-SUFFIX,chatgpt.com,📲Telegram',
        'DOMAIN-SUFFIX,auth0.com,📲Telegram',
        'DOMAIN-SUFFIX,challenges.cloudflare.com,📲Telegram',
        'DOMAIN-SUFFIX,client-api.arkoselabs.com,📲Telegram',
        'DOMAIN-SUFFIX,events.statsigapi.net,📲Telegram',
        'DOMAIN-SUFFIX,featuregates.org,📲Telegram',
        'DOMAIN-SUFFIX,identrust.com,📲Telegram',
        'DOMAIN-SUFFIX,ingest.sentry.io,📲Telegram',
        'DOMAIN-SUFFIX,intercom.io,📲Telegram',
        'DOMAIN-SUFFIX,intercomcdn.com,📲Telegram',
        'DOMAIN-SUFFIX,ai.com,📲Telegram',
        'DOMAIN-SUFFIX,openai.com,📲Telegram',
        'DOMAIN,chat.openai.com.cdn.cloudflare.net,📲Telegram',
        'DOMAIN,openaiapi-site.azureedge.net,📲Telegram',
        'DOMAIN,openaicom-api-bdcpf8c6d2e9atf6.z01.azurefd.net,📲Telegram',
        'DOMAIN,openaicomproductionae4b.blob.core.windows.net,📲Telegram',
        'DOMAIN,production-openaicom-storage.azureedge.net,📲Telegram',
        'DOMAIN-SUFFIX,oaistatic.com,📲Telegram',
        'DOMAIN-SUFFIX,oaiusercontent.com,📲Telegram',
    ];
    // 将自定义 rules 插入到配置文件的 rules 开头
    config.rules.unshift(...customRules);

    // 返回修改后的配置文件
    return yaml.stringify(config)
}
