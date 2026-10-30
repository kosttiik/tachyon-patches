#!/usr/bin/env python3
"""Convert Tachyon's modular UCI snapshot to the 1.5.21 section model."""

import argparse
import json
import sys


LEGACY_TYPES = ("settings", "telegram", "priority_level", "priority_group",
                "provider", "guest_mode", "subscription_url", "section")
RELATION_KEYS = {"condition_refs", "outbound_source_refs", "balancer_refs",
                 "outbound_group_refs", "source_refs", "member_refs"}
CONDITION_KEYS = {
    "community_lists", "rule_set", "rule_set_with_subnets", "domain_ip_lists",
    "geoip_country", "geoip_mode", "ports", "ports_text", "port", "port_range",
    "protocol", "network", "domain", "domain_text", "domain_suffix",
    "domain_suffix_text", "domain_keyword", "domain_keyword_text", "domain_regex",
    "domain_regex_text", "ip_cidr", "ip_cidr_text", "source_ip_cidr",
    "fully_routed_ips", "excluded_ips", "process_name", "package_name",
}
TEXT_LIST_KEYS = {"domain", "domain_text", "domain_suffix", "domain_suffix_text",
                  "domain_keyword", "domain_keyword_text", "domain_regex",
                  "domain_regex_text", "ip_cidr", "ip_cidr_text", "source_ip_cidr",
                  "fully_routed_ips", "excluded_ips", "ports_text"}
SOURCE_KEYS = {"nfqws2_opt", "mixed_proxy_enabled", "community_subnets",
               "routed_dns_enabled", "excluded_protocol", "fail_policy", "ports_text",
               "outbound_jsons"}
OLD_MIGRATIONS = {
    "interface_sections", "enable_component_checks", "http_connection_urls",
    "dns_hosts_to_option", "steer_spec_v2", "global_hosts_to_section",
    "orphan_section_interface_cleanup", "ensure_dns_server_defaults",
    "engine_identity_tachyon_core",
}


def values_of(snapshot):
    values = snapshot.get("values") if isinstance(snapshot, dict) else None
    if not isinstance(values, dict):
        raise ValueError("Expected ubus uci.get JSON with a values object")
    return values


def option_values(section):
    return {k: v for k, v in section.items() if not k.startswith(".")}


def as_items(value, key):
    if value is None or value == "":
        return []
    if isinstance(value, list):
        return value[:]
    if key in TEXT_LIST_KEYS and isinstance(value, str):
        return [line.strip() for line in value.replace("\r", "").split("\n") if line.strip()]
    return [value]


def merge_option(target, key, incoming):
    if key in TEXT_LIST_KEYS or isinstance(incoming, list) or isinstance(target.get(key), list):
        combined = as_items(target.get(key), key)
        for value in as_items(incoming, key):
            if value not in combined:
                combined.append(value)
        if combined:
            target[key] = combined
        return
    if key in target and target[key] != incoming:
        raise ValueError(f"Conflicting legacy and condition values for {key}")
    target[key] = incoming


def migrate(snapshot, cache_path=None):
    source = values_of(snapshot)
    types = {}
    for name, section in source.items():
        typ = section.get(".type")
        if typ:
            types.setdefault(typ, {})[name] = section

    conditions = types.get("condition", {})
    sources = types.get("outbound_source", {})
    sections = sorted(types.get("section", {}).values(), key=lambda s: int(s.get(".index", 0)))
    migrated_sections = []
    referenced_subscriptions = set()

    for original in sections:
        section = option_values(original)
        for key in RELATION_KEYS:
            section.pop(key, None)
        condition_refs = original.get("condition_refs", [])
        if isinstance(condition_refs, str):
            condition_refs = [condition_refs]
        if len(condition_refs) > 1:
            raise ValueError(f"{original['.name']} has multiple conditions; refusing to flatten logic")
        if condition_refs:
            condition = conditions.get(condition_refs[0])
            if not condition or condition.get("condition_type") != "atomic":
                raise ValueError(f"{original['.name']} has a missing or non-atomic condition")
            if condition.get("enabled") in ("0", 0, False):
                section["enabled"] = "0"
            for key, value in option_values(condition).items():
                if key in CONDITION_KEYS and value not in (None, "", []):
                    merge_option(section, key, value)

        source_refs = original.get("outbound_source_refs", [])
        if isinstance(source_refs, str):
            source_refs = [source_refs]
        for ref in source_refs:
            item = sources.get(ref)
            if not item or item.get("enabled", "1") in ("0", 0, False):
                continue
            source_type = item.get("source_type")
            if source_type == "zapret2":
                section["action"] = "zapret2"
                for key in SOURCE_KEYS - {"outbound_jsons"}:
                    value = item.get(key)
                    if value not in (None, "", []):
                        merge_option(section, key, value)
            elif source_type == "outbound_json":
                if item.get("outbound_jsons"):
                    merge_option(section, "outbound_jsons", item["outbound_jsons"])
            elif source_type == "subscription":
                referenced_subscriptions.add(original[".name"])
            else:
                raise ValueError(f"Unsupported source type in {original['.name']}: {source_type}")

        section[".type"] = "section"
        section[".name"] = original[".name"]
        section[".index"] = original.get(".index", 0)
        migrated_sections.append(section)

    result = {}
    for typ in LEGACY_TYPES:
        result[typ] = []
        for item in sorted(types.get(typ, {}).values(), key=lambda s: int(s.get(".index", 0))):
            clone = dict(item)
            if typ == "settings":
                migrations = clone.get("applied_migrations", [])
                clone["applied_migrations"] = [m for m in migrations if m in OLD_MIGRATIONS]
                if cache_path:
                    clone["cache_path"] = cache_path
            result[typ].append(clone)
    result["section"] = migrated_sections

    subscriptions = result["subscription_url"]
    legacy_child_by_section = {s.get("section"): s for s in subscriptions if s.get("section")}
    for name, item in sources.items():
        if item.get("source_type") != "subscription" or item.get("enabled", "1") in ("0", 0, False):
            continue
        section_name = None
        for section in sections:
            refs = section.get("outbound_source_refs", [])
            if isinstance(refs, str):
                refs = [refs]
            if name in refs:
                section_name = section[".name"]
                break
        child = legacy_child_by_section.get(section_name)
        if not child or not child.get("url"):
            raise ValueError("An enabled subscription source has no legacy URL entry")
        for key in ("auto_user_agent", "user_agent", "auto_hwid", "hwid",
                    "custom_device_headers", "device_os", "ver_os", "device_model",
                    "device_locale", "app_version", "accept_language",
                    "show_dashboard_metadata", "subscription_update_enabled",
                    "subscription_update_interval", "download_via_proxy_enabled",
                    "download_via_proxy_section", "prefix_nodes", "node_prefix",
                    "node_prefix_bg", "node_prefix_color", "include_urltest_groups",
                    "hide_urltest_group_outbounds", "hide_detour_outbounds",
                    "subscription_insecure"):
            if item.get(key) is not None:
                child[key] = item[key]
    linked = [s for s in subscriptions if s.get("section") in referenced_subscriptions]
    if referenced_subscriptions and len(linked) != len(referenced_subscriptions):
        raise ValueError("A subscription source has no legacy subscription_url child")
    return result


def uci_quote(value):
    value = str(value)
    if "\n" in value or "\r" in value:
        raise ValueError("UCI scalar contains a newline")
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def render_uci(config):
    output = []
    for typ in LEGACY_TYPES:
        for item in config.get(typ, []):
            name = item.get(".name")
            if not name:
                continue
            output.append(f"config {typ} {uci_quote(name)}")
            for key, value in item.items():
                if key.startswith(".") or value is None:
                    continue
                if isinstance(value, list):
                    output.extend(f"\tlist {key} {uci_quote(v)}" for v in value)
                elif isinstance(value, str) and "\n" in value:
                    output.extend(f"\tlist {key} {uci_quote(v.strip())}" for v in value.splitlines() if v.strip())
                else:
                    output.append(f"\toption {key} {uci_quote(value)}")
            output.append("")
    return "\n".join(output)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("snapshot", help="private JSON from ubus call uci get")
    parser.add_argument("--cache-path", help="path from the active core config")
    parser.add_argument("--format", choices=("fixture", "uci"), default="fixture")
    args = parser.parse_args()
    try:
        with open(args.snapshot, encoding="utf-8") as f:
            result = migrate(json.load(f), args.cache_path)
        print(json.dumps(result, ensure_ascii=False, indent=2) if args.format == "fixture" else render_uci(result))
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print(f"migration refused: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
