## Backup & Restore

**Creating a Backup**

- Binary Backup

   /system backup save name="desired name"

  **** replace "desired name" with your prefered name

Export Configuration

/export file="desired name"

**** remember to set the correct name for the file export

## Backup Storage

Store backups securely in:

- GitHub repository (sanitized exports only)
- SharePoint
- Secure cloud storage
- Offline storage

## Restoration

- Restoring Binary Backup**

   /system backup load name=""desired name.backup
  
**** remember to set the correct name for the file restore


- Restoring Exported Backup file

   /import file-name="desired name".rsc
  
**** remember to set the correct name for the file restore

## Backup Schedule

Recommended:

| Item                 | Frequency                |
| -------------------- | ------------------------ |
| Configuration Export | Weekly                   |
| Full Backup          | Monthly                  |
| Post-change Backup   | Immediately after change |
