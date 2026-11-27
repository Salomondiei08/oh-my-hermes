"""Run with Hermes's Python environment after installing into a disposable HERMES_HOME."""
import json
from pathlib import Path


def main():
    """Assert discovery and explicit loading through the upstream implementation."""
    import tools.skills_tool as skills_tool

    find_all_skills = getattr(skills_tool, 'find_all_skills', None) or skills_tool._find_all_skills
    skill_view = skills_tool.skill_view

    expected = {p.stem for p in (Path(__file__).resolve().parents[1] / 'skills').glob('*.md')}
    catalog = {skill['name'] for skill in find_all_skills(skip_disabled=True)}
    assert not expected - catalog, f'Missing catalog skills: {expected - catalog}'
    for name in sorted(expected):
        result = json.loads(skill_view(name))
        assert result.get('success') is not False, (name, result)
    print(f'UPSTREAM CATALOG AND LOAD: {len(expected)} OMH skills discovered and loaded')


if __name__ == '__main__':
    main()
