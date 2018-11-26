#!/bin/sh
#
# Restore a single git repository from multiple bundle files.
#
# Run this script inside a directory with backup bundle files.
#
# Usage: backup-git-restore.sh <backup_dir> <repo_name>
# Restores the repository <repo_name> from bundle files named "<repo_name>_*.bundle"
# into a new git repository "<backup_dir>/<repo_name>".
#

REPO=$1
BACKUP_DIR=${2:-"$HOME/dotfiles/git_backup"}

if [ $# -lt 1 ]; then
	echo "Usage: `basename $0` <repo_name> [<backup_dir>]"
	echo "Example: `basename $0` repo /tmp/git_backup/"
	exit 1
fi

rc=1

for file in `ls ${BACKUP_DIR}/${REPO}.bundle`
do
	bundleFile="${file}"
    git clone ${bundleFile} -o bundle
	rc=$?
done

if [ ${rc} -eq 0 ]; then
	echo "INFO: repository ${REPO} restored successfully"
else
	echo "ERROR: restoring failed: ${rc}"
	exit ${rc}
fi

