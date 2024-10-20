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
    const config = yaml.parse(raw)
    // 遍历配置中的 proxy-groups
    config['proxy-groups'].forEach(group => {
        if (group.name === "🔰Proxy") {
            group.type = "url-test";
            group.url = "http://www.gstatic.com/generate_204";
            group.interval = 600;
        }
        if (group.name === "📲Telegram") {  // 复用一个已有的组作为ChatGPT代理
            group.type = "url-test";
            group.url = "http://www.gstatic.com/generate_204";
            group.interval = 600;

            const proxiesToDelete = ["🔰Proxy"];  // 删除无法访问ChatGPT的proxy
            group.proxies = group.proxies.filter(proxy => !proxy.startsWith("HK") && !proxiesToDelete.includes(proxy));
        }
    });

    // 你可以在这里添加你的自定义 rules
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