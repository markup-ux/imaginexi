#!/usr/bin/env python3
"""Normalize char_inventory slot 0 to gil (itemId 65535). Move any other item to first free slot."""
from __future__ import annotations

import argparse

import pymysql

GIL_ID = 65535
LOC_INV = 0
SLOT_GIL = 0


def first_free_slot(cur: pymysql.cursors.Cursor, charid: int) -> int:
    cur.execute(
        "SELECT slot FROM char_inventory WHERE charid=%s AND location=%s",
        (charid, LOC_INV),
    )
    used = {row[0] for row in cur.fetchall()}
    s = 1
    while s in used:
        s += 1
    return s


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument("--user", default="root")
    p.add_argument("--password", default="Pass")
    p.add_argument("--database", default="xidb")
    args = p.parse_args()

    conn = pymysql.connect(
        host=args.host,
        user=args.user,
        password=args.password,
        database=args.database,
    )
    cur = conn.cursor()
    cur.execute(
        """
        SELECT charid, itemId, quantity, bazaar, signature, extra
        FROM char_inventory
        WHERE location=%s AND slot=%s AND itemId != %s
        """,
        (LOC_INV, SLOT_GIL, GIL_ID),
    )
    bad = cur.fetchall()
    print("Rows to fix:", len(bad))

    if args.dry_run:
        for row in bad:
            print("  would fix", row)
        conn.close()
        return 0

    try:
        conn.begin()
        for charid, item_id, qty, _bazaar, _sig, _extra in bad:
            if item_id == 0 and qty == 0:
                cur.execute(
                    """
                    UPDATE char_inventory
                    SET itemId=%s, quantity=0, bazaar=0, signature='', extra=NULL
                    WHERE charid=%s AND location=%s AND slot=%s
                    """,
                    (GIL_ID, charid, LOC_INV, SLOT_GIL),
                )
                print(f"  charid {charid}: normalized empty slot 0 -> gil")
                continue

            new_slot = first_free_slot(cur, charid)
            cur.execute(
                """
                UPDATE char_inventory
                SET slot=%s
                WHERE charid=%s AND location=%s AND slot=%s
                """,
                (new_slot, charid, LOC_INV, SLOT_GIL),
            )
            print(f"  charid {charid}: moved item {item_id} x{qty} from slot 0 -> slot {new_slot}")

            cur.execute(
                """
                INSERT INTO char_inventory (charid, location, slot, itemId, quantity, bazaar, signature, extra)
                VALUES (%s, %s, %s, %s, 0, 0, '', NULL)
                """,
                (charid, LOC_INV, SLOT_GIL, GIL_ID),
            )
            print(f"  charid {charid}: inserted gil row at slot 0 (qty 0)")

        conn.commit()
        print("Committed.")
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

    conn = pymysql.connect(
        host=args.host,
        user=args.user,
        password=args.password,
        database=args.database,
    )
    cur = conn.cursor()
    cur.execute(
        """
        SELECT c.charid, c.charname, i.itemId, i.quantity
        FROM char_inventory i
        JOIN chars c ON c.charid = i.charid
        WHERE i.location=%s AND i.slot=%s
        ORDER BY c.charid
        """,
        (LOC_INV, SLOT_GIL),
    )
    print("All slot-0 rows:")
    for row in cur.fetchall():
        print(" ", row)

    cur.execute(
        """
        SELECT COUNT(*) FROM char_inventory
        WHERE location=%s AND slot=%s AND itemId != %s
        """,
        (LOC_INV, SLOT_GIL, GIL_ID),
    )
    print("Remaining bad slot-0 count:", cur.fetchone()[0])
    conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
