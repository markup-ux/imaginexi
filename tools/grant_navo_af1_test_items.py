#!/usr/bin/env python3
"""
Grant GEO + RUN AF1 trade materials to a character.

Two methods:
  --method delivery   (default) INSERT into delivery_box box=1 (incoming); pick up at a Moogle.
  --method inventory  Append to main bag using empty slots / new high slots only (never overwrites).

Credentials: edit CFG below or match server/settings/network.lua

Aggregated from:
  scripts/zones/GM_Home/imagine_geo_af1_npc.lua
  scripts/zones/GM_Home/imagine_run_af1_npc.lua
"""
from __future__ import annotations

import argparse
import os

import mariadb

CFG = dict(
    host=os.getenv("XI_NETWORK_SQL_HOST", "127.0.0.1"),
    port=int(os.getenv("XI_NETWORK_SQL_PORT", "3306")),
    user=os.getenv("XI_NETWORK_SQL_LOGIN", "root"),
    password=os.getenv("XI_NETWORK_SQL_PASSWORD", "root"),
    database=os.getenv("XI_NETWORK_SQL_DATABASE", "xidb"),
)

LOCATION_INV = 0  # xi.inventoryLocation.INVENTORY
BOX_INCOMING = 1

# (itemId, total qty) — stacks split to 99 max when inserting
ITEMS = [
    (4096, 5),   # FIRE_CRYSTAL
    (4097, 4),   # ICE_CRYSTAL
    (4098, 3),   # WIND_CRYSTAL
    (4099, 5),   # EARTH_CRYSTAL
    (4100, 2),   # LIGHTNING_CRYSTAL
    (4101, 1),   # WATER_CRYSTAL
    (4102, 3),   # LIGHT_CRYSTAL
    (4103, 1),   # DARK_CRYSTAL
    (703, 1),    # PETRIFIED_LOG
    (690, 1),    # ELM_LOG
    (700, 2),    # MAHOGANY_LOG
    (816, 1),    # SPOOL_OF_SILK_THREAD
    (826, 1),    # SQUARE_OF_LINEN_CLOTH
    (850, 1),    # SQUARE_OF_SHEEP_LEATHER
    (855, 2),    # SQUARE_OF_BLACK_TIGER_LEATHER
    (651, 1),    # IRON_INGOT
    (653, 2),    # MYTHRIL_INGOT
    (654, 2),    # DARKSTEEL_INGOT
    (655, 1),    # ADAMAN_INGOT
    (16537, 1),  # MYTHRIL_SWORD
]


def split_stacks(items: list[tuple[int, int]]) -> list[tuple[int, int]]:
    out: list[tuple[int, int]] = []
    for item_id, total in items:
        remain = total
        while remain > 0:
            q = min(remain, 99)
            out.append((item_id, q))
            remain -= q
    return out


def grant_delivery(cur, charid: int, charname: str) -> None:
    """Same shape as dboxutils incoming row: box=1, trigger assigns slot >= 8."""
    sender = "ImagineXI_AF1"
    senderid = 0
    for item_id, qty in split_stacks(ITEMS):
        cur.execute(
            "INSERT INTO delivery_box (charid, charname, box, itemid, itemsubid, quantity, extra, senderid, sender) "
            "VALUES (%s, %s, %s, %s, 0, %s, NULL, %s, %s)",
            (charid, charname, BOX_INCOMING, item_id, qty, senderid, sender),
        )
        print("delivery box:", charname, "item", item_id, "qty", qty)


def grant_inventory_append_only(cur, charid: int) -> None:
    """
    Only use slots that are empty (65535 / qty 0) or new indices after max slot.
    Does not REPLACE occupied equipment/items.
    Never uses slot 0 — that slot is gil (currency) for the client.
    """
    cur.execute(
        "SELECT slot, itemId, quantity FROM char_inventory "
        "WHERE charid = %s AND location = %s ORDER BY slot",
        (charid, LOCATION_INV),
    )
    rows = cur.fetchall()
    # Slot 0 is reserved for gil (currency) in the client; never place normal items there.
    empty_slots = [r[0] for r in rows if r[0] != 0 and (r[1] == 65535 or r[2] == 0)]
    max_slot = max((r[0] for r in rows), default=-1)

    def next_slot() -> int:
        nonlocal max_slot
        if empty_slots:
            return empty_slots.pop(0)
        max_slot += 1
        return max_slot

    for item_id, qty in split_stacks(ITEMS):
        slot = next_slot()
        cur.execute(
            "REPLACE INTO char_inventory (charid, location, slot, itemId, quantity, bazaar, signature) "
            "VALUES (%s, %s, %s, %s, %s, 0, '')",
            (charid, LOCATION_INV, slot, item_id, qty),
        )
        print("inventory slot", slot, "item", item_id, "qty", qty)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--char", default="Navo", help="Character name (case-sensitive in DB)")
    p.add_argument(
        "--method",
        choices=("delivery", "inventory"),
        default="delivery",
        help="delivery = Moogle incoming mail (recommended); inventory = main bag",
    )
    args = p.parse_args()

    conn = mariadb.connect(**CFG)
    cur = conn.cursor()
    cur.execute("SELECT charid, charname FROM chars WHERE charname = %s LIMIT 1", (args.char,))
    row = cur.fetchone()
    if not row:
        print("Character not found:", args.char)
        print("Tip: names are case-sensitive. Try: SELECT charid, charname FROM chars WHERE LOWER(charname)=LOWER('navo');")
        return 1
    charid, charname = int(row[0]), row[1]
    print("charid", charid, "charname", charname, "method", args.method)

    if args.method == "delivery":
        grant_delivery(cur, charid, charname)
        print("Done. Log in and check Delivery at a Moogle (incoming).")
    else:
        grant_inventory_append_only(cur, charid)
        print("Done. Relog or zone to refresh inventory.")

    conn.commit()
    conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
