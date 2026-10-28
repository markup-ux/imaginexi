import mariadb


def migration_name():
    return "Making char_effects.subpower unsigned to match uint16 (Dedication cap 65535)."


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute(
        "SHOW COLUMNS FROM char_effects WHERE FIELD = 'subpower' AND TYPE = 'smallint(5)';"
    )
    if cur.fetchone():
        return True
    return False


def migrate(cur, db):
    try:
        cur.execute(
            "ALTER TABLE char_effects MODIFY subpower smallint(5) unsigned NOT NULL DEFAULT '0';"
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
