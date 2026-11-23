"""Behavioral distribution checks isolated from the user's Hermes installation."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DistributionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.home = self.base / "hermes"
        self.home.mkdir()
        self.env = {**os.environ, "HERMES_HOME": str(self.home), "TEST_MODE": "1"}

    def run_script(self, script, *args, cwd=None, input=None):
        return subprocess.run(["bash", str(ROOT / script), *args], cwd=cwd,
                              env=self.env, text=True, input=input,
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    def install(self):
        result = self.run_script("install.sh")
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_installs_all_skills_in_discoverable_layout_and_templates(self):
        self.install()
        sources = sorted((ROOT / "skills").glob("*.md"))
        self.assertEqual(len(sources), 39)
        for source in sources:
            self.assertEqual((self.home / "skills/oh-my-hermes" / source.stem / "SKILL.md").read_bytes(), source.read_bytes())
        self.assertTrue((self.home / "templates/AGENTS.md.template").is_file())
        result = self.run_script("scripts/verify.sh")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(self.run_script("scripts/test.sh").returncode, 0)

    def test_installed_validator_checks_discoverable_skill_files(self):
        self.install()
        (self.home / "skills/custom-notes.md").write_text("user notes, not an Oh My Hermes skill")
        result = self.run_script(str(self.home / "scripts/validate-skills.sh"))
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_verify_missing_install_fails(self):
        self.assertNotEqual(self.run_script("scripts/verify.sh").returncode, 0)

    def test_reinstall_and_uninstall_preserve_customizations_and_profile_state(self):
        self.install()
        skill = self.home / "skills/oh-my-hermes/create-skill/SKILL.md"
        skill.write_text("customized")
        custom = self.home / "skills/oh-my-hermes/custom/SKILL.md"
        custom.parent.mkdir()
        custom.write_text("user skill")
        profile = self.home / "profiles/cto/memories/MEMORY.md"
        profile.parent.mkdir(parents=True)
        profile.write_text("private state")
        self.install()
        self.assertEqual(skill.read_text(), "customized")
        result = self.run_script("scripts/uninstall.sh", input="y\n")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(skill.read_text(), "customized")
        self.assertEqual(custom.read_text(), "user skill")
        self.assertEqual(profile.read_text(), "private state")
        self.assertFalse((self.home / "skills/oh-my-hermes/gateway-routing/SKILL.md").exists())
        self.assertEqual(sorted(self.home.glob("skills/oh-my-hermes/*/SKILL.md")), sorted([skill, custom]))
        self.assertIn("cron", result.stdout.lower())

    def test_install_preserves_unowned_collision(self):
        custom = self.home / "workflows/cto-loop.md"
        custom.parent.mkdir()
        custom.write_text("unowned")
        self.install()
        self.assertEqual(custom.read_text(), "unowned")

    def test_installed_bootstrap_uses_existing_router_and_is_idempotent(self):
        self.install()
        bootstrap = self.home / "scripts/bootstrap.sh"
        for folder in ("app", "src/app"):
            with self.subTest(folder=folder):
                project = self.base / folder.replace("/", "-")
                (project / folder).mkdir(parents=True)
                (project / "package.json").write_text(json.dumps({"dependencies": {"next": "16.0.0"}}))
                result = self.run_script(str(bootstrap), cwd=project)
                self.assertEqual(result.returncode, 0, result.stdout)
                route = project / folder / "api/health/route.ts"
                self.assertTrue(route.is_file())
                unused = "src/app" if folder == "app" else "app"
                self.assertFalse((project / unused).exists())
                self.assertIn(".env*", (project / ".gitignore").read_text())
                route.write_text("custom health")
                self.assertEqual(self.run_script(str(bootstrap), cwd=project).returncode, 0)
                self.assertEqual(route.read_text(), "custom health")

    def test_bootstrap_refuses_unsupported_and_ambiguous_frameworks(self):
        cases = (([], "next"), (["app", "src/app"], "next"), (["app"], "vite"))
        for index, (folders, framework) in enumerate(cases):
            with self.subTest(folders=folders, framework=framework):
                project = self.base / str(index)
                project.mkdir()
                for folder in folders:
                    (project / folder).mkdir(parents=True)
                (project / "package.json").write_text(json.dumps({"dependencies": {framework: "16.0.0"}}))
                self.assertNotEqual(self.run_script("scripts/bootstrap.sh", cwd=project).returncode, 0)
                self.assertFalse((project / "AGENTS.md").exists())
                self.assertFalse((project / "src/app/api/health/route.ts").exists())

    def test_install_does_not_follow_custom_directory_symlinks(self):
        outside = self.base / "custom-scripts"
        outside.mkdir()
        (outside / "bootstrap.sh").write_text("custom")
        (self.home / "scripts").symlink_to(outside, target_is_directory=True)
        self.install()
        self.assertEqual((outside / "bootstrap.sh").read_text(), "custom")
        self.assertEqual(len(list(outside.iterdir())), 1)

    def test_setup_checks_are_explicit_and_fail_when_profiles_are_missing(self):
        self.install()
        self.assertNotEqual(self.run_script("scripts/verify.sh", "--setup").returncode, 0)

    def test_validator_rejects_malformed_yaml_and_missing_pitfalls(self):
        fixture = self.base / "repo"
        (fixture / "scripts").mkdir(parents=True)
        (fixture / "skills").mkdir()
        shutil.copy(ROOT / "scripts/validate-skills.sh", fixture / "scripts")
        skill = fixture / "skills/example.md"
        skill.write_text("---\nname: example\ndescription: Use when testing\nversion: 1.0.0\ntags: [test\n---\n" + "\n".join("## " + section for section in ("When to Use", "Prerequisites", "Procedure", "Pitfalls", "Verification")))
        result = self.run_script(str(fixture / "scripts/validate-skills.sh"))
        self.assertNotEqual(result.returncode, 0, result.stdout)
        skill.write_text(skill.read_text().replace("tags: [test", "tags: [test]").replace("## Pitfalls", "## Other"))
        self.assertNotEqual(self.run_script(str(fixture / "scripts/validate-skills.sh")).returncode, 0)

    def test_catalog_checker_supports_public_and_legacy_hermes_api(self):
        import contextlib
        import importlib.util
        import io
        import sys
        import types
        from unittest.mock import patch

        spec = importlib.util.spec_from_file_location("check_hermes_catalog", ROOT / "tests/check_hermes_catalog.py")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)

        skills = [{"name": p.stem} for p in sorted((ROOT / "skills").glob("*.md"))]
        for attr_name in ("find_all_skills", "_find_all_skills"):
            with self.subTest(attr_name=attr_name):
                fake_tools = types.ModuleType("tools")
                fake_tools.__path__ = []
                fake_skills_tool = types.ModuleType("tools.skills_tool")
                setattr(fake_skills_tool, attr_name, lambda *, skip_disabled=False: skills if skip_disabled else [])
                fake_skills_tool.skill_view = lambda name: json.dumps({"success": True, "name": name})
                fake_tools.skills_tool = fake_skills_tool
                output = io.StringIO()
                with patch.dict(sys.modules, {"tools": fake_tools, "tools.skills_tool": fake_skills_tool}), \
                     contextlib.redirect_stdout(output):
                    module.main()
                self.assertEqual(
                    output.getvalue().strip(),
                    f"UPSTREAM CATALOG AND LOAD: {len(skills)} OMH skills discovered and loaded",
                )


if __name__ == "__main__":
    unittest.main()
