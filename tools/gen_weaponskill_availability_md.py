"""Generate documentation/weaponskill_availability_by_level.md from SQL.

Layout inspired by FFXIclopedia weapon category pages (e.g. Category:Daggers):
per weapon type: intro-style section, Job skill ratings table, Weapon skills table.
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

TYPE_TO_SKILL = {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9, 10: 10, 11: 11, 12: 12, 25: 25, 26: 26}

JOB_TITLES = [
    "Warrior",
    "Monk",
    "White Mage",
    "Black Mage",
    "Red Mage",
    "Thief",
    "Paladin",
    "Dark Knight",
    "Beastmaster",
    "Bard",
    "Ranger",
    "Samurai",
    "Ninja",
    "Dragoon",
    "Summoner",
    "Blue Mage",
    "Corsair",
    "Puppetmaster",
    "Dancer",
    "Scholar",
    "Geomancer",
    "Rune Fencer",
]

# skill_caps column index -> letter tier (lower index = higher cap at most levels)
RANK_LABELS = {
    0: "—",
    1: "A+",
    2: "A",
    3: "A-",
    4: "B+",
    5: "B",
    6: "B-",
    7: "C+",
    8: "C",
    9: "C-",
    10: "D",
    11: "E",
    12: "F",
}

# Internal SQL category name -> wiki-style section heading
CATEGORY_HEADING = {
    "hand2hand": "Hand-to-hand",
    "dagger": "Daggers",
    "sword": "Swords",
    "great sword": "Great Swords",
    "axe": "Axes",
    "great axe": "Great Axes",
    "scythe": "Scythes",
    "polearm": "Polearms",
    "katana": "Katana",
    "great katana": "Great Katana",
    "club": "Clubs",
    "staff": "Staves",
    "archery": "Archery",
    "marksmanship": "Marksmanship",
}

CATEGORY_BLURB = {
    "hand2hand": "Unarmed and knuckle weapons. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "dagger": "One-handed daggers. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "sword": "One-handed swords. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "great sword": "Two-handed great swords. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "axe": "One-handed axes. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "great axe": "Two-handed great axes. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "scythe": "Two-handed scythes. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "polearm": "Two-handed polearms. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "katana": "One-handed katana. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "great katana": "Two-handed great katana. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "club": "One-handed clubs. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "staff": "Staves. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "archery": "Ranged archery. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
    "marksmanship": "Ranged guns/crossbows. Skill caps follow `skill_caps` / `skill_ranks` in this repo.",
}


def load_caps():
    caps = {}
    for line in (ROOT / "sql/skill_caps.sql").read_text(encoding="utf-8").splitlines():
        m = re.match(r"INSERT INTO `skill_caps` VALUES \((\d+),(.+)\);$", line)
        if not m:
            continue
        lvl = int(m.group(1))
        parts = [int(x.strip()) for x in m.group(2).split(",")]
        caps[lvl] = parts
    return caps


def load_skills():
    skills = {}
    for line in (ROOT / "sql/skill_ranks.sql").read_text(encoding="utf-8").splitlines():
        m = re.match(r"INSERT INTO `skill_ranks` VALUES \((\d+),'([^']+)',(.+)\);$", line)
        if not m:
            continue
        sid = int(m.group(1))
        name = m.group(2)
        ranks = [int(x.strip()) for x in m.group(3).split(",")]
        skills[sid] = (name, ranks)
    return skills


def best_worst_rank(skillid, skills):
    _, ranks = skills[skillid]
    nz = [r for r in ranks if r > 0]
    if not nz:
        return None, None
    return min(nz), max(nz)


def min_level_for_rank(caps, rank_idx, need_skill, max_lv=75):
    if rank_idx is None or need_skill <= 0:
        return None
    for lv in range(1, max_lv + 1):
        row = caps.get(lv)
        if row and row[rank_idx] >= need_skill:
            return lv
    return None


def load_weapon_skills():
    rows = []
    text = (ROOT / "sql/weapon_skills.sql").read_text(encoding="utf-8")
    for line in text.splitlines():
        m = re.match(r"INSERT INTO `weapon_skills` VALUES \((\d+),'([^']+)',[^,]+,(\d+),(\d+),", line)
        if not m:
            continue
        wid, wname, wtype, sklvl = int(m.group(1)), m.group(2), int(m.group(3)), int(m.group(4))
        tail = line.strip().rsplit(",", 2)
        unlock = int(tail[-1].rstrip(");"))
        rows.append((wid, wname, wtype, sklvl, unlock))
    return rows


def rank_label(rank_idx: int) -> str:
    if rank_idx <= 0:
        return "—"
    return RANK_LABELS.get(rank_idx, f"Col {rank_idx}")


def prettify_ws_name(raw: str) -> str:
    return " ".join(part.capitalize() for part in raw.replace("_", " ").split())


def load_ws_display_names() -> dict[int, str]:
    """Map WS id -> display string from documentation/player_abilities.txt (WeaponSkill rows)."""
    path = ROOT / "documentation" / "player_abilities.txt"
    if not path.is_file():
        return {}
    out: dict[int, str] = {}
    pat = re.compile(r"^\s*(\d{4})\s+(.+?)\s+WeaponSkill")
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        m = pat.match(line)
        if not m:
            continue
        wid = int(m.group(1), 10)
        name = re.sub(r"\s+", " ", m.group(2).strip())
        if name and name != "." and not name.lower().startswith("unused"):
            out[wid] = name
    return out


def ws_display_name(wid: int, sql_slug: str, display_map: dict[int, str]) -> str:
    if wid in display_map:
        return display_map[wid]
    return prettify_ws_name(sql_slug)


def job_ratings_table(caps, skillid: int, skills: dict) -> list[str]:
    _, ranks = skills[skillid]
    rows_out = []
    for i, rank_idx in enumerate(ranks):
        if rank_idx <= 0:
            continue
        job = JOB_TITLES[i]
        label = rank_label(rank_idx)
        c1 = caps[1][rank_idx] if 1 in caps else 0
        c49 = caps[49][rank_idx] if 49 in caps else 0
        c75 = caps[75][rank_idx] if 75 in caps else 0
        rows_out.append((rank_idx, job, label, c1, c49, c75))
    rows_out.sort(key=lambda r: (r[0], r[1]))
    # FFXIclopedia-style tier prefix: group by rank_idx, assign 01, 02, ... per distinct tier (best first)
    lines = [
        "| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |",
        "| --- | --- | ---: | ---: | ---: |",
    ]
    tier = 0
    prev_rank = None
    for rank_idx, job, label, c1, c49, c75 in rows_out:
        if rank_idx != prev_rank:
            tier += 1
            prev_rank = rank_idx
        ranking = f"{tier:02d}) {label}"
        lines.append(f"| {job} | {ranking} | {c1} | {c49} | {c75} |")
    return lines


def ws_notes(sklvl, unlock, best_lv, _worst_lv, cb, _caps, _br):
    if sklvl > 0:
        if best_lv is not None:
            return "Natural cap (best job rank for this weapon type)"
        return f"Req. {sklvl} > best cap @75 ({cb}); **Suggested Lv** uses 61–75 compression band"
    if unlock > 0:
        return "Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL`"
    return "Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor)"


def suggested_level(sklvl, unlock, best_lv, cb):
    if sklvl > 0:
        if best_lv is not None:
            return str(best_lv)
        # Keep in sync with battleutils::CompressedWeaponskillMinLevel (battleutils.cpp).
        lo, hi = 250, 357
        t = (max(sklvl, lo) - lo) / (hi - lo) if hi > lo else 1.0
        cs = int(round(61 + max(0.0, min(1.0, t)) * 14))
        return str(max(61, min(75, cs)))
    if unlock > 0:
        return "75"
    return "—"


def main():
    caps = load_caps()
    skills = load_skills()
    ws_rows = load_weapon_skills()
    ws_names = load_ws_display_names()
    # Custom / server WS not listed as WeaponSkill in player_abilities.txt
    ws_names.setdefault(228, "Final Paradise")

    lines = []
    lines.append("# Weapon skill availability by level (75-cap progression)")
    lines.append("")
    lines.append("<!-- Regenerate: `python tools/gen_weaponskill_availability_md.py` (from `server/`) -->")
    lines.append("")
    lines.append("Layout follows **[FFXIclopedia weapon categories](https://ffxiclopedia.fandom.com/wiki/Category:Daggers)** style: each weapon type has **Job skill ratings** then **Weapon skills**, sorted by required combat skill.")
    lines.append("")
    lines.append("## Server rules (summary)")
    lines.append("")
    lines.append("- **Skill math** uses this repo’s **`skill_caps`** and **`skill_ranks`** (`battleutils::GetMaxSkill`). Caps below use **level 75** (not 99).")
    lines.append("- **Job flags on WS are not enforced** in map code: any job may use a WS if skill/unlock/item rules pass. Weapon/ranged/H2H categories are **A+ for all jobs** in `skill_ranks`; defensive and magic schools keep retail ranks.")
    lines.append("- **Post–75-era** requirements in SQL are folded into **suggested levels** where the skill floor exceeds the best cap at 75.")
    lines.append("")
    lines.append("- See [Combat Skills](https://ffxiclopedia.fandom.com/wiki/Category:Combat_Skills) on the wiki for retail context; numbers here come from **your** SQL dumps.")
    lines.append(
        "- **Weapon skill** display names prefer `documentation/player_abilities.txt` (WeaponSkill rows); anything missing there is title-cased from the SQL slug."
    )
    lines.append("")

    # Categories present in weapon_skills, stable wiki heading order
    internal_cats = set()
    for _w, _n, wtype, _s, _u in ws_rows:
        sid = TYPE_TO_SKILL.get(wtype)
        if sid is not None:
            internal_cats.add(skills[sid][0])

    def cat_sort_key(cn: str):
        return CATEGORY_HEADING.get(cn, cn)

    for cat_internal in sorted(internal_cats, key=cat_sort_key):
        sid = None
        for _tid, (name, _) in skills.items():
            if name == cat_internal:
                sid = _tid
                break
        if sid is None:
            continue

        heading = CATEGORY_HEADING.get(cat_internal, cat_internal.title())
        lines.append(f"## {heading}")
        lines.append("")
        lines.append(CATEGORY_BLURB.get(cat_internal, ""))
        lines.append("")
        lines.append("### Job skill ratings")
        lines.append("")
        lines.extend(job_ratings_table(caps, sid, skills))
        lines.append("")
        lines.append("### Weapon skills")
        lines.append("")
        lines.append(
            "| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |"
        )
        lines.append(
            "| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |"
        )

        cat_rows = [
            r
            for r in ws_rows
            if TYPE_TO_SKILL.get(r[2]) == sid
        ]
        cat_rows.sort(key=lambda r: (r[3], r[0]))  # skill asc, then id

        br, wr = best_worst_rank(sid, skills)
        cb = caps[75][br] if br is not None else 0

        for wid, wname, _wtype, sklvl, unlock in cat_rows:
            best_lv = min_level_for_rank(caps, br, sklvl) if br is not None and sklvl > 0 else None
            worst_lv = min_level_for_rank(caps, wr, sklvl) if wr is not None and sklvl > 0 else None
            note = ws_notes(sklvl, unlock, best_lv, worst_lv, cb, caps, br)
            sugg = suggested_level(sklvl, unlock, best_lv, cb)
            bl = "" if best_lv is None else str(best_lv)
            wl = "" if worst_lv is None else str(worst_lv)
            disp = ws_display_name(wid, wname, ws_names)
            lines.append(
                f"| {disp} | {wid} | {sklvl} | {unlock} | {bl} | {wl} | {sugg} | {note} |"
            )
        lines.append("")

    out_path = ROOT / "documentation" / "weaponskill_availability_by_level.md"
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {out_path} ({len(ws_rows)} weapon skills)")


if __name__ == "__main__":
    main()
