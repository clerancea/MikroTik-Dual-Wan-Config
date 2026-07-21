# Backup & Restore

## Creating a Backup

### Binary backup (full system state, including RouterOS-encrypted secrets)

```
/system backup save name="<hostname>_<YYYY-MM-DD>"
```

> Replace `<hostname>_<YYYY-MM-DD>` with an actual name, e.g. `gw01_2026-07-21`. A consistent naming convention is what makes "weekly backups" actually useful later — without one, files just overwrite or pile up with no way to tell them apart.

### Configuration export (plain-text script, for version control / review)

```
/export show-sensitive=no file="<hostname>_<YYYY-MM-DD>_export"
```

> **Security-critical:** always use `show-sensitive=no` for any export destined for GitHub or another shared location. A plain `/export` can include plaintext secrets (VPN/PPP passwords, API keys, RADIUS shared secrets) depending on RouterOS version. This is the difference between a "sanitized export" and an accidental credential leak — double-check the exported file for secrets before committing, even with this flag set.

## Backup Storage

| Destination | Use for |
|---|---|
| GitHub repository | Sanitized (`show-sensitive=no`) exports only — never binary backups or unredacted exports |
| SharePoint / secure cloud storage | Full binary backups (may contain encrypted sensitive data) |
| Offline storage | Periodic full backups, for recovery if all networked storage is unavailable |

## Restoration

### Restoring a binary backup

```
/system backup load name="<hostname>_<YYYY-MM-DD>.backup"
```

> This reboots the router and fully overwrites the running configuration — confirm you're restoring the intended file before running this.

### Restoring from an exported script

```
/import file-name="<hostname>_<YYYY-MM-DD>_export.rsc"
```

### After any restore

1. Confirm interfaces came up as expected: `/interface print`
2. Confirm PCC and failover are still functioning correctly — re-run the checks in [`failover-testing.md`](failover-testing.md) rather than assuming a clean restore means everything works.
3. Confirm WAN gateways and DNS are reachable.

## Backup Schedule

| Item | Frequency | Retention |
|---|---|---|
| Configuration export | Weekly | Keep last 4 |
| Full binary backup | Monthly | Keep last 6 |
| Post-change backup | Immediately after any config change | Keep until superseded by next scheduled backup |
