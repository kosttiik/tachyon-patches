import importlib.util
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "tools" / "migrate-modular-config.py"
SPEC = importlib.util.spec_from_file_location("migration", SCRIPT)
migration = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(migration)


def item(kind, name, index, **values):
    return {".type": kind, ".name": name, ".index": index, **values}


class MigrationTests(unittest.TestCase):
    def test_inlines_atomic_rules_and_restores_legacy_children(self):
        snapshot = {"values": {
            "settings": item("settings", "settings", 0,
                             applied_migrations=["interface_sections", "modular_entities_v1"],
                             cache_path="/usr/share/tachyon-core/cache.db"),
            "YouTube": item("section", "YouTube", 1, action="connection", enabled="1",
                            condition_refs=["condition_1"], outbound_source_refs=["src_1"]),
            "condition_1": item("condition", "condition_1", 2, condition_type="atomic",
                                enabled="1", domain="youtube.com\ngooglevideo.com"),
            "src_1": item("outbound_source", "src_1", 3, source_type="zapret2",
                           enabled="1", nfqws2_opt="--dpi-desync=fake"),
            "Proxy": item("section", "Proxy", 4, action="connection", enabled="1",
                          outbound_source_refs=["sub_1"]),
            "sub_1": item("outbound_source", "sub_1", 5, source_type="subscription",
                          enabled="1", auto_user_agent="1", auto_hwid="1",
                          include_urltest_groups="0", custom_device_headers="1",
                          device_os="Android"),
            "url_1": item("subscription_url", "url_1", 6, section="Proxy", url="https://private.invalid",
                          auto_user_agent="0", auto_hwid="0"),
            "priority": item("priority_group", "priority", 7, section="Proxy"),
            "level": item("priority_level", "level", 8, group="priority"),
            "balancer": item("balancer", "balancer", 9, section="Proxy"),
        }}
        result = migration.migrate(snapshot, "/etc/tachyon-core/cache.db")
        yt = next(s for s in result["section"] if s[".name"] == "YouTube")
        self.assertEqual(yt["action"], "zapret2")
        self.assertEqual(yt["domain"], ["youtube.com", "googlevideo.com"])
        self.assertEqual(yt["nfqws2_opt"], "--dpi-desync=fake")
        self.assertEqual(len(result["subscription_url"]), 1)
        self.assertEqual(result["subscription_url"][0]["auto_user_agent"], "1")
        self.assertEqual(result["subscription_url"][0]["auto_hwid"], "1")
        self.assertEqual(result["subscription_url"][0]["include_urltest_groups"], "0")
        self.assertEqual(result["subscription_url"][0]["custom_device_headers"], "1")
        self.assertEqual(result["subscription_url"][0]["device_os"], "Android")
        self.assertEqual(result["settings"][0]["cache_path"], "/etc/tachyon-core/cache.db")
        self.assertEqual(result["settings"][0]["applied_migrations"], ["interface_sections"])
        self.assertNotIn("balancer", result)
        self.assertNotIn("condition", result)

    def test_refuses_to_flatten_multiple_conditions(self):
        snapshot = {"values": {
            "section": item("section", "section", 0, condition_refs=["a", "b"]),
            "a": item("condition", "a", 1, condition_type="atomic"),
            "b": item("condition", "b", 2, condition_type="atomic"),
        }}
        with self.assertRaisesRegex(ValueError, "multiple conditions"):
            migration.migrate(snapshot)


if __name__ == "__main__":
    unittest.main()
