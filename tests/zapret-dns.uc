let route = require("tachyon_core.route");
let condition = { domain_suffix: [ "example.org" ] };
let standard = route.resolve_rule_for_section({ ".name": "vpn", action: "zapret2" }, condition);
let routed = route.resolve_rule_for_section({ ".name": "vpn", action: "zapret2", routed_dns_enabled: "1" }, condition);
if (standard.rule.server != "dns-server" || routed.rule.server != "vpn-routed-dns-server")
    exit(1);
print("DNS resolver fixtures passed\n");
